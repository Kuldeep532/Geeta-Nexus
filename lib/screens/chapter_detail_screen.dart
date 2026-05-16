import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/gita_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart'; 
import '../models/scripture_model.dart';
import 'scripture_verse_detail_screen.dart';

// FIX: 'import' ko hatakar 'class' kiya gaya
class ChapterDetailScreen extends StatelessWidget {
  final Chapter chapter;
  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (chapter.name.isEmpty) {
      return const Scaffold(body: Center(child: Text("Chapter data not found")));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios, color: kGold, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Chapter ${chapter.number}',
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: _HeaderBackground(chapter: chapter),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChapterStats(chapter: chapter),
                  const SizedBox(height: 20),
                  _SummaryCard(summary: chapter.summary),
                  const SizedBox(height: 28),
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
                  Divider(color: kGold.withOpacity(0.3), thickness: 0.5),
                  const SizedBox(height: 12),
                  _VerseList(verses: chapter.verses),
                  const SizedBox(height: 32),
                  _CompletionButton(chapterNumber: chapter.number),
                  const SizedBox(height: 16),
                  _ChapterNavButtons(currentChapter: chapter.number),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final Chapter chapter;
  const _HeaderBackground({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kGold.withOpacity(0.2),
                isDark ? Colors.black : Colors.white,
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                chapter.name,
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                chapter.nameSanskrit,
                style: GoogleFonts.notoSansDevanagari(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerseList extends StatelessWidget {
  final List<Verse> verses;
  const _VerseList({required this.verses});

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return const Center(child: Text("No verses found"));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: verses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _VerseRowItem(
        verse: verses[index],
        allVerses: verses,
        currentIndex: index,
      ),
    );
  }
}

class _VerseRowItem extends StatelessWidget {
  final Verse verse;
  final List<Verse> allVerses;
  final int currentIndex;
  const _VerseRowItem({
    required this.verse,
    required this.allVerses,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Verse ${verse.verseNumber}',
      hint: 'Double tap to open verse details',
      child: Card(
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kGold.withOpacity(0.2)), // FIX: 'border' ko 'side' kiya
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kGold.withOpacity(0.1),
          child: Text('${verse.verseNumber}', style: const TextStyle(color: kGold, fontSize: 12)),
        ),
        title: Text(
          verse.translation.split('\n').first,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.crimsonText(fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScriptureVerseDetailScreen(
                allVerses: allVerses
                    .map((v) => ScriptureVerse.fromLocalVerse(v))
                    .toList(),
                initialIndex: currentIndex,
              ),
            ),
          );
        },
      ),
    ));
  }
}

class _CompletionButton extends StatelessWidget {
  final int chapterNumber;
  const _CompletionButton({required this.chapterNumber});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Mark chapter $chapterNumber as completed',
      child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          context.read<AppState>().markChapterComplete(chapterNumber.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Chapter $chapterNumber marked as complete!")),
          );
        },
        child: Text(
          "MARK AS COMPLETED",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    ));
  }
}

class _ChapterStats extends StatelessWidget {
  final Chapter chapter;
  const _ChapterStats({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(context, chapter.theme, Icons.auto_awesome),
        const SizedBox(width: 10),
        _pill(context, '${chapter.verses.length} Verses', Icons.menu_book),
      ],
    );
  }

  Widget _pill(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kGold, size: 14),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: kGold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ChapterNavButtons extends StatelessWidget {
  final int currentChapter;
  const _ChapterNavButtons({required this.currentChapter});

  @override
  Widget build(BuildContext context) {
    final previous = currentChapter > 1 ? kChapters[currentChapter - 2] : null;
    final next = currentChapter < kChapters.length ? kChapters[currentChapter] : null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: previous == null
                ? null
                : () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: previous)),
                    ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous Chapter'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: next == null
                ? null
                : () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: next)),
                    ),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next Chapter'),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget { // FIX: Extra comma hataya
  final String summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Chapter summary',
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: kGold),
          const SizedBox(height: 8),
          Text(
            summary,
            style: GoogleFonts.crimsonText(fontSize: 17, height: 1.5),
          ),
        ],
      ),
    ));
  }
}
