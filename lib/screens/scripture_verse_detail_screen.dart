import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/scripture_model.dart';
import '../theme.dart';

class ScriptureVerseDetailScreen extends StatefulWidget {
  final List<ScriptureVerse> allVerses;
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
  final AudioPlayer _player = AudioPlayer();
  FlutterTts? _tts;
  stt.SpeechToText? _stt;
  
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isBookmarked = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _setupAudio();
    _initTtsAndStt();
  }

  void _setupAudio() {
    _player.onPlayerStateChanged.listen((s) => setState(() => _playerState = s));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
  }

  void _initTtsAndStt() {
    _tts = FlutterTts();
    _tts!.setLanguage('hi-IN');
    _stt = stt.SpeechToText();
  }

  @override
  void dispose() {
    _player.dispose();
    _tts?.stop();
    _stt?.stop();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    _playerState == PlayerState.playing ? await _player.pause() : await _player.resume();
  }

  void _toggleBookmark() => setState(() => _isBookmarked = !_isBookmarked);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final v = widget.allVerses[_currentIndex];
    
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = theme.scaffoldBackgroundColor;
    final panelColor = isDark ? theme.cardColor : const Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(v.section.displayLabel, style: GoogleFonts.lato(color: textColor, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: kGold),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Text(
                v.originalText,
                style: GoogleFonts.notoSansDevanagari(fontSize: 22, color: textColor, height: 1.8),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: panelColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                ProgressBar(
                  progress: _position,
                  total: _duration,
                  progressBarColor: kGold,
                  baseBarColor: kGold.withOpacity(0.2),
                  thumbColor: kGold,
                  onSeek: (d) => _player.seek(d),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: Icon(Icons.replay_10, color: textColor, size: 30), onPressed: () => _player.seek(_position - const Duration(seconds: 10))),
                    const SizedBox(width: 30),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kGold, width: 2)),
                      child: IconButton(
                        icon: Icon(_playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow, size: 40, color: kGold),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    const SizedBox(width: 30),
                    IconButton(icon: Icon(Icons.forward_30, color: textColor, size: 30), onPressed: () => _player.seek(_position + const Duration(seconds: 30))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
