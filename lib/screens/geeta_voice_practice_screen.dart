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
  State<GeetaVoicePracticeScreen> createState() =>
      _GeetaVoicePracticeScreenState();
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
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.43);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    if (mounted) {
      setState(() => _speechReady = ready);
    }
  }

  void _loadRandomVerse() {
    final verses = getAllVerses().where((v) => v.translation.isNotEmpty).toList();
    if (verses.isEmpty) return;
    setState(() {
      _targetVerse = verses[_random.nextInt(verses.length)];
      _spoken = '';
      _similarity = 0;
    });
  }

  Future<void> _speakTarget() async {
    final verse = _targetVerse;
    if (verse == null) return;
    await _tts.stop();
    await _tts.speak(verse.translation);
  }

  Future<void> _toggleListen() async {
    if (!_speechReady) return;

    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    await _speech.listen(
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        final words = result.recognizedWords;
        final verse = _targetVerse;
        if (!mounted || verse == null) return;

        setState(() {
          _spoken = words;
          _similarity = _calculateSimilarity(verse.translation, words);
          _listening = !result.finalResult;
        });

        if (result.finalResult) {
          context.read<AppState>().addXp(10 + (_similarity * 10).round());
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
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verse = _targetVerse;
    final cs = Theme.of(context).colorScheme;

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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapter ${verse.chapter}, Verse ${verse.verse}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(verse.translation),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                FilledButton.icon(
                                  onPressed: _isSpeaking ? null : _speakTarget,
                                  icon: const Icon(Icons.volume_up),
                                  label: const Text('Listen'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _loadRandomVerse,
                                  icon: const Icon(Icons.shuffle),
                                  label: const Text('New Verse'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      label: 'Speech accuracy',
                      value: '${(_similarity * 100).round()} percent',
                      child: LinearProgressIndicator(
                        value: _similarity,
                        minHeight: 10,
                        backgroundColor: cs.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Accuracy: ${(_similarity * 100).round()}%'),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Text(
                              _spoken.isEmpty
                                  ? 'Tap Start Practice and recite the verse aloud. Your spoken words will appear here.'
                                  : _spoken,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _speechReady ? _toggleListen : null,
                      icon: Icon(_listening ? Icons.stop : Icons.mic),
                      label: Text(_listening ? 'Stop Practice' : 'Start Practice'),
                    ),
                    if (!_speechReady)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Microphone permission unavailable. Enable microphone access to practice.',
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final state = context.read<AppState>();
          if (state.hapticsEnabled) {
            HapticFeedback.mediumImpact();
          }
          _loadRandomVerse();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh Verse'),
      ),
    );
  }
}
