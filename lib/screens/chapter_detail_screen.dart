import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'verse_detail_screen.dart';

class ChapterDetailScreen extends StatelessWidget {
  final Chapter chapter;
  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kBg,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Chapter ${chapter.number}',
                style: GoogleFonts.cinzel(color: kGold, fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2A1F00), kBg],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        chapter.name,
                        style: GoogleFonts.cinzel(
                            color: kGold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        chapter.nameSanskrit,
                        style: const TextStyle(color: kGoldDim, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _pill(chapter.theme, Icons.auto_awesome),
                      const SizedBox(width: 10),
                      _pill('${chapter.verseCount} Verses', Icons.format_list_numbered),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kDivider),
                    ),
                    child: Text(
                      chapter.summary,
                      style: GoogleFonts.crimsonText(
                          color: kText, fontSize: 15, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Key Verses',
                    style: GoogleFonts.cinzel(
                        color: kGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...chapter.verses.map((verse) => _verseRow(context, verse, state)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        state.completeChapter(chapter.number);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chapter marked complete! +100 XP'),
                            backgroundColor: kCard,
                          ),
                        );
                      },
                      icon: state.isChapterCompleted(chapter.number)
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.check_circle_outline),
                      label: Text(state.isChapterCompleted(chapter.number)
                          ? 'Chapter Complete ✓'
                          : 'Mark as Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isChapterCompleted(chapter.number)
                            ? kGoldDim
                            : kGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kGold, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: kGold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _verseRow(BuildContext context, Verse verse, AppState state) {
    final isBookmarked = state.isBookmarked(verse.id);
    return GestureDetector(
      onTap: () {
        state.markVerseRead(verse.id);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => VerseDetailScreen(verse: verse)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDivider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.1),
                border: Border.all(color: kGoldDim),
              ),
              child: Center(
                child: Text('${verse.verse}',
                    style: GoogleFonts.cinzel(
                        color: kGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verse.translation,
                    style: const TextStyle(color: kText, fontSize: 13, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    verse.id,
                    style: const TextStyle(color: kTextDim, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? kGold : kTextDim,
                size: 20,
              ),
              onPressed: () => state.toggleBookmark(verse.id),
            ),
          ],
        ),
      ),
    );
  }
}
