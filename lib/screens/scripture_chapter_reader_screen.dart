import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/scripture_service.dart';
import '../theme.dart';

class ScriptureChapterReaderScreen extends StatefulWidget {
  final ScriptureChapterData chapter;

  const ScriptureChapterReaderScreen({super.key, required this.chapter});

  @override
  State<ScriptureChapterReaderScreen> createState() =>
      _ScriptureChapterReaderScreenState();
}

class _ScriptureChapterReaderScreenState
    extends State<ScriptureChapterReaderScreen> {
  final ScriptureService _service = ScriptureService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<ScriptureVerseData> _verses = [];
  List<ScriptureTranslationData> _translations = [];
  bool _loading = true;
  String? _error;

  PlayerState _playerState = PlayerState.stopped;
  int? _playingVerseNumber;
  bool _isChapterSummaryPlaying = false;
  String _liveAudioStatus = '';

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
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final chNum = widget.chapter.chapterNumber;
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
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onPlaybackComplete() {
    setState(() {
      _playingVerseNumber = null;
      _isChapterSummaryPlaying = false;
      _liveAudioStatus = 'Playback finished';
    });
    SemanticsService.announce('Playback finished', TextDirection.ltr);
  }

  Future<void> _playVerseAudio(int verse) async {
    final ch = widget.chapter.chapterNumber;
    final url = ScriptureService.verseRecitationUrl(ch, verse);
    final label = 'Now playing Chapter $ch, Verse $verse';

    if (_playerState == PlayerState.playing) {
      await _audioPlayer.stop();
      if (_playingVerseNumber == verse && !_isChapterSummaryPlaying) {
        setState(() { _playingVerseNumber = null; _liveAudioStatus = 'Stopped verse $verse'; });
        SemanticsService.announce('Stopped verse $verse', TextDirection.ltr);
        return;
      }
    }

    setState(() {
      _playingVerseNumber = verse;
      _isChapterSummaryPlaying = false;
      _liveAudioStatus = label;
    });
    SemanticsService.announce(label, TextDirection.ltr);
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _playingVerseNumber = null;
        _liveAudioStatus = 'Audio unavailable for verse $verse';
      });
      SemanticsService.announce(
          'Audio unavailable for verse $verse', TextDirection.ltr);
    }
  }

  Future<void> _playChapterSummaryAudio() async {
    final ch = widget.chapter.chapterNumber;
    final url = ScriptureService.chapterSummaryAudioUrl(ch);
    final label = 'Now playing chapter ${widget.chapter.nameTranslation} summary audio';

    if (_playerState == PlayerState.playing) {
      await _audioPlayer.stop();
      if (_isChapterSummaryPlaying) {
        setState(() { _isChapterSummaryPlaying = false; _liveAudioStatus = 'Chapter summary audio stopped'; });
        SemanticsService.announce('Chapter summary audio stopped', TextDirection.ltr);
        return;
      }
    }

    setState(() {
      _isChapterSummaryPlaying = true;
      _playingVerseNumber = null;
      _liveAudioStatus = label;
    });
    SemanticsService.announce(label, TextDirection.ltr);
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isChapterSummaryPlaying = false;
        _liveAudioStatus = 'Chapter summary audio unavailable';
      });
      SemanticsService.announce(
          'Chapter summary audio unavailable', TextDirection.ltr);
    }
  }

  Future<void> _pauseResumeAudio() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      const msg = 'Audio paused';
      setState(() => _liveAudioStatus = msg);
      SemanticsService.announce(msg, TextDirection.ltr);
    } else if (_playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      const msg = 'Audio resumed';
      setState(() => _liveAudioStatus = msg);
      SemanticsService.announce(msg, TextDirection.ltr);
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playingVerseNumber = null;
      _isChapterSummaryPlaying = false;
      _liveAudioStatus = 'Audio stopped';
    });
    SemanticsService.announce('Audio stopped', TextDirection.ltr);
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
    final ch = widget.chapter;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          label: 'Chapter ${ch.chapterNumber}: ${ch.nameTranslation}',
          child: Column(
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
        ),
        elevation: 0,
      ),
      body: _loading
          ? Semantics(
              label: 'Loading verses for chapter ${ch.chapterNumber}, please wait',
              child: const Center(child: CircularProgressIndicator(color: kGold)),
            )
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildAudioStatusRegion(),
                    _buildChapterHeader(isDark),
                    _buildFloatingAudioBar(theme, isDark),
                    Expanded(child: _buildVerseList(theme, isDark)),
                  ],
                ),
    );
  }

  Widget _buildAudioStatusRegion() {
    return Semantics(
      liveRegion: true,
      label: _liveAudioStatus,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildError() {
    return Semantics(
      label: 'Error loading verses. Tap retry to try again.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: kGoldDim),
              const SizedBox(height: 16),
              const Text('Could not load verses.\nCheck your connection and try again.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: 'Retry loading verses',
                child: ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterHeader(bool isDark) {
    final ch = widget.chapter;
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
                    Semantics(
                      header: true,
                      child: Text(
                        ch.name,
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kGold,
                        ),
                      ),
                    ),
                    Text(
                      ch.nameTransliterated,
                      style: GoogleFonts.lato(fontSize: 13, color: kGoldDim, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: _isChapterSummaryPlaying && _playerState == PlayerState.playing
                    ? 'Stop chapter summary audio'
                    : 'Play chapter summary audio for ${ch.nameTranslation}',
                child: IconButton(
                  onPressed: _playChapterSummaryAudio,
                  icon: Icon(
                    _isChapterSummaryPlaying && _playerState == PlayerState.playing
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_filled_rounded,
                    color: kGold,
                    size: 36,
                  ),
                  tooltip: _isChapterSummaryPlaying && _playerState == PlayerState.playing
                      ? 'Stop summary'
                      : 'Play summary audio',
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
          Text(
            '${ch.versesCount} verses',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAudioBar(ThemeData theme, bool isDark) {
    final isPlaying = _playerState == PlayerState.playing;
    final isPaused = _playerState == PlayerState.paused;
    final hasActive = isPlaying || isPaused;

    if (!hasActive) return const SizedBox.shrink();

    final label = _isChapterSummaryPlaying
        ? 'Chapter summary'
        : _playingVerseNumber != null
            ? 'Verse $_playingVerseNumber'
            : '';

    return Semantics(
      label: 'Audio player. Now playing: $label. ${isPlaying ? "Playing" : "Paused"}.',
      child: Container(
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
                isPlaying ? '♫  Playing: $label' : '⏸  Paused: $label',
                style: GoogleFonts.lato(color: kGold, fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Semantics(
              button: true,
              label: isPlaying ? 'Pause audio' : 'Resume audio',
              child: IconButton(
                onPressed: _pauseResumeAudio,
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: kGold),
                tooltip: isPlaying ? 'Pause' : 'Resume',
              ),
            ),
            Semantics(
              button: true,
              label: 'Stop audio',
              child: IconButton(
                onPressed: _stopAudio,
                icon: const Icon(Icons.stop_rounded, color: kGoldDim),
                tooltip: 'Stop',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseList(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: _verses.length,
      itemBuilder: (context, index) {
        final verse = _verses[index];
        final translation = _translationFor(verse.verseNumber);
        final isThisPlaying = _playerState == PlayerState.playing &&
            !_isChapterSummaryPlaying &&
            _playingVerseNumber == verse.verseNumber;

        return Semantics(
          container: true,
          label: 'Verse ${verse.verseNumber} of ${widget.chapter.chapterNumber}. '
              'Sanskrit text: ${verse.text.replaceAll('\n', ' ')}. '
              'Transliteration: ${verse.transliteration.replaceAll('\n', ' ')}. '
              '${translation.isNotEmpty ? "Translation: $translation." : ""}',
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isThisPlaying
                  ? kGold.withOpacity(0.08)
                  : theme.cardColor,
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
                      ExcludeSemantics(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.chapter.chapterNumber}.${verse.verseNumber}',
                            style: GoogleFonts.cinzel(fontSize: 12, color: kGold, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: isThisPlaying
                            ? 'Stop recitation of verse ${verse.verseNumber}'
                            : 'Play recitation of verse ${verse.verseNumber}',
                        child: IconButton(
                          onPressed: () => _playVerseAudio(verse.verseNumber),
                          icon: Icon(
                            isThisPlaying
                                ? Icons.stop_circle_rounded
                                : Icons.record_voice_over_rounded,
                            color: isThisPlaying ? kGold : kGoldDim,
                            size: 26,
                          ),
                          tooltip: isThisPlaying ? 'Stop verse audio' : 'Play verse recitation',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ExcludeSemantics(
                    child: Text(
                      verse.text.trim(),
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        height: 1.8,
                        fontStyle: FontStyle.italic,
                        color: isDark ? kText : null,
                      ),
                    ),
                  ),
                  if (verse.transliteration.trim().isNotEmpty) ...[
                    const Divider(height: 20, color: kDivider),
                    ExcludeSemantics(
                      child: Text(
                        verse.transliteration.trim(),
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          height: 1.6,
                          color: kGoldDim,
                        ),
                      ),
                    ),
                  ],
                  if (translation.isNotEmpty) ...[
                    const Divider(height: 20, color: kDivider),
                    ExcludeSemantics(
                      child: Text(
                        translation,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          height: 1.6,
                          color: isDark ? kTextDim : null,
                        ),
                      ),
                    ),
                  ],
                  if (verse.wordMeanings.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ExcludeSemantics(
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          'Word meanings',
                          style: GoogleFonts.lato(fontSize: 12, color: theme.hintColor),
                        ),
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
