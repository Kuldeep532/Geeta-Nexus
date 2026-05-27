import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/gita_data.dart' show kChapters;
import '../models/models.dart';
import '../services/scripture_service.dart';
import '../theme.dart';

class ScriptureChapterReaderScreen extends StatefulWidget {
  final ScriptureChapterData? chapter;
  final int? chapterNumber;
  final int? initialVerseNumber;

  const ScriptureChapterReaderScreen({
    super.key,
    this.chapter,
    this.chapterNumber,
    this.initialVerseNumber,
  }) : assert(chapter != null || chapterNumber != null);

  @override
  State<ScriptureChapterReaderScreen> createState() =>
      _ScriptureChapterReaderScreenState();
}

class _ScriptureChapterReaderScreenState
    extends State<ScriptureChapterReaderScreen> {
  final ScriptureService _service = ScriptureService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  ScriptureChapterData? _chapter;
  List<ScriptureVerseData> _verses = [];
  List<ScriptureTranslationData> _translations = [];
  bool _loading = true;
  String? _error;

  PlayerState _playerState = PlayerState.stopped;
  int? _playingVerseNumber;
  bool _isChapterSummaryPlaying = false;
  String _liveAudioStatus = '';

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
      if (state == PlayerState.completed) {
        _onPlaybackComplete();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (widget.chapter != null) {
        _chapter = widget.chapter;
      } else {
        final allChapters = await _service.fetchChapters();
        _chapter = allChapters.firstWhere(
          (c) => c.chapterNumber == widget.chapterNumber,
          orElse: () => allChapters.first,
        );
      }

      final chNum = _chapter!.chapterNumber;
      final allVerses = await _service.fetchVersesForChapter(chNum);
      final allTranslations = await _service.fetchTranslations();

      if (!mounted) return;
      setState(() {
        _verses = allVerses;
        _translations = allTranslations
            .where((t) => t.chapterNumber == chNum && t.language == 'en')
            .toList();
        _loading = false;
      });

      // Scroll to initial verse after frame
      if (widget.initialVerseNumber != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToVerse(widget.initialVerseNumber!);
        });
      }
    } catch (_) {
      // API failed — fall back to locally loaded CSV data
      _fallbackToLocalData();
    }
  }

  /// Convert locally loaded CSV verses into the types this reader expects.
  void _fallbackToLocalData() {
    final int targetNum = widget.chapter?.chapterNumber ?? widget.chapterNumber ?? 0;

    // Find chapter in local data
    Chapter? localChapter;
    if (targetNum > 0) {
      for (final ch in kChapters) {
        if (ch.number == targetNum) {
          localChapter = ch;
          break;
        }
      }
    }
    if (localChapter == null) {
      if (mounted) setState(() { _error = 'Chapter not found in local data'; _loading = false; });
      return;
    }

    // Convert local Chapter -> ScriptureChapterData
    _chapter = ScriptureChapterData(
      chapterNumber: localChapter.number,
      name: localChapter.nameSanskrit,
      nameTranslation: localChapter.name,
      nameTransliterated: '',
      nameMeaning: '',
      chapterSummary: localChapter.summary,
      chapterSummaryHindi: '',
      versesCount: localChapter.verses.length,
      imageName: '',
    );

    // Convert local Verse list -> ScriptureVerseData list
    _verses = localChapter.verses.map((v) => ScriptureVerseData(
      chapterNumber: v.chapter,
      verseNumber: v.verse,
      text: v.sanskrit,
      transliteration: v.transliteration,
      wordMeanings: v.meaning,
    )).toList();

    // Build translations from verse.translation
    _translations = localChapter.verses.map((v) => ScriptureTranslationData(
      chapterNumber: v.chapter,
      verseNumber: v.verse,
      authorName: 'English',
      description: v.translation,
      language: 'en',
    )).toList();

    if (mounted) {
      setState(() { _loading = false; _error = null; });
    }

    if (widget.initialVerseNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(widget.initialVerseNumber!);
      });
    }
  }

  void _scrollToVerse(int verseNumber) {
    final key = _verseKeys[verseNumber];
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _onPlaybackComplete() {
    setState(() {
      _playingVerseNumber = null;
      _isChapterSummaryPlaying = false;
      _liveAudioStatus = 'Playback finished';
    });
  }

  Future<void> _playVerseAudio(int verse) async {
    final ch = _chapter!.chapterNumber;
    final url = ScriptureService.verseRecitationUrl(ch, verse);

    if (_playerState == PlayerState.playing) {
      await _audioPlayer.stop();
      if (_playingVerseNumber == verse && !_isChapterSummaryPlaying) {
        setState(() { _playingVerseNumber = null; _liveAudioStatus = 'Stopped verse $verse'; });
        return;
      }
    }

    setState(() {
      _playingVerseNumber = verse;
      _isChapterSummaryPlaying = false;
      _liveAudioStatus = 'Now playing Chapter $ch, Verse $verse';
    });

    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _playingVerseNumber = null;
        _liveAudioStatus = 'Audio unavailable for verse $verse';
      });
    }
  }

  Future<void> _playChapterSummaryAudio() async {
    final ch = _chapter!.chapterNumber;
    final url = ScriptureService.chapterSummaryAudioUrl(ch);

    if (_playerState == PlayerState.playing) {
      await _audioPlayer.stop();
      if (_isChapterSummaryPlaying) {
        setState(() { _isChapterSummaryPlaying = false; _liveAudioStatus = 'Chapter summary audio stopped'; });
        return;
      }
    }

    setState(() {
      _isChapterSummaryPlaying = true;
      _playingVerseNumber = null;
      _liveAudioStatus = 'Now playing chapter ${_chapter!.nameTranslation} summary audio';
    });

    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isChapterSummaryPlaying = false;
        _liveAudioStatus = 'Chapter summary audio unavailable';
      });
    }
  }

  Future<void> _pauseResumeAudio() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      setState(() => _liveAudioStatus = 'Audio paused');
    } else if (_playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      setState(() => _liveAudioStatus = 'Audio resumed');
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playingVerseNumber = null;
      _isChapterSummaryPlaying = false;
      _liveAudioStatus = 'Audio stopped';
    });
  }

  String _translationFor(int verse) {
    final match = _translations.where((t) => t.verseNumber == verse);
    if (match.isNotEmpty) return match.first.description;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ch = _chapter;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: ch == null
            ? const Text('Chapter')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${ch.chapterNumber}',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold, fontSize: 16),
                  ),
                  Text(
                    ch.nameTranslation,
                    style: GoogleFonts.lato(color: kGoldDim, fontSize: 12),
                  ),
                ],
              ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildChapterHeader(isDark),
                    _buildFloatingAudioBar(theme),
                    Expanded(child: _buildVerseList(theme, isDark)),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: kGoldDim),
            const SizedBox(height: 16),
            const Text('Could not load verses.\nCheck your connection and try again.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterHeader(bool isDark) {
    final ch = _chapter!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ch.name,
                      style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: kGold),
                    ),
                    Text(
                      ch.nameTransliterated,
                      style: GoogleFonts.lato(fontSize: 13, color: kGoldDim, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _isChapterSummaryPlaying && _playerState == PlayerState.playing
                    ? 'Stop summary'
                    : 'Play summary audio',
                onPressed: _playChapterSummaryAudio,
                icon: Icon(
                  _isChapterSummaryPlaying && _playerState == PlayerState.playing
                      ? Icons.stop_circle_rounded
                      : Icons.play_circle_filled_rounded,
                  color: kGold,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ch.chapterSummary,
            style: GoogleFonts.lato(fontSize: 13, height: 1.5),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text('${ch.versesCount} verses', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFloatingAudioBar(ThemeData theme) {
    final isPlaying = _playerState == PlayerState.playing;
    final isPaused = _playerState == PlayerState.paused;
    final hasActive = isPlaying || isPaused;

    if (!hasActive) return const SizedBox.shrink();

    final label = _isChapterSummaryPlaying
        ? 'Chapter summary'
        : _playingVerseNumber != null
            ? 'Verse $_playingVerseNumber'
            : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGold.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isPlaying ? 'Playing: $label' : 'Paused: $label',
              style: GoogleFonts.lato(color: kGold, fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: isPlaying ? 'Pause' : 'Resume',
            onPressed: _pauseResumeAudio,
            icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: kGold),
          ),
          IconButton(
            tooltip: 'Stop',
            onPressed: _stopAudio,
            icon: const Icon(Icons.stop_rounded, color: kGoldDim),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseList(ThemeData theme, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: _verses.length,
      itemBuilder: (context, index) {
        final verse = _verses[index];
        final translation = _translationFor(verse.verseNumber);
        final isThisPlaying = _playerState == PlayerState.playing &&
            !_isChapterSummaryPlaying &&
            _playingVerseNumber == verse.verseNumber;

        _verseKeys.putIfAbsent(verse.verseNumber, () => GlobalKey());

        return Container(
          key: _verseKeys[verse.verseNumber],
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isThisPlaying ? kGold.withOpacity(0.08) : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isThisPlaying ? kGold.withOpacity(0.5) : kGold.withOpacity(0.12),
              width: isThisPlaying ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_chapter!.chapterNumber}.${verse.verseNumber}',
                        style: GoogleFonts.cinzel(fontSize: 12, color: kGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      tooltip: isThisPlaying ? 'Stop verse audio' : 'Play verse recitation',
                      onPressed: () => _playVerseAudio(verse.verseNumber),
                      icon: Icon(
                        isThisPlaying ? Icons.stop_circle_rounded : Icons.record_voice_over_rounded,
                        color: isThisPlaying ? kGold : kGoldDim,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Sanskrit text — accessible, NOT excluded
                Text(
                  verse.text.trim(),
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    height: 1.8,
                    fontStyle: FontStyle.italic,
                    color: isDark ? kText : null,
                  ),
                ),
                if (verse.transliteration.trim().isNotEmpty) ...[
                  const Divider(height: 20, color: kDivider),
                  Text(
                    verse.transliteration.trim(),
                    style: GoogleFonts.lato(fontSize: 13, height: 1.6, color: kGoldDim),
                  ),
                ],
                if (translation.isNotEmpty) ...[
                  const Divider(height: 20, color: kDivider),
                  Text(
                    translation,
                    style: GoogleFonts.lato(fontSize: 13, height: 1.6, color: isDark ? kTextDim : null),
                  ),
                ],
                if (verse.wordMeanings.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text('Word meanings', style: GoogleFonts.lato(fontSize: 12, color: theme.hintColor)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          verse.wordMeanings.trim(),
                          style: GoogleFonts.lato(fontSize: 12, height: 1.6, color: theme.hintColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
