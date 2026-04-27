import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme.dart'; 
import '../state/app_state.dart';

const int kMalaBeads = 108;

class ChantsScreen extends StatefulWidget {
  const ChantsScreen({super.key});

  @override
  State<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends State<ChantsScreen> {
  int _selectedMantraIndex = 0;
  late Future<List<Map<String, String>>> _mantraFuture;
  
  final AudioPlayer _mantraPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isBgMusicPlaying = false;
  bool _isVoiceModeActive = false;

  final String _shantiMusicUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3";

  final List<Map<String, String>> _localMantras = const [
    {
      'name': 'Mahamantra',
      'mantra': 'Hare Krishna Hare Krishna Krishna Krishna Hare Hare, Hare Rama Hare Rama Rama Rama Hare Hare',
      'meaning': 'A prayer to the Divine Energy for universal peace and consciousness.',
      'audio': 'https://www.learningu.org/wp-content/uploads/2023/05/Hare-Krishna-Maha-Mantra.mp3'
    },
  ];

  @override
  void initState() {
    super.initState();
    _mantraFuture = _fetchOnlineMantras();
    WakelockPlus.enable(); 
  }

  @override
  void dispose() {
    _mantraPlayer.dispose();
    _bgMusicPlayer.dispose();
    _speech.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<List<Map<String, String>>> _fetchOnlineMantras() async {
    final url = Uri.parse('https://havyaka-rest-api-gaonkarbhai.vercel.app/api/v1/mantras?limit=100');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['mantras'];
        return list.map((m) => {
          'name': m['name']?.toString() ?? 'Unknown',
          'mantra': m['shloka']?.toString() ?? '',
          'meaning': (m['purpose'] ?? m['benefits'] ?? 'Sacred Chant').toString(),
          'audio': 'https://www.learningu.org/wp-content/uploads/2023/05/Hare-Krishna-Maha-Mantra.mp3'
        }).toList();
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return _localMantras;
  }

  void _toggleVoiceMode(AppState state, String mantraName) async {
    if (!_isVoiceModeActive) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isVoiceModeActive = true);
        _speech.listen(
          onResult: (result) {
            String words = result.recognizedWords.toLowerCase();
            if (words.contains(mantraName.split(' ')[0].toLowerCase())) {
              _incrementChant(state);
            }
          },
          loopStrategy: stt.SpeechToText.loopStrategyNone,
        );
      }
    } else {
      setState(() => _isVoiceModeActive = false);
      _speech.stop();
    }
  }

  void _toggleBgMusic() async {
    if (_isBgMusicPlaying) {
      await _bgMusicPlayer.pause();
    } else {
      await _bgMusicPlayer.play(UrlSource(_shantiMusicUrl), volume: 0.3);
      _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    }
    setState(() => _isBgMusicPlaying = !_isBgMusicPlaying);
  }

  void _incrementChant(AppState state) {
    HapticFeedback.mediumImpact();
    state.incrementJapa();
    final count = state.japaCount % kMalaBeads;
    if (count == 0 && state.japaCount > 0) {
      HapticFeedback.heavyImpact();
      SemanticsService.announce("Mala Round Completed", Directionality.of(context));
    } else {
      SemanticsService.announce("Bead $count", Directionality.of(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goldColor = const Color(0xFFFFD700);
    final appState = context.watch<AppState>();
    final japa = appState.japaCount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Japa & Chants', style: GoogleFonts.cinzel(color: goldColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isBgMusicPlaying ? Icons.music_note : Icons.music_off, color: goldColor),
            onPressed: _toggleBgMusic,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.resetJapa(),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _mantraFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final mantras = snapshot.data!;
          final mantra = mantras[_selectedMantraIndex];

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSelector(mantras, theme, goldColor),
                  const SizedBox(height: 20),
                  _buildMantraCard(mantra, theme, goldColor),
                  const SizedBox(height: 40),
                  _buildCounterDisplay(japa, goldColor),
                  const SizedBox(height: 24),
                  _buildProgress(japa % kMalaBeads, goldColor, theme),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton.icon(
                      onPressed: () => _incrementChant(appState),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('MANUAL CHANT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _toggleVoiceMode(appState, mantra['name']!),
        label: Text(_isVoiceModeActive ? "LISTENING..." : "VOICE MODE"),
        icon: Icon(_isVoiceModeActive ? Icons.mic : Icons.mic_none),
        backgroundColor: _isVoiceModeActive ? Colors.redAccent : goldColor,
      ),
    );
  }

  // --- UI Helper Methods (BuildSelector, buildMantraCard etc. yahan aayenge) ---
}
