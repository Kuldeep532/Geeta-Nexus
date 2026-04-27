import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/gita_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class GeetaVoicePracticeScreen extends StatefulWidget {
  const GeetaVoicePracticeScreen({super.key});

  @override
  State<GeetaVoicePracticeScreen> createState() => _GeetaVoicePracticeScreenState();
}

class _GeetaVoicePracticeScreenState extends State<GeetaVoicePracticeScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final Random _random = Random();

  Verse? _targetVerse;
  String _spoken = '';
  double _similarity = 0;
  bool _listening = false;
  bool _speechReady = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
    _loadRandomVerse();
  }

  Future<void> _initVoice() async {
    final ready = await _speech.initialize();
    await _tts.setLanguage('en-IN'); // Hindi/Indian accent support
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));

    if (mounted) setState(() => _speechReady = ready);
  }

  void _loadRandomVerse() {
    final verses = getAllVerses().where((v) => v.translation.isNotEmpty).toList();
    if (verses.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _targetVerse = verses[_random.nextInt(verses.length)];
      _spoken = '';
      _similarity = 0;
    });
    // Blind User Feature: Naya verse aate hi uska reference bol kar sunaye
    _tts.speak("Practice verse from Chapter ${_targetVerse!.chapter}, Verse ${_targetVerse!.verse}");
  }

  Future<void> _speakTarget() async {
    if (_targetVerse == null) return;
    await _tts.stop();
    await _tts.speak(_targetVerse!.translation);
  }

  Future<void> _toggleListen() async {
    if (!_speechReady) return;

    if (_listening) {
      await _speech.stop();
      HapticFeedback.mediumImpact();
      setState(() => _listening = false);
      return;
    }

    HapticFeedback.mediumImpact();
    await _speech.listen(
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        if (!mounted || _targetVerse == null) return;

        setState(() {
          _spoken = result.recognizedWords;
          _similarity = _calculateSimilarity(_targetVerse!.translation, _spoken);
          _listening = !result.finalResult;
        });

        if (result.finalResult) {
          context.read<AppState>().addXp(10 + (_similarity * 10).round());
          // Final Feedback for Blind Users
          _tts.speak("Accuracy is ${(_similarity * 100).round()} percent.");
        }
      },
    );

    if (mounted) setState(() => _listening = true);
  }

  double _calculateSimilarity(String expected, String spoken) {
    final a = _normalize(expected);
    final b = _normalize(spoken);
    if (a.isEmpty || b.isEmpty) return 0;

    final expectedWords = a.split(' ').where((w) => w.isNotEmpty).toSet();
    final spokenWords = b.split(' ').where((w) => w.isNotEmpty).toSet();
    final intersection = expectedWords.intersection(spokenWords).length;
    return (intersection / expectedWords.length).clamp(0, 1);
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verse = _targetVerse;

    return Scaffold(
      appBar: AppBar(title: const Text('Geeta Voice Practice')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: verse == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Chapter ${verse.chapter}, Verse ${verse.verse}',
                              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(verse.translation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton.filled(onPressed: _isSpeaking ? null : _speakTarget, icon: const Icon(Icons.volume_up)),
                                IconButton.outlined(onPressed: _loadRandomVerse, icon: const Icon(Icons.shuffle)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAccuracyMeter(theme),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor)),
                        child: SingleChildScrollView(
                          child: Text(
                            _spoken.isEmpty ? 'Tap mic to start reciting...' : _spoken,
                            style: TextStyle(color: _spoken.isEmpty ? theme.hintColor : theme.textTheme.bodyLarge?.color, fontStyle: _spoken.isEmpty ? FontStyle.italic : FontStyle.normal),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _speechReady ? _toggleListen : null,
                      icon: Icon(_listening ? Icons.stop : Icons.mic),
                      label: Text(_listening ? 'STOP PRACTICE' : 'START PRACTICE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: _listening ? Colors.redAccent : theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAccuracyMeter(ThemeData theme) {
    return Column(
      children: [
        Semantics(
          label: "Accuracy level",
          value: "${(_similarity * 100).round()}%",
          child: LinearProgressIndicator(
            value: _similarity,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text('Accuracy: ${(_similarity * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
