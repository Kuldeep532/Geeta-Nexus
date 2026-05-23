import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/scripture_model.dart';
import '../models/models.dart';
import '../theme.dart';
import 'quiz_screen.dart';
import 'aira_screen.dart';

class ScriptureVerseDetailScreen extends StatefulWidget {
  final List<dynamic> allVerses;
  final int initialIndex;

  const ScriptureVerseDetailScreen({
    super.key,
    required this.allVerses,
    required this.initialIndex,
  });

  @override
  State<ScriptureVerseDetailScreen> createState() =>
      _ScriptureVerseDetailScreenState();
}

class _ScriptureVerseDetailScreenState
    extends State<ScriptureVerseDetailScreen> {
  late int _currentIndex;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _isPlaying = false;
  bool _isAudioMode = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _initTts();
    _initAudioListeners();
  }

  // =========================
  // INIT
  // =========================

  Future<void> _initTts() async {
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    _tts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _initAudioListeners() {
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  // =========================
  // GETTERS
  // =========================

  dynamic get currentVerse => widget.allVerses[_currentIndex];

  bool get hasAudio {
    final v = currentVerse;

    return v is ScriptureVerse &&
        v.audioUrl != null &&
        v.audioUrl.toString().trim().isNotEmpty;
  }

  String get verseText {
    final v = currentVerse;

    if (v is ScriptureVerse) {
      return v.originalText;
    }

    return v.sanskrit;
  }

  String get verseTitle {
    final v = currentVerse;

    if (v is ScriptureVerse) {
      return v.section.displayLabel;
    }

    return "Chapter ${v.chapter}";
  }

  // =========================
  // AUDIO / TTS
  // =========================

  Future<void> _stopAll() async {
    await _audioPlayer.stop();
    await _tts.stop();

    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _handlePlayPause() async {
    if (_isPlaying) {
      await _stopAll();
      return;
    }

    await _playCurrentVerse();
  }

  Future<void> _playCurrentVerse() async {
    final v = currentVerse;

    await _audioPlayer.stop();
    await _tts.stop();

    setState(() {
      _isPlaying = true;
      _showControls = true;
    });

    try {
      // =========================
      // ONLINE AUDIO
      // =========================

      if (hasAudio) {
        _isAudioMode = true;

        await _audioPlayer.play(
          UrlSource(v.audioUrl!),
        );
      }

      // =========================
      // TTS FALLBACK
      // =========================

      else {
        _isAudioMode = false;

        await _tts.speak(verseText);
      }
    } catch (e) {
      setState(() {
        _isPlaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to play audio",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  // =========================
  // NAVIGATION
  // =========================

  Future<void> _changeVerse(int index) async {
    if (index < 0 || index >= widget.allVerses.length) return;

    await _stopAll();

    setState(() {
      _currentIndex = index;
      _showControls = false;
    });
  }

  Future<void> _nextVerse() async {
    if (_currentIndex < widget.allVerses.length - 1) {
      await _changeVerse(_currentIndex + 1);
    }
  }

  Future<void> _previousVerse() async {
    if (_currentIndex > 0) {
      await _changeVerse(_currentIndex - 1);
    }
  }

  // =========================
  // QUIZ
  // =========================

  void _navigateToQuiz() async {
    final currentVerseData = currentVerse;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          currentVerse: currentVerseData is ScriptureVerse
              ? currentVerseData
              : ScriptureVerse.fromLocalVerse(currentVerseData),
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Shlok Completed! Quiz finished successfully.",
          ),
        ),
      );
    }
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final v = currentVerse;
    final String shlokaContext = v is ScriptureVerse
        ? '${v.originalText}\n[${v.section.displayLabel}]'
        : '${v.sanskrit}\n[Chapter ${v.chapter}, Verse ${v.verse}]';
    final String verseRef = v is ScriptureVerse
        ? v.section.displayLabel
        : 'Chapter ${v.chapter}, Verse ${v.verse}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Semantics(
          header: true,
          namesRoute: true,
          child: Text(
            verseTitle,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Ask Aira about this verse',
            hint: 'Double tap to open Aira AI with this verse as context',
            child: IconButton(
              tooltip: 'Ask Aira',
              icon: const Icon(Icons.support_agent_rounded, color: kGold),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiraScreen(
                      contextShloka: shlokaContext,
                      contextVerse: verseRef,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // VERSE CONTENT
            // =========================

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    verseText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 24,
                      height: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // =========================
            // QUIZ BUTTON
            // =========================

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _navigateToQuiz,
                  icon: const Icon(Icons.quiz_outlined),
                  label: Text(
                    "COMPLETE SHLOK & START QUIZ",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),

            // =========================
            // BOTTOM AUDIO PLAYER
            // =========================

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TOP LABEL
                  Semantics(
                    label: hasAudio
                        ? 'Audio narration available'
                        : 'Text to speech mode',
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          Icon(
                            hasAudio
                                ? Icons.multitrack_audio
                                : Icons.record_voice_over,
                            color: kGold,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              hasAudio
                                  ? 'Audio narration available'
                                  : 'Text to speech mode',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // CONTROLS
                  // =========================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // PREVIOUS
                      _buildControlButton(
                        icon: Icons.skip_previous_rounded,
                        label: 'Previous verse',
                        onTap: _currentIndex > 0 ? _previousVerse : null,
                        enabled: _currentIndex > 0,
                      ),

                      // REWIND (audio only)
                      if (hasAudio)
                        _buildControlButton(
                          icon: Icons.replay_10_rounded,
                          label: 'Rewind 10 seconds',
                          onTap: () async {
                            final position =
                                await _audioPlayer.getCurrentPosition();
                            if (position != null) {
                              await _audioPlayer.seek(
                                  position - const Duration(seconds: 10));
                            }
                          },
                          enabled: true,
                        ),

                      // PLAY / PAUSE
                      Semantics(
                        button: true,
                        label: _isPlaying
                            ? 'Stop playback'
                            : (hasAudio
                                ? 'Play audio narration'
                                : 'Read shlok aloud'),
                        hint: 'Double tap to ${_isPlaying ? "stop" : "play"}',
                        child: ExcludeSemantics(
                          child: Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kGold,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: kGold.withOpacity(0.4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _handlePlayPause,
                              icon: Icon(
                                _isPlaying
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                                size: 38,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // FORWARD (audio only)
                      if (hasAudio)
                        _buildControlButton(
                          icon: Icons.forward_10_rounded,
                          label: 'Forward 10 seconds',
                          onTap: () async {
                            final position =
                                await _audioPlayer.getCurrentPosition();
                            if (position != null) {
                              await _audioPlayer.seek(
                                  position + const Duration(seconds: 10));
                            }
                          },
                          enabled: true,
                        ),

                      // NEXT
                      _buildControlButton(
                        icon: Icons.skip_next_rounded,
                        label: 'Next verse',
                        onTap: _currentIndex < widget.allVerses.length - 1
                            ? _nextVerse
                            : null,
                        enabled: _currentIndex < widget.allVerses.length - 1,
                      ),
                    ],
                  ),

                  // STATUS TEXT — liveRegion so screen reader announces changes
                  if (_showControls) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      label: _isPlaying
                          ? (hasAudio ? 'Playing audio' : 'Reading shlok')
                          : 'Playback stopped',
                      child: ExcludeSemantics(
                        child: Text(
                          _isPlaying
                              ? (hasAudio ? 'Playing audio…' : 'Reading shlok…')
                              : 'Playback stopped',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // REUSABLE BUTTON
  // =========================

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: enabled ? 'Double tap to activate' : 'Not available',
      child: ExcludeSemantics(
        child: Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? kGold.withOpacity(0.12)
                : Colors.grey.withOpacity(0.15),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              size: 28,
              color: enabled ? kGold : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
