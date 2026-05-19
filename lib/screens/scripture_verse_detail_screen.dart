import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scripture_model.dart';
import '../theme.dart';
import 'quiz_screen.dart';

class ScriptureVerseDetailScreen extends StatefulWidget {
  final List<ScriptureVerse> allVerses;
  final int initialIndex;

  const ScriptureVerseDetailScreen({super.key, required this.allVerses, required this.initialIndex});

  @override
  State<ScriptureVerseDetailScreen> createState() => _ScriptureVerseDetailScreenState();
}

class _ScriptureVerseDetailScreenState extends State<ScriptureVerseDetailScreen> {
  late int _currentIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _isTtsPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.5);
    _tts.setCompletionHandler(() => setState(() => _isTtsPlaying = false));
  }

  // Optimized Hybrid Playback
  Future<void> _handlePlay() async {
    final verse = widget.allVerses[_currentIndex];
    
    // Online Audio Priority
    if (verse.audioUrl.isNotEmpty) {
      await _audioPlayer.play(UrlSource(verse.audioUrl));
    } else {
      // Fallback to Offline TTS
      setState(() => _isTtsPlaying = true);
      await _tts.speak(verse.originalText);
    }
  }

  Future<void> _stopAll() async {
    await _audioPlayer.stop();
    await _tts.stop();
    setState(() => _isTtsPlaying = false);
  }

  void _completeShlok() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
    if (result == true) {
      // Yahan Shlok completion status local database ya provider mein update karein
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shlok Completed!")));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.allVerses[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Verse ${_currentIndex + 1}")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(v.originalText, style: GoogleFonts.notoSansDevanagari(fontSize: 22)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous), onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null),
                    IconButton(icon: Icon(_isTtsPlaying ? Icons.stop : Icons.play_arrow, size: 40), onPressed: _handlePlay),
                    IconButton(icon: const Icon(Icons.skip_next), onPressed: _currentIndex < widget.allVerses.length - 1 ? () => setState(() => _currentIndex++) : null),
                  ],
                ),
                ElevatedButton(
                  onPressed: _completeShlok,
                  child: const Text("Complete Shlok & Quiz"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
