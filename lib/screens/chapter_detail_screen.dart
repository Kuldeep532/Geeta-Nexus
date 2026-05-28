import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../audio/audio_state.dart';
import '../data/gita_data.dart' show kChapters;
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'aira_screen.dart';
import 'audio_player_screen.dart';
import 'scripture_chapter_reader_screen.dart';

/// Chapter Detail Screen — text and metadata only.
/// Audio is fully isolated: the dedicated Audio Player handles all playback.
class ChapterDetailScreen extends StatelessWidget {
  final Chapter chapter;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
  });

  void _openReader(BuildContext context, int verseIndex) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScriptureChapterReaderScreen(
          chapterNumber: chapter.number,
          initialVerseNumber: verseIndex + 1,
        ),
      ),
    );
  }

  void _openAudioPlayer(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioPlayerScreen(chapterNumber: chapter.number),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (chapter.name.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Chapter data not found')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Semantics(
        explicitChildNodes: true,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Collapsing header ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              systemOverlayStyle:
                  theme.brightness == Brightness.dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark,
              leading: Semantics(
                button: true,
                label: 'Go back',
                child: IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: kGold, size: 20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Semantics(
                  header: true,
                  child: Text(
                    'Chapter ${chapter.number}',
                    style: GoogleFonts.cinzel(
                        color: kGold, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                background: _HeaderBackground(chapter: chapter),
              ),
            ),

            // ── Body content ───────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    _ChapterStats(chapter: chapter),
                    const SizedBox(height: 20),

                    // Summary
                    _SummaryCard(summary: chapter.summary),
                    const SizedBox(height: 20),

                    // Listen button — opens dedicated audio player
                    _ListenButton(
                      onTap: () => _openAudioPlayer(context),
                    ),
                    const SizedBox(height: 28),

                    // Verses section header
                    Semantics(
                      header: true,
                      child: Text(
                        'VERSES',
                        style: GoogleFonts.cinzel(
                          color: kGold,
                          fontSize: 16,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(
                      color: kGold.withOpacity(0.3),
                      thickness: 0.6,
                    ),
                    const SizedBox(height: 12),

                    // Verse list — text only
                    _VerseList(
                      verses: chapter.verses,
                      chapterNumber: chapter.number,
                    ),
                    const SizedBox(height: 32),

                    // Mark complete button
                    _CompletionButton(chapterNumber: chapter.number),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Ask Aira FAB
      floatingActionButton: Semantics(
        button: true,
        label:
            'Ask Aira about Chapter ${chapter.number}: ${chapter.name}.',
        hint: 'Double-tap to open the AI assistant with this chapter as context.',
        child: FloatingActionButton.extended(
          heroTag: 'chapter_aira_fab',
          backgroundColor: kGold,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.support_agent_rounded),
          label: Text('Ask Aira',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          tooltip: 'Ask Aira about this chapter',
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AiraScreen(
                  contextShloka:
                      '${chapter.name} (Chapter ${chapter.number}): ${chapter.summary}',
                  contextVerse:
                      'Bhagavad Gita, Chapter ${chapter.number} — ${chapter.nameSanskrit}',
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Prev / Next chapter nav bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, -2),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            height: 58,
            child: _ChapterNavButtons(currentChapter: chapter.number),
          ),
        ),
      ),
    );
  }
}

// ── Header background ──────────────────────────────────────────────────────────

class _HeaderBackground extends StatelessWidget {
  final Chapter chapter;
  const _HeaderBackground({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kGold.withOpacity(0.22),
                isDark ? Colors.black : Colors.white,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 52),
              Semantics(
                header: true,
                label: 'Chapter title: ${chapter.name}.',
                child: Text(
                  chapter.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                      color: kGold, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Semantics(
                label: 'Sanskrit title: ${chapter.nameSanskrit}.',
                child: Text(
                  chapter.nameSanskrit,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansDevanagari(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Chapter stats ──────────────────────────────────────────────────────────────

class _ChapterStats extends StatelessWidget {
  final Chapter chapter;
  const _ChapterStats({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Verses',
            value: '${chapter.verses.length}',
            icon: Icons.menu_book_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Chapter',
            value: '${chapter.number}',
            icon: Icons.auto_stories,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value.',
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: kGold.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ExcludeSemantics(
                  child: Icon(icon, color: kGold, size: 28)),
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Chapter summary section.',
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: kGold.withOpacity(0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(summary,
              style: const TextStyle(fontSize: 15, height: 1.6)),
        ),
      ),
    );
  }
}

// ── Listen button (opens Audio Player) ────────────────────────────────────────

class _ListenButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ListenButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Listen to this chapter. Opens the audio player.',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.headphones_rounded, color: kGold),
          label: Text(
            'Listen to Chapter',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: kGold),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: BorderSide(color: kGold.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}

// ── Verse list ─────────────────────────────────────────────────────────────────

class _VerseList extends StatelessWidget {
  final List<Verse> verses;
  final int chapterNumber;
  const _VerseList({required this.verses, required this.chapterNumber});

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No verses available'),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: verses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _VerseRowItem(
        verse: verses[i],
        currentIndex: i,
        chapterNumber: chapterNumber,
      ),
    );
  }
}

class _VerseRowItem extends StatelessWidget {
  final Verse verse;
  final int currentIndex;
  final int chapterNumber;
  const _VerseRowItem(
      {required this.verse,
      required this.currentIndex,
      required this.chapterNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstLine = verse.translation.split('\n').first;

    return Semantics(
      button: true,
      label: 'Verse ${verse.verseNumber}. $firstLine.',
      hint: 'Double-tap to open full verse details.',
      child: Card(
        elevation: 0,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: kGold.withOpacity(0.2)),
        ),
        child: ListTile(
          minVerticalPadding: 14,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ExcludeSemantics(
            child: CircleAvatar(
              backgroundColor: kGold.withOpacity(0.1),
              child: Text('${verse.verseNumber}',
                  style: const TextStyle(color: kGold, fontSize: 12)),
            ),
          ),
          title: Text(
            firstLine,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.crimsonText(fontSize: 17, height: 1.4),
          ),
          trailing: const ExcludeSemantics(
            child: Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScriptureChapterReaderScreen(
                  chapterNumber: chapterNumber,
                  initialVerseNumber: currentIndex + 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Mark as completed button ───────────────────────────────────────────────────

class _CompletionButton extends StatelessWidget {
  final int chapterNumber;
  const _CompletionButton({required this.chapterNumber});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Mark chapter $chapterNumber as completed.',
      hint: 'Double-tap to save reading progress.',
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            context
                .read<AppState>()
                .markChapterComplete(chapterNumber.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                    'Chapter $chapterNumber marked as complete!'),
              ),
            );
          },
          child: Text(
            'MARK AS COMPLETED',
            style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Chapter prev / next navigation bar ────────────────────────────────────────

class _ChapterNavButtons extends StatelessWidget {
  final int currentChapter;
  const _ChapterNavButtons({required this.currentChapter});

  @override
  Widget build(BuildContext context) {
    final hasPrevious = currentChapter > 1;
    final hasNext = currentChapter < kChapters.length;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            enabled: hasPrevious,
            label: 'Go to previous chapter.',
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58)),
              onPressed: hasPrevious
                  ? () {
                      HapticFeedback.lightImpact();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterDetailScreen(
                              chapter: kChapters[currentChapter - 2]),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            enabled: hasNext,
            label: 'Go to next chapter.',
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58)),
              onPressed: hasNext
                  ? () {
                      HapticFeedback.lightImpact();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterDetailScreen(
                              chapter: kChapters[currentChapter]),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
            ),
          ),
        ),
      ],
    );
  }
}
