import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/gita_data.dart';
import '../state/app_state.dart';
import 'chapter_detail_screen.dart';

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Uses the theme's background color for automatic light/dark support
      backgroundColor: theme.scaffoldBackgroundColor,
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
          final bool isCompleted = state.isChapterCompleted(chapter.number);

          return Semantics(
            label: "Chapter ${chapter.number}: ${chapter.name}. ${chapter.verseCount} verses. ${isCompleted ? 'Completed' : 'Not completed'}",
            button: true,
            hint: "Double tap to view chapter details",
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                // Use colorScheme for dynamic colors
                color: colorScheme.surface,
                elevation: 1,
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
                        color: isCompleted ? Colors.orangeAccent : theme.dividerColor,
                        width: isCompleted ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Decorative indicator hidden from screen readers to avoid clutter
                        ExcludeSemantics(
                          child: _buildChapterIndicator(
                            context,
                            chapter.number,
                            isCompleted,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                chapter.nameSanskrit,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildChapterMeta(context, chapter),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: theme.hintColor,
                          size: 20,
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Colors.orangeAccent.withOpacity(0.1)
            : Theme.of(context).dividerColor.withOpacity(0.1),
        border: Border.all(
          color: isCompleted ? Colors.orangeAccent : Theme.of(context).dividerColor,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.orangeAccent,
                size: 20,
              )
            : Text(
                '$number',
                style: GoogleFonts.cinzel(
                  color: colorScheme.onSurface,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              chapter.theme,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${chapter.verseCount} verses',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
