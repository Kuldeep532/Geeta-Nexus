import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/scripture_model.dart';
import '../services/scripture_repository.dart';
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
  final AudioPlayer _player = AudioPlayer();
  final ScriptureRepository _repo = ScriptureRepository();

  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _audioSearching = false;
  String? _resolvedAudioUrl;
  String _liveStatus = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

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
      if (!mounted) return;
      setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });

    _initAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  ScriptureVerse get _verse => widget.allVerses[_currentIndex];

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
    final clamped = d.isNegative ? Duration.zero : d;
    await _player.seek(clamped);
  }

  Future<void> _rewind10() => _seek(_position - const Duration(seconds: 10));
  Future<void> _forward30() => _seek(_position + const Duration(seconds: 30));

  void _navigateTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.allVerses.length) return;
    setState(() => _currentIndex = newIndex);
    _initAudio();

    final v = widget.allVerses[newIndex];
    SemanticsService.announce(
      '${v.section.displayLabel}, verse ${v.verseIndex}',
      TextDirection.ltr,
    );
  }

  void _copyVerse() {
    final v = _verse;
    final text = StringBuffer();
    text.writeln(v.originalText);
    if (v.translations.isNotEmpty) {
      text.writeln('\n— ${v.translations.values.first}');
    }
    Clipboard.setData(ClipboardData(text: text.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kGoldDim,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final v = _verse;

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
          _LiveStatusRegion(status: _liveStatus),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _VerseHeroCard(verse: v, isDark: isDark),
                  if (v.translations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _ExpandableSection(
                      title: v.translations.length == 1
                          ? 'Translation'
                          : 'Translations (${v.translations.length})',
                      icon: Icons.translate_rounded,
                      iconColor: kGold,
                      initiallyExpanded: true,
                      children: v.translations.entries.map((e) {
                        return _AuthoredBlock(
                          author: e.key,
                          text: e.value,
                          isDark: isDark,
                        );
                      }).toList(),
                    ),
                  ],
                  if (v.commentaries.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _ExpandableSection(
                      title: 'Commentaries (${v.commentaries.length})',
                      icon: Icons.library_books_rounded,
                      iconColor: kSaffron,
                      children: v.commentaries.entries.map((e) {
                        return _AuthoredBlock(
                          author: e.key,
                          text: e.value,
                          isDark: isDark,
                          accentColor: kSaffron,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SourceInfoCard(verse: v, isDark: isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_resolvedAudioUrl != null || _audioSearching)
            _AudioPlayerBar(
              isSearching: _audioSearching,
              resolvedUrl: _resolvedAudioUrl,
              playerState: _playerState,
              position: _position,
              duration: _duration,
              onPlayPause: _playPause,
              onRewind10: _rewind10,
              onForward30: _forward30,
              onSeek: _seek,
            ),
          _NavigationRow(
            currentIndex: _currentIndex,
            total: widget.allVerses.length,
            onPrev: () => _navigateTo(_currentIndex - 1),
            onNext: () => _navigateTo(_currentIndex + 1),
          ),
        ],
      ),
    );
  }
}

class _LiveStatusRegion extends StatelessWidget {
  final String status;
  const _LiveStatusRegion({required this.status});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: status,
      child: const SizedBox.shrink(),
    );
  }
}

class _VerseHeroCard extends StatelessWidget {
  final ScriptureVerse verse;
  final bool isDark;

  const _VerseHeroCard({required this.verse, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: verse.semanticsLabel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2A1F00), const Color(0xFF1A1500)]
                : [Colors.white, const Color(0xFFFFF9E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 12),
          ],
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VERSE ${verse.verseIndex}',
                    style: GoogleFonts.cinzel(
                        color: kGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                  if (verse.verseType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: kSaffron.withOpacity(0.12),
                        border: Border.all(
                            color: kSaffron.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        verse.verseType!,
                        style: GoogleFonts.notoSansDevanagari(
                            color: kSaffron,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                verse.originalText,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.9,
                  color: isDark ? kText : const Color(0xFF2A1F00),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(
          title,
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold, fontSize: 14, color: iconColor),
        ),
        iconColor: iconColor,
        collapsedIconColor: iconColor.withOpacity(0.5),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }
}

class _AuthoredBlock extends StatelessWidget {
  final String author;
  final String text;
  final bool isDark;
  final Color accentColor;

  const _AuthoredBlock({
    required this.author,
    required this.text,
    required this.isDark,
    this.accentColor = kGoldDim,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$author: $text',
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withOpacity(0.15)),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: GoogleFonts.crimsonText(
                    fontSize: 17,
                    height: 1.55,
                    color: isDark ? kText : const Color(0xFF2A1F00)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceInfoCard extends StatelessWidget {
  final ScriptureVerse verse;
  final bool isDark;

  const _SourceInfoCard({required this.verse, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[
      _InfoRow(label: 'Scripture', value: verse.sourceLabel),
      _InfoRow(label: 'Section', value: verse.section.label),
      if (verse.section.subLabel.isNotEmpty)
        _InfoRow(label: 'Sub-section', value: verse.section.subLabel),
      _InfoRow(label: 'Verse', value: '${verse.verseIndex}'),
      if (verse.verseType != null)
        _InfoRow(label: 'Verse type', value: verse.verseType!),
    ];

    return Semantics(
      label: rows.map((r) => '${r.label}: ${r.value}').join('. '),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.all(16),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SOURCE INFO',
                style: GoogleFonts.cinzel(
                    color: kGoldDim,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              ...rows.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text('${r.label}  ',
                            style: GoogleFonts.lato(
                                fontSize: 12,
                                color: kTextDim)),
                        Expanded(
                          child: Text(
                            r.value,
                            style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? kText : null),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}

class _AudioPlayerBar extends StatelessWidget {
  final bool isSearching;
  final String? resolvedUrl;
  final PlayerState playerState;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onRewind10;
  final VoidCallback onForward30;
  final ValueChanged<Duration> onSeek;

  const _AudioPlayerBar({
    required this.isSearching,
    required this.resolvedUrl,
    required this.playerState,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onRewind10,
    required this.onForward30,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = playerState == PlayerState.playing;
    final isPaused = playerState == PlayerState.paused;

    if (isSearching) {
      return Semantics(
        label: 'Searching for audio, please wait',
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGold.withOpacity(0.25)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(color: kGoldDim, strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Finding audio…',
                  style: TextStyle(color: kGoldDim, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    if (resolvedUrl == null) return const SizedBox.shrink();

    final safePosition = position > duration && duration > Duration.zero
        ? duration
        : position;

    return Semantics(
      label: 'Audio player. ${isPlaying ? "Playing" : isPaused ? "Paused" : "Ready to play"}.',
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProgressBar(
              progress: safePosition,
              total: duration > Duration.zero ? duration : const Duration(minutes: 10),
              onSeek: onSeek,
              progressBarColor: kGold,
              thumbColor: kGold,
              bufferedBarColor: kGold.withOpacity(0.25),
              baseBarColor: kGold.withOpacity(0.1),
              thumbRadius: 7,
              barHeight: 3.5,
              timeLabelLocation: TimeLabelLocation.sides,
              timeLabelTextStyle: const TextStyle(color: kGoldDim, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  button: true,
                  label: 'Rewind 10 seconds',
                  excludeSemantics: true,
                  child: IconButton(
                    onPressed: onRewind10,
                    icon: const Icon(Icons.replay_10_rounded, color: kGoldDim),
                    tooltip: 'Rewind 10s',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: isPlaying ? 'Pause audio' : 'Play audio',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onPlayPause,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: kGold.withOpacity(0.5)),
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: kGold,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Skip forward 30 seconds',
                  excludeSemantics: true,
                  child: IconButton(
                    onPressed: onForward30,
                    icon: const Icon(Icons.forward_30_rounded, color: kGoldDim),
                    tooltip: 'Forward 30s',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _NavigationRow({
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canPrev = currentIndex > 0;
    final canNext = currentIndex < total - 1;

    return SafeArea(
      top: false,
      child: Semantics(
        label: 'Verse navigation. Verse ${currentIndex + 1} of $total.',
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: kDivider.withOpacity(0.6)),
            ),
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                enabled: canPrev,
                label: canPrev
                    ? 'Previous verse, verse ${currentIndex}'
                    : 'No previous verse',
                excludeSemantics: true,
                child: _NavButton(
                  icon: Icons.chevron_left_rounded,
                  label: 'Prev',
                  enabled: canPrev,
                  onTap: canPrev ? onPrev : null,
                ),
              ),
              Expanded(
                child: Text(
                  '${currentIndex + 1} / $total',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                      color: kGoldDim,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Semantics(
                button: true,
                enabled: canNext,
                label: canNext
                    ? 'Next verse, verse ${currentIndex + 2}'
                    : 'No next verse',
                excludeSemantics: true,
                child: _NavButton(
                  icon: Icons.chevron_right_rounded,
                  label: 'Next',
                  enabled: canNext,
                  onTap: canNext ? onNext : null,
                  iconOnRight: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final bool iconOnRight;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? kGold : kGoldDim.withOpacity(0.35);
    final iconWidget = Icon(icon, color: color, size: 22);
    final textWidget = Text(
      label,
      style: GoogleFonts.lato(
          color: color, fontWeight: FontWeight.w600, fontSize: 13),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? kGold.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: enabled ? kGold.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: iconOnRight
              ? [textWidget, const SizedBox(width: 4), iconWidget]
              : [iconWidget, const SizedBox(width: 4), textWidget],
        ),
      ),
    );
  }
}
