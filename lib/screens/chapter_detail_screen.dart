import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/gita_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart'; 
import '../models/scripture_model.dart';
import 'scripture_verse_detail_screen.dart';

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
              tooltip: 'Back to library',
              icon: const Icon(Icons.arrow_back_ios, color: kGold, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Semantics(
                header: true,
                label: 'Chapter ${chapter.number} Detail Page',
                child: Text(
                  'Chapter ${chapter.number}',
                  style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    label: 'Verses List Section',
                    excludeSemantics: true,
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
                  // NOTE: Yahan se nav buttons ko hata kar bottomNavigationBar mein shift kar diya hai
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // FIXED: Buttons ko bottom mein permanent fix kar diya taaki accessible rahein
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
          child: _ChapterNavButtons(currentChapter: chapter.number),
        ),
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
              Semantics(
                label: 'Chapter Title: ${chapter.name}. Sanskrit: ${chapter.nameSanskrit}',
                excludeSemantics: true,
                child: Column(
                  children: [
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
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kGold.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Semantics(
          label: 'Chapter Summary: $summary',
          child: Text(
            summary,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ),
      ),
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
    final String firstLine = verse.translation.split('\n').first;

    return Semantics(
      button: true,
      label: 'Verse number ${verse.verseNumber}. Text snippet: $firstLine',
      hint: 'Double tap to view full sanskrit verse, translation, and commentary',
      excludeSemantics: true,
      child: Card(
        color: theme.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: kGold.withOpacity(0.2)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: kGold.withOpacity(0.1),
            child: Text('${verse.verseNumber}', style: const TextStyle(color: kGold, fontSize: 12)),
          ),
          title: Text(
            firstLine,
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
      ),
    );
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
      hint: 'Double tap to save progress for this chapter',
      excludeSemantics: true,
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
      ),
    );
  }
}

class _ChapterStats extends StatelessWidget {
  final Chapter chapter;
  const _ChapterStats({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chapter meta information. Theme is ${chapter.theme} and contains ${chapter.verses.length} verses',
      excludeSemantics: true,
      child: Row(
        children: [
          _pill(context, chapter.theme, Icons.auto_awesome),
          const SizedBox(width: 10),
          _pill(context, '${chapter.verses.length} Verses', Icons.menu_book),
        ],
      ),
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
          child: Semantics(
            button: true,
            label: 'Go to Previous Chapter',
            hint: previous == null ? 'Disabled, this is the first chapter' : 'Double tap to open chapter ${currentChapter - 1}',
            enabled: previous != null,
            child: OutlinedButton.icon(
              onPressed: previous == null
                  ? null
                  : () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: previous)),
                      ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Go to Next Chapter',
            hint: next == null ? 'Disabled, this is the final chapter' : 'Double tap to open chapter ${currentChapter + 1}',
            enabled: next != null,
            child: ElevatedButton.icon(
              onPressed: next == null
                  ? null
                  : () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: next)),
                      ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
