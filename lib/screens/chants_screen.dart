import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          }
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
    } 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goldColor = kGold; 
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
      floatingActionButton: FutureBuilder<List<Map<String, String>>>(
        future: _mantraFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final mantras = snapshot.data!;
          final mantra = mantras[_selectedMantraIndex];
          return FloatingActionButton.extended(
            onPressed: () => _toggleVoiceMode(appState, mantra['name']!),
            label: Text(_isVoiceModeActive ? "LISTENING..." : "VOICE MODE"),
            icon: Icon(_isVoiceModeActive ? Icons.mic : Icons.mic_none),
            backgroundColor: _isVoiceModeActive ? Colors.redAccent : goldColor,
          );
        }
      ),
    );
  }

  Widget _buildSelector(List<Map<String, String>> mantras, ThemeData theme, Color gold) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mantras.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedMantraIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(mantras[index]['name']!),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedMantraIndex = index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMantraCard(Map<String, String> mantra, ThemeData theme, Color gold) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: gold.withOpacity(0.5)), // FIX: Changed 'border' to 'side'
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              mantra['mantra']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansDevanagari(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            Text(
              mantra['meaning']!,
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterDisplay(int japa, Color gold) {
    int rounds = japa ~/ kMalaBeads;
    int currentBead = japa % kMalaBeads;
    return Column(
      children: [
        Text("ROUNDS: $rounds", style: TextStyle(fontSize: 18, color: gold, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: gold, width: 4),
          ),
          child: Center(
            child: Text("$currentBead", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(int currentBead, Color gold, ThemeData theme) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: currentBead / kMalaBeads,
          backgroundColor: theme.dividerColor,
          color: gold,
          minHeight: 10,
        ),
        const SizedBox(height: 8),
        Text("$currentBead / $kMalaBeads Beads"),
      ],
    );
  }
}
