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
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kChapters.length,
        itemBuilder: (context, index) {
          final chapter = kChapters[index];
          final isCompleted = state.isChapterCompleted(chapter.number);

          // FIX: Added Semantics for Screen Readers
          return Semantics(
            label: "Chapter ${chapter.number}: ${chapter.name}. ${isCompleted ? 'Completed' : 'Not completed'}",
            button: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChapterDetailScreen(chapter: chapter),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted ? kGoldDim : kDivider,
                        width: isCompleted ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildChapterIndicator(chapter.number, isCompleted),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.name,
                                maxLines: 1, // FIX: Prevents overflow
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: kText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                              Text(
                                chapter.nameSanskrit,
                                style: const TextStyle(color: kGoldDim, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              _buildChapterMeta(chapter),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: kTextDim, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChapterIndicator(int number, bool isCompleted) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? kGold.withOpacity(0.1) : kDivider.withOpacity(0.3),
        border: Border.all(color: isCompleted ? kGold : kDivider),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: kGold, size: 20)
            : Text(
                '$number',
                style: GoogleFonts.cinzel(
                    color: kGold, fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildChapterMeta(dynamic chapter) {
    return Row(
      children: [
        Flexible( // FIX: Prevents long theme names from pushing text off screen
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: kDivider,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              chapter.theme,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kGoldDim, fontSize: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${chapter.verseCount} verses',
          style: const TextStyle(color: kTextDim, fontSize: 11),
        ),
      ],
    );
  }
}
