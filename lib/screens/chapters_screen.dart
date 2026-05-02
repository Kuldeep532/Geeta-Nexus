import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/gita_data.dart';
import '../state/app_state.dart';
import '../theme.dart'; // ERROR FIX: Theme file import ki gayi
import 'chapter_detail_screen.dart';

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('18 Chapters', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kChapters.length,
        itemBuilder: (context, index) {
          final chapter = kChapters[index];
          // AppState ke naye logic ke hisab se completion check
          final bool isCompleted = state.isChapterCompleted(chapter.number.toString());

          return Semantics(
            container: true,
            label: "Chapter ${chapter.number}: ${chapter.name}. ${chapter.verses.length} verses. ${isCompleted ? 'Completed' : 'Not completed'}",
            hint: 'Double tap to open chapter details',
            button: true,
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: theme.cardColor,
                elevation: 0,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterDetailScreen(chapter: chapter),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted ? kGold : theme.dividerColor.withOpacity(0.2),
                        width: isCompleted ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ExcludeSemantics(
                          child: _buildChapterIndicator(context, chapter.number, isCompleted),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExcludeSemantics(
                                child: Text(
                                chapter.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? kGold : null,
                                ),
                                ),
                              ),
                              ExcludeSemantics(
                                child: Text(
                                chapter.nameSanskrit,
                                style: TextStyle(
                                  color: kGold.withOpacity(0.8),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ExcludeSemantics(child: _buildChapterMeta(context, chapter)),
                            ],
                          ),
                        ),
                        ExcludeSemantics(
                          child: Icon(
                          Icons.chevron_right,
                          color: kGold.withOpacity(0.5),
                          size: 20,
                        ),
                        ),
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

  Widget _buildChapterIndicator(BuildContext context, int number, bool isCompleted) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? kGold.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: isCompleted ? kGold : Theme.of(context).dividerColor,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: kGold, size: 20)
            : Text(
                '$number',
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildChapterMeta(BuildContext context, dynamic chapter) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              chapter.theme,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${chapter.verses.length} verses',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
