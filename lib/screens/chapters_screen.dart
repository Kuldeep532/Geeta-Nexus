import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/gita_data.dart';
import '../state/app_state.dart';
import 'chapter_detail_screen.dart';

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('18 Chapters'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kDivider),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kChapters.length,
        itemBuilder: (context, index) {
          final chapter = kChapters[index];
          final isCompleted = state.isChapterCompleted(chapter.number);
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChapterDetailScreen(chapter: chapter),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted ? kGoldDim : kDivider,
                  width: isCompleted ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? kGold.withOpacity(0.2)
                          : kDivider,
                      border: Border.all(
                          color: isCompleted ? kGold : kDivider),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: kGold, size: 20)
                          : Text(
                              '${chapter.number}',
                              style: GoogleFonts.cinzel(
                                  color: kGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.name,
                          style: const TextStyle(
                              color: kText,
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chapter.nameSanskrit,
                          style: const TextStyle(
                              color: kGoldDim, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: kDivider,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chapter.theme,
                                style: const TextStyle(
                                    color: kGoldDim, fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${chapter.verseCount} verses',
                              style: const TextStyle(
                                  color: kTextDim, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: kTextDim),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
