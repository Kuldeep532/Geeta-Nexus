import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/gita_data.dart' show kChapters;
import '../models/models.dart';
import '../models/scripture_model.dart';
import '../services/scripture_service.dart';
import '../theme.dart';

/// Clean verse-by-verse reader — text only, no audio contamination.
///
/// Accessibility:
/// • Each verse element (number, Sanskrit, transliteration, translation,
///   word meanings) is a separate, individually focusable Semantics node.
/// • Horizontal swipe navigation uses spring physics for a natural feel.
/// • Fully functional Previous / Next buttons remain as alternative
///   accessibility touch targets.
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
  final PageController _pageController = PageController();

  ScriptureChapterData? _chapter;
  List<ScriptureVerseData> _verses = [];
  List<ScriptureTranslationData> _translations = [];
  bool _loading = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.chapter != null) {
        _chapter = widget.chapter;
      } else {
        final all = await _service.fetchChapters();
        _chapter = all.firstWhere(
          (c) => c.chapterNumber == widget.chapterNumber,
          orElse: () => all.first,
        );
      }

      final ch = _chapter!.chapterNumber;
      final allVerses = await _service.fetchVersesForChapter(ch);
      final allTranslations = await _service.fetchTranslations();

      if (!mounted) return;
      setState(() {
        _verses = allVerses;
        _translations = allTranslations
            .where((t) => t.chapterNumber == ch && t.language == 'en')
            .toList();
        _loading = false;
      });

      _jumpToInitialVerse();
    } catch (_) {
      _fallbackToLocalData();
    }
  }

  void _fallbackToLocalData() {
    final targetNum =
        widget.chapter?.chapterNumber ?? widget.chapterNumber ?? 0;
    Chapter? local;
    for (final ch in kChapters) {
      if (ch.number == targetNum) {
        local = ch;
        break;
      }
    }
    if (local == null) {
      if (mounted) {
        setState(() {
          _error = 'Chapter not found in local data';
          _loading = false;
        });
      }
      return;
    }

    _chapter = ScriptureChapterData(
      chapterNumber: local.number,
      name: local.nameSanskrit,
      nameTranslation: local.name,
      nameTransliterated: '',
      nameMeaning: '',
      chapterSummary: local.summary,
      chapterSummaryHindi: '',
      versesCount: local.verses.length,
      imageName: '',
    );

    _verses = local.verses
        .map((v) => ScriptureVerseData(
              chapterNumber: v.chapter,
              verseNumber: v.verse,
              text: v.sanskrit,
              transliteration: v.transliteration,
              wordMeanings: v.meaning,
            ))
        .toList();

    _translations = local.verses
        .map((v) => ScriptureTranslationData(
              chapterNumber: v.chapter,
              verseNumber: v.verse,
              authorName: 'English',
              description: v.translation,
              language: 'en',
            ))
        .toList();

    if (mounted) setState(() => _loading = false);
    _jumpToInitialVerse();
  }

  void _jumpToInitialVerse() {
    final initial = widget.initialVerseNumber;
    if (initial != null && initial > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(initial - 1);
          if (mounted) setState(() => _currentPage = initial - 1);
        }
      });
    }
  }

  String _translationFor(int verse) {
    final match = _translations.where((t) => t.verseNumber == verse);
    return match.isNotEmpty ? match.first.description : '';
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.elasticOut,
      );
    }
  }

  void _goToNext() {
    if (_currentPage < _verses.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.elasticOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ch = _chapter;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: ch == null
            ? Semantics(
                header: true,
                label: 'Chapter.',
                child: const Text('Chapter'))
            : Semantics(
                header: true,
                label:
                    'Chapter ${ch.chapterNumber}, ${ch.nameTranslation}.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter ${ch.chapterNumber}',
                      style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.bold,
                          color: kGold,
                          fontSize: 16),
                    ),
                    Text(
                      ch.nameTranslation,
                      style: GoogleFonts.lato(color: kGoldDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
      ),
      body: _loading
          ? Semantics(
              label: 'Loading verses, please wait.',
              child: const Center(
                  child: CircularProgressIndicator(color: kGold)))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildVerseIndicator(theme),
                    Expanded(
                        child: _buildPageView(theme, isDark)),
                    _buildNavBar(theme),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Semantics(
      label: 'Error loading verses.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.wifi_off_rounded,
                    size: 48, color: kGoldDim),
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load verses.\nCheck your connection and try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: 'Retry loading verses.',
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _loadData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      foregroundColor: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseIndicator(ThemeData theme) {
    return Semantics(
      label:
          'Verse ${_currentPage + 1} of ${_verses.length}. '
          'Swipe left or right to navigate between verses. '
          'Use the Previous and Next buttons below as alternatives.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Verse ${_currentPage + 1} of ${_verses.length}',
              style: GoogleFonts.cinzel(
                  fontSize: 12,
                  color: kGold,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView(ThemeData theme, bool isDark) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _verses.length,
      // Spring-like physics for swipe gestures — bounces naturally
      // on overscroll and snaps with an elastic feel.
      physics: const SpringPageScrollPhysics(),
      onPageChanged: (page) {
        HapticFeedback.selectionClick();
        setState(() => _currentPage = page);
      },
      itemBuilder: (ctx, i) {
        final verse = _verses[i];
        final translation = _translationFor(verse.verseNumber);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGold.withOpacity(0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Semantics(
                explicitChildNodes: true,
                label:
                    'Verse ${verse.verseNumber} of ${_verses.length}. '
                    'Swipe to navigate.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Verse number badge ─────────────────────────────
                    Semantics(
                      container: true,
                      label:
                          'Verse number: ${_chapter!.chapterNumber}.${verse.verseNumber}.',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_chapter!.chapterNumber}.${verse.verseNumber}',
                          style: GoogleFonts.cinzel(
                              fontSize: 12,
                              color: kGold,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Sanskrit text ────────────────────────────────────
                    Semantics(
                      container: true,
                      label:
                          'Sanskrit text: ${verse.text.trim().replaceAll('\n', ' ')}.',
                      child: Text(
                        verse.text.trim(),
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          height: 1.9,
                          fontStyle: FontStyle.italic,
                          color: isDark ? kText : null,
                        ),
                      ),
                    ),

                    // ── 3. Transliteration ────────────────────────────────
                    if (verse.transliteration.trim().isNotEmpty) ...[
                      const Divider(height: 24, color: kDivider),
                      Semantics(
                        container: true,
                        label:
                            'Transliteration: ${verse.transliteration.trim().replaceAll('\n', ' ')}.',
                        child: Text(
                          verse.transliteration.trim(),
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              height: 1.6,
                              color: kGoldDim),
                        ),
                      ),
                    ],

                    // ── 4. English translation ────────────────────────────
                    if (translation.isNotEmpty) ...[
                      const Divider(height: 24, color: kDivider),
                      Semantics(
                        container: true,
                        label: 'Translation: $translation.',
                        child: Text(
                          translation,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            height: 1.7,
                            color: isDark ? kTextDim : null,
                          ),
                        ),
                      ),
                    ],

                    // ── 5. Word meanings ────────────────────────────────
                    if (verse.wordMeanings.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Semantics(
                        container: true,
                        label:
                            'Word meanings: ${verse.wordMeanings.trim().replaceAll('\n', ' ')}. Double-tap to expand.',
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text('Word meanings',
                              style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: theme.hintColor)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                verse.wordMeanings.trim(),
                                style: GoogleFonts.lato(
                                    fontSize: 12,
                                    height: 1.6,
                                    color: theme.hintColor),
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
          ),
        );
      },
    );
  }

  /// Accessible Previous / Next navigation buttons with gold styling.
  Widget _buildNavBar(ThemeData theme) {
    final hasPrev = _currentPage > 0;
    final hasNext = _currentPage < _verses.length - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: kGold.withOpacity(0.12)),
          ),
        ),
        child: Row(
          children: [
            // Previous verse
            Expanded(
              child: Semantics(
                button: true,
                enabled: hasPrev,
                label: hasPrev
                    ? 'Go to previous verse, verse ${_currentPage}.'
                    : 'No previous verse. This is the first verse.',
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor:
                        hasPrev ? kGold : kGold.withOpacity(0.25),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: hasPrev ? _goToPrevious : null,
                  icon:
                      const Icon(Icons.arrow_back_ios_rounded, size: 16),
                  label: Text(
                    'Previous',
                    style:
                        GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Next verse
            Expanded(
              child: Semantics(
                button: true,
                enabled: hasNext,
                label: hasNext
                    ? 'Go to next verse, verse ${_currentPage + 2}.'
                    : 'No next verse. This is the last verse.',
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor:
                        hasNext ? kGold : kGold.withOpacity(0.25),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: hasNext ? _goToNext : null,
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16),
                  label: Text(
                    'Next',
                    style:
                        GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  iconAlignment: IconAlignment.end,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Spring Physics for PageView swipe ─────────────────────────────────────

/// Custom scroll physics that gives the PageView a natural spring-bounce
/// feel on overscroll and an elastic snap when settling on a page.
/// This benefits both touch gestures and accessibility navigation.
class SpringPageScrollPhysics extends ScrollPhysics {
  const SpringPageScrollPhysics({super.parent});

  @override
  SpringPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SpringPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 60,
        stiffness: 120,
        damping: 18,
      );

  @override
  double get minFlingVelocity => 80;

  @override
  double get maxFlingVelocity => 8000;

  @override
  double get dragStartDistanceMotionThreshold => 6;
}
