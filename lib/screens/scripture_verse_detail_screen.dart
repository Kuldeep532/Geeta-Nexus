import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scripture_model.dart';
import '../models/models.dart';
import '../theme.dart';
import 'quiz_screen.dart';

class ScriptureVerseDetailScreen extends StatefulWidget {
  final List<dynamic> allVerses;
  final int initialIndex;

  const ScriptureVerseDetailScreen({
    super.key,
    required this.allVerses,
    required this.initialIndex,
  });

  @override
  State<ScriptureVerseDetailScreen> createState() => _ScriptureVerseDetailScreenState();
}

class _ScriptureVerseDetailScreenState extends State<ScriptureVerseDetailScreen> {
  late int _currentIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.5);
    _tts.setCompletionHandler(() => setState(() => _isPlaying = false));
  }

  // --- HYBRID OPTIMIZED PLAYER ---
  Future<void> _handlePlay() async {
    final v = widget.allVerses[_currentIndex];
    await _audioPlayer.stop();
    await _tts.stop();

    setState(() => _isPlaying = true);

    // 1. Agar online data (ScriptureVerse) hai aur audioUrl hai
    if (v is ScriptureVerse && v.audioUrl != null && v.audioUrl!.isNotEmpty) {
      await _audioPlayer.play(UrlSource(v.audioUrl!));
    } 
    // 2. Agar offline data (Verse) hai ya audioUrl nahi hai, toh TTS chalao
    else {
      final textToSpeak = (v is ScriptureVerse) ? v.originalText : v.sanskrit;
      await _tts.speak(textToSpeak);
    }
  }

  void _navigateToQuiz() async {
    // Current verse ko model ke hisab se process karke quiz mein bhejein
    final currentVerseData = widget.allVerses[_currentIndex];
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          // Agar Online model hai to vahi, varna Verse se convert karke
          currentVerse: currentVerseData is ScriptureVerse 
              ? currentVerseData 
              : ScriptureVerse.fromLocalVerse(currentVerseData)
        ),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shlok Completed! Agli baar se yahan 'Completed' dikhega.")),
      );
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
    final title = (v is ScriptureVerse) ? v.section.displayLabel : "Chapter ${v.chapter}";
    final text = (v is ScriptureVerse) ? v.originalText : v.sanskrit;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(text, style: GoogleFonts.notoSansDevanagari(fontSize: 22, height: 1.8), textAlign: TextAlign.center),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous), onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null),
                    IconButton(icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 50, color: kGold), onPressed: _handlePlay),
                    IconButton(icon: const Icon(Icons.skip_next), onPressed: _currentIndex < widget.allVerses.length - 1 ? () => setState(() => _currentIndex++) : null),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToQuiz,
                  style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("COMPLETE SHLOK & START QUIZ"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
