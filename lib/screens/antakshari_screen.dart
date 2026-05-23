import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/gita_data.dart';
import '../models/models.dart';
import '../theme.dart';

enum _GameState { idle, airaReciting, userTurn, validating, result }

/// Feature 6: Conversational Shloka Antakshari / Word-Chain Game.
/// Aira recites a Shloka; user must reply with a Shloka starting
/// with the last keyword. Fully voice-driven and accessible.
class AntakshariScreen extends StatefulWidget {
  const AntakshariScreen({super.key});

  @override
  State<AntakshariScreen> createState() => _AntakshariScreenState();
}

class _AntakshariScreenState extends State<AntakshariScreen> {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();

  _GameState _state = _GameState.idle;
  Verse? _currentAiraVerse;
  String _challengeKeyword = '';
  String _userSpokenText = '';
  String _resultMessage = '';
  bool _isCorrect = false;
  int _score = 0;
  int _round = 0;
  bool _isListening = false;
  Verse? _matchedVerse;

  static const int _maxRounds = 5;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.40);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (_state == _GameState.airaReciting) {
        setState(() => _state = _GameState.userTurn);
        SemanticsService.announce(
          'Your turn! Speak a Shloka starting with the keyword: $_challengeKeyword',
          TextDirection.ltr,
        );
      }
    });
  }

  List<Verse> get _allVerses => allVerses;

  Future<void> _startGame() async {
    setState(() {
      _score = 0;
      _round = 0;
      _resultMessage = '';
    });
    await _nextRound();
  }

  Future<void> _nextRound() async {
    if (_round >= _maxRounds) {
      _endGame();
      return;
    }

    final verses = _allVerses;
    if (verses.isEmpty) {
      setState(() {
        _resultMessage =
            'Shloka data not loaded. Please restart the app.';
        _state = _GameState.result;
      });
      return;
    }

    final rng = Random();
    final verse = verses[rng.nextInt(verses.length)];
    final keywords = _extractKeywords(verse.translation);
    if (keywords.isEmpty) {
      await _nextRound();
      return;
    }

    final keyword = keywords[rng.nextInt(keywords.length)];

    setState(() {
      _currentAiraVerse = verse;
      _challengeKeyword = keyword;
      _round++;
      _state = _GameState.airaReciting;
      _userSpokenText = '';
      _matchedVerse = null;
    });

    SemanticsService.announce(
      'Round $_round. Aira is reciting a Shloka.', TextDirection.ltr);

    await _tts.stop();
    final announcement =
        'Round $_round. I recite: Chapter ${verse.chapter}, Verse ${verse.verse}. '
        '${verse.transliteration.isNotEmpty ? verse.transliteration : verse.translation}. '
        'Now reply with a Shloka that contains the keyword: $keyword.';
    await _tts.speak(announcement);
  }

  List<String> _extractKeywords(String text) {
    final stopWords = {
      'the', 'a', 'an', 'is', 'are', 'was', 'were', 'of', 'in', 'on', 'and',
      'to', 'for', 'with', 'he', 'she', 'it', 'they', 'that', 'this', 'by',
      'from', 'at', 'be', 'do', 'not', 'all', 'or', 'as', 'but', 'so',
    };
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(' ')
        .where((w) => w.length > 4 && !stopWords.contains(w))
        .toSet()
        .take(5)
        .toList();
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          setState(() => _isListening = false);
          if (_userSpokenText.trim().isNotEmpty) _validateAnswer();
        }
      },
      onError: (_) => setState(() => _isListening = false),
    );
    if (!available) return;

    setState(() => _isListening = true);
    SemanticsService.announce(
        'Listening. Speak your Shloka.', TextDirection.ltr);

    _speech.listen(
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(seconds: 60),
      partialResults: true,
      onResult: (r) {
        setState(() => _userSpokenText = r.recognizedWords);
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_userSpokenText.trim().isNotEmpty) _validateAnswer();
  }

  void _validateAnswer() {
    setState(() => _state = _GameState.validating);
    SemanticsService.announce('Validating your answer...', TextDirection.ltr);

    final spoken = _userSpokenText.toLowerCase();
    final keyword = _challengeKeyword.toLowerCase();

    if (!spoken.contains(keyword)) {
      setState(() {
        _isCorrect = false;
        _resultMessage =
            'The keyword "$_challengeKeyword" was not found in your Shloka. Try again next time!';
        _state = _GameState.result;
      });
      _tts.speak(_resultMessage);
      return;
    }

    // Try to match spoken text against dataset
    final verses = _allVerses;
    Verse? match;
    int bestScore = 0;

    for (final v in verses) {
      final combined = '${v.transliteration} ${v.translation}'.toLowerCase();
      int score = 0;
      for (final w in spoken.split(' ')) {
        if (w.length > 3 && combined.contains(w)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        match = v;
      }
    }

    final isCorrect = bestScore >= 2;

    if (isCorrect) {
      _score++;
      _matchedVerse = match;
    }

    setState(() {
      _isCorrect = isCorrect;
      _resultMessage = isCorrect
          ? 'Excellent! 🎉 Your Shloka matched! '
              '${match != null ? "Chapter ${match.chapter}, Verse ${match.verse}" : ""}'
          : 'Good attempt, but your reply did not clearly match a Bhagavad Gita verse. '
              'The keyword "$_challengeKeyword" was present, but try quoting a verse more precisely!';
      _state = _GameState.result;
    });

    _tts.speak(_resultMessage);
  }

  void _endGame() {
    setState(() {
      _resultMessage =
          'Game over! You scored $_score out of $_maxRounds rounds. '
          '${_score >= 4 ? "Magnificent! You are a true Gita scholar!" : _score >= 2 ? "Well done! Keep practicing." : "Keep studying the Gita — wisdom comes with practice."}';
      _state = _GameState.result;
      _currentAiraVerse = null;
    });
    _tts.speak(_resultMessage);
    SemanticsService.announce(_resultMessage, TextDirection.ltr);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_rounded, color: kGold),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Semantics(
          header: true,
          child: Text(
            'Shloka Antakshari',
            style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold, color: kGold, fontSize: 18),
          ),
        ),
        actions: [
          if (_round > 0)
            Semantics(
              label: 'Score: $_score out of $_round',
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'Score: $_score/$_round',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, color: kGold),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInstructions(isDark),
            const SizedBox(height: 16),
            Expanded(child: _buildGameBody(isDark)),
            const SizedBox(height: 16),
            _buildActionButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(bool isDark) {
    return Semantics(
      label: 'Game instructions',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kGold.withOpacity(isDark ? 0.08 : 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kGold.withOpacity(0.2)),
        ),
        child: Text(
          '🎵 Aira recites a Shloka, then gives you a keyword. '
          'Speak a Bhagavad Gita verse containing that keyword to score a point!',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.5,
            color: isDark ? kTextDim : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildGameBody(bool isDark) {
    switch (_state) {
      case _GameState.idle:
        return Center(
          child: Semantics(
            label: 'Press Start Game to begin the Shloka Antakshari game',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note_rounded,
                    size: 72, color: kGold.withOpacity(0.4)),
                const SizedBox(height: 16),
                Text(
                  'Tap "Start Game" to begin!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDark ? kTextDim : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );

      case _GameState.airaReciting:
        return _buildAiraCard(isDark);

      case _GameState.userTurn:
        return Column(
          children: [
            _buildAiraCard(isDark),
            const SizedBox(height: 16),
            _buildKeywordChip(isDark),
            const SizedBox(height: 16),
            _buildUserInput(isDark),
          ],
        );

      case _GameState.validating:
        return Center(
          child: Semantics(
            liveRegion: true,
            label: 'Validating your answer',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kGold),
                const SizedBox(height: 16),
                Text('Checking your Shloka...',
                    style: GoogleFonts.poppins(color: kGold)),
              ],
            ),
          ),
        );

      case _GameState.result:
        return _buildResultCard(isDark);
    }
  }

  Widget _buildAiraCard(bool isDark) {
    if (_currentAiraVerse == null) return const SizedBox.shrink();
    final v = _currentAiraVerse!;
    return Semantics(
      label:
          'Aira\'s Shloka: Chapter ${v.chapter}, Verse ${v.verse}. ${v.transliteration}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [kGold.withOpacity(0.10), kSaffron.withOpacity(0.06)]
                : [kGold.withOpacity(0.15), kSaffron.withOpacity(0.07)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: kGold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Aira recites — Ch.${v.chapter} V.${v.verse}',
                  style: GoogleFonts.cinzel(
                      color: kGold,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Semantics(
                  button: true,
                  label: 'Replay Aira\'s Shloka',
                  child: IconButton(
                    tooltip: 'Replay',
                    icon: const Icon(Icons.replay_rounded,
                        color: kGold, size: 18),
                    onPressed: () => _tts.speak(
                        v.transliteration.isNotEmpty
                            ? v.transliteration
                            : v.translation),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (v.sanskrit.isNotEmpty)
              Text(
                v.sanskrit,
                style: GoogleFonts.lora(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: isDark ? kGoldLight : kGoldDim,
                  height: 1.6,
                ),
              ),
            if (v.transliteration.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                v.transliteration,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? kTextDim : Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordChip(bool isDark) {
    return Semantics(
      label: 'Your challenge keyword is: $_challengeKeyword',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your keyword: ',
            style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? kTextDim : Colors.grey.shade600),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _challengeKeyword,
              style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput(bool isDark) {
    return Semantics(
      label: _isListening
          ? 'Listening — say your Shloka now'
          : 'Tap the microphone to speak your Shloka',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isListening ? Colors.red : kGold.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isListening ? Colors.red : kGold,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  _isListening ? 'Listening...' : 'Tap mic to speak',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _isListening ? Colors.red : kGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (_userSpokenText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _userSpokenText,
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? kText : Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Semantics(
            liveRegion: true,
            label: _resultMessage,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? kSuccess.withOpacity(isDark ? 0.15 : 0.1)
                    : kError.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _isCorrect ? kSuccess.withOpacity(0.4) : kError.withOpacity(0.4),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _isCorrect ? kSuccess : kError,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _resultMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? kText : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_matchedVerse != null) ...[
            const SizedBox(height: 12),
            _buildAiraCard(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    switch (_state) {
      case _GameState.idle:
        return Semantics(
          button: true,
          label: 'Start Antakshari game',
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Start Game',
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: _startGame,
          ),
        );

      case _GameState.airaReciting:
        return Semantics(
          label: 'Aira is reciting. Please wait.',
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kGold)),
                const SizedBox(width: 10),
                Text('Aira is reciting...',
                    style: GoogleFonts.poppins(color: kGold, fontSize: 14)),
              ],
            ),
          ),
        );

      case _GameState.userTurn:
        return Semantics(
          button: true,
          label: _isListening
              ? 'Stop speaking and submit your Shloka'
              : 'Speak your Shloka',
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isListening ? Colors.red : kGold,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded),
            label: Text(
              _isListening ? 'Submit Answer' : 'Speak Your Shloka',
              style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
        );

      case _GameState.validating:
        return const SizedBox.shrink();

      case _GameState.result:
        return Semantics(
          button: true,
          label: _round >= _maxRounds ? 'Play again' : 'Next round',
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: Icon(_round >= _maxRounds
                ? Icons.replay_rounded
                : Icons.arrow_forward_rounded),
            label: Text(
              _round >= _maxRounds ? 'Play Again' : 'Next Round',
              style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed:
                _round >= _maxRounds ? _startGame : _nextRound,
          ),
        );
    }
  }
}
