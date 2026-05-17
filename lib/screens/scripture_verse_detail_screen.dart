import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/scripture_model.dart';
import '../services/scripture_repository.dart';
import '../state/app_state.dart';
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
  State<ScriptureVerseDetailScreen> createState() =>
      _ScriptureVerseDetailScreenState();
}

class _ScriptureVerseDetailScreenState
    extends State<ScriptureVerseDetailScreen> {
  late int _currentIndex;

  // Audio playback
  final AudioPlayer _player = AudioPlayer();
  final ScriptureRepository _repo = ScriptureRepository();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _audioSearching = false;
  String? _resolvedAudioUrl;
  String _liveStatus = '';

  // TTS / Pronunciation
  FlutterTts? _tts;
  stt.SpeechToText? _stt;
  final bool _showTransliteration = true;
  bool _isListening = false;
  String _userSpokenText = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _setupAudioListeners();
    _onVerseChanged();
  }

  void _setupAudioListeners() {
    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _playerState = s);
      if (s == PlayerState.completed) {
        setState(() {
          _position = Duration.zero;
          _liveStatus = 'Playback finished';
        });
        SemanticsService.announce('Playback finished', TextDirection.ltr);
      }
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
  }

  void _onVerseChanged() {
    final v = _verse;

    if (v.localVerseId != null) {
      Future.microtask(() {
        if (mounted) context.read<AppState>().markVerseRead(v.localVerseId!);
      });
    }

    if (v.transliteration != null) {
      _tts ??= FlutterTts();
      _tts!.setLanguage('hi-IN');
      _tts!.setSpeechRate(0.4);
      _stt ??= stt.SpeechToText();
    } else {
      _tts?.stop();
      _stt?.stop();
    }

    _initAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    _tts?.stop();
    _stt?.stop();
    super.dispose();
  }

  ScriptureVerse get _verse => widget.allVerses[_currentIndex];

  // ── Audio Methods ──────────────────────────────────────────────────────────

  Future<void> _initAudio() async {
    setState(() {
      _resolvedAudioUrl = null;
      _audioSearching = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _player.stop();

    final url = _verse.audioUrl;
    if (url != null && url.isNotEmpty) {
      setState(() => _resolvedAudioUrl = url);
    } else {
      final query = _repo.archiveQueryFor(_verse);
      if (query.isNotEmpty) {
        setState(() => _audioSearching = true);
        try {
          final result = await _repo.searchArchiveAudio(query);
          if (mounted && result != null) {
            setState(() => _resolvedAudioUrl = result.streamUrl);
          }
        } catch (_) {}
        if (mounted) setState(() => _audioSearching = false);
      }
    }
  }

  Future<void> _playPause() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
      const msg = 'Audio paused';
      setState(() => _liveStatus = msg);
      SemanticsService.announce(msg, TextDirection.ltr);
    } else if (_playerState == PlayerState.paused) {
      await _player.resume();
      const msg = 'Audio resumed';
      setState(() => _liveStatus = msg);
      SemanticsService.announce(msg, TextDirection.ltr);
    } else if (_resolvedAudioUrl != null) {
      final label = 'Now playing ${_verse.section.displayLabel}, verse ${_verse.verseIndex}';
      setState(() => _liveStatus = label);
      SemanticsService.announce(label, TextDirection.ltr);
      await _player.play(UrlSource(_resolvedAudioUrl!));
    }
  }

  Future<void> _seek(Duration d) async {
    if (_resolvedAudioUrl == null) return;
    await _player.seek(d.isNegative ? Duration.zero : d);
  }

  Future<void> _rewind10() => _seek(_position - const Duration(seconds: 10));
  Future<void> _forward30() => _seek(_position + const Duration(seconds: 30));

  // ── TTS / Pronunciation ────────────────────────────────────────────────────

  Future<void> _speakVerse() async {
    HapticFeedback.selectionClick();
    final text = (_showTransliteration && _verse.transliteration != null)
        ? _verse.transliteration!
        : _verse.originalText;
    await _tts?.speak(text);
  }

  void _startPractice() async {
    final sttInstance = _stt;
    if (sttInstance == null) return;

    if (!_isListening) {
      final available = await sttInstance.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _userSpokenText = '';
        });
        sttInstance.listen(
          localeId: 'hi_IN',
          onResult: (val) => setState(() {
            _userSpokenText = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              _validateSpeech();
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      sttInstance.stop();
    }
  }

  void _validateSpeech() {
    final original = (_verse.transliteration ?? _verse.originalText)
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '');
    final spoken = _userSpokenText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    if (spoken.isEmpty) return;
    if (original.contains(spoken) || spoken.contains(original)) {
      _showSnack('Sahi Uchcharan! ✨', Colors.green);
    } else {
      HapticFeedback.heavyImpact();
      _showSnack('Phir se koshish karein.', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _navigateTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.allVerses.length) return;
    setState(() {
      _currentIndex = newIndex;
    });
    _onVerseChanged();
    final v = widget.allVerses[newIndex];
    SemanticsService.announce(
        '${v.section.displayLabel}, verse ${v.verseIndex}', TextDirection.ltr);
  }

  void _copyVerse() {
    final v = _verse;
    final text = StringBuffer();
    text.writeln(v.originalText);
    if (v.transliteration != null) text.writeln('\n${v.transliteration}');
    if (v.translations.isNotEmpty) {
      text.writeln('\n— ${v.translations.values.first}');
    }
    Clipboard.setData(ClipboardData(text: text.toString()));
    _showSnack('Verse copied to clipboard', kGoldDim);
  }

  // ── Build Elements ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = _verse;
    final hasTranslit = v.transliteration != null;
    final hasTts = _tts != null;
    final isAudioAvailable = _resolvedAudioUrl != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(color: kGold),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              v.sourceLabel,
              style: GoogleFonts.cinzel(
                  color: kGold, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${v.section.displayLabel} · ${v.verseIndex}',
              style: GoogleFonts.lato(color: kGoldDim, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (hasTts)
            Semantics(
              button: true,
              label: 'Speak verse aloud',
              excludeSemantics: true,
              child: IconButton(
                tooltip: 'Speak verse',
                icon: const Icon(Icons.volume_up_rounded, color: kGold, size: 20),
                onPressed: _speakVerse,
              ),
            ),
          Semantics(
            button: true,
            label: 'Copy verse to clipboard',
            excludeSemantics: true,
            child: IconButton(
              tooltip: 'Copy verse',
              icon: const Icon(Icons.copy_rounded, color: kGold, size: 20),
              onPressed: _copyVerse,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Screen reader live updates status region
          MergeSemantics(
            child: Container(
              height: 1,
              color: Colors.transparent,
              child: Opacity(
                opacity: 0.0,
                child: Text(_liveStatus, style: const TextStyle(fontSize: 1)),
              ),
            ),
          ),
          
          if (hasTranslit)
            ListTile(
              backgroundColor: theme.cardColor,
              leading: Icon(_isListening ? Icons.mic : Icons.mic_none, color: kGold),
              title: Text(
                _isListening ? 'Listening... Speak now' : 'Practice Pronunciation',
                style: GoogleFonts.lato(color: kGold, fontSize: 14),
              ),
              onTap: _startPractice,
            ),

          // Main text area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    v.originalText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amita(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                  ),
                  if (v.transliteration != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      v.transliteration!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                  ],
                  if (v.translations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      v.translations.values.first,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(fontSize: 16, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Control Panel (Dynamically handles layout)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_audioSearching)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: LinearProgressIndicator(color: kGold),
                    ),

                  // Audio progress seek bar (Only visible if audio is found)
                  if (isAudioAvailable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ProgressBar(
                        progress: _position,
                        total: _duration,
                        buffered: Duration.zero,
                        onSeek: _seek,
                        barHeight: 4.0,
                        thumbRadius: 6.0,
                        thumbColor: kGold,
                        activeTrackColor: kGold,
                        inactiveTrackColor: theme.dividerColor,
                        timeLabelTextStyle: GoogleFonts.lato(fontSize: 12, color: kGoldDim),
                      ),
                    ),

                  // Main Interactive Row (Previous, Audio Controls, Next)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous Button
                      Semantics(
                        button: true,
                        label: 'Previous Verse',
                        enabled: _currentIndex > 0,
                        child: IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 32),
                          color: _currentIndex > 0 ? kGold : theme.disabledColor,
                          onPressed: _currentIndex > 0
                              ? () => _navigateTo(_currentIndex - 1)
                              : null,
                        ),
                      ),

                      // Audio Action Controls (Only visible if audio is available)
                      if (isAudioAvailable) ...[
                        Semantics(
                          button: true,
                          label: 'Rewind 10 seconds',
                          child: IconButton(
                            icon: const Icon(Icons.replay_10_rounded, size: 28),
                            color: kGoldDim,
                            onPressed: _rewind10,
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: _playerState == PlayerState.playing ? 'Pause Audio' : 'Play Audio',
                          child: FloatingActionButton(
                            backgroundColor: kGold,
                            foregroundColor: Colors.black,
                            elevation: 2,
                            mini: true,
                            onPressed: _playPause,
                            child: Icon(
                              _playerState == PlayerState.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 28,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Forward 30 seconds',
                          child: IconButton(
                            icon: const Icon(Icons.forward_30_rounded, size: 28),
                            color: kGoldDim,
                            onPressed: _forward30,
                          ),
                        ),
                      ],

                      // Next Button
                      Semantics(
                        button: true,
                        label: 'Next Verse',
                        enabled: _currentIndex < widget.allVerses.length - 1,
                        child: IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 32),
                          color: _currentIndex < widget.allVerses.length - 1
                              ? kGold
                              : theme.disabledColor,
                          onPressed: _currentIndex < widget.allVerses.length - 1
                              ? () => _navigateTo(_currentIndex + 1)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
