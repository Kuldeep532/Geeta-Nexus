import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/scripture_model.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'scripture_chapter_reader_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Semantics(
          button: true,
          label: 'Go back',
          hint: 'Returns to previous screen',
          child: BackButton(color: kGold),
        ),
        title: Semantics(
          header: true,
          child: Text(
            'Saved Verses',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: kGold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, child) {
            final bookmarkedList = state.bookmarkedVerses;

            if (bookmarkedList.isEmpty) {
              return Semantics(
                liveRegion: true,
                label: 'No saved verses found',
                child: _buildEmptyState(theme),
              );
            }

            return Semantics(
              container: true,
              liveRegion: true,
              explicitChildNodes: true,
              label:
                  'Bookmarks list containing ${bookmarkedList.length} saved verses. '
                  'Swipe left to remove a bookmark.',
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: bookmarkedList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (ctx, i) {
                  return _buildDismissibleCard(
                    context,
                    bookmarkedList[i],
                    i,
                    bookmarkedList.length,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(
    BuildContext context,
    ScriptureVerse verse,
    int index,
    int total,
  ) {
    final appState = Provider.of<AppState>(context, listen: false);

    final versePreview = verse.originalText
        .replaceAll('\n', ' ')
        .trim();

    final shortPreview = versePreview.length > 80
        ? '${versePreview.substring(0, 80)}...'
        : versePreview;

    return MergeSemantics(
      child: Semantics(
        container: true,
        button: true,
        enabled: true,
        label:
            'Saved verse ${verse.verseIndex}. '
            'Item ${index + 1} of $total. '
            '$shortPreview',
        hint:
            'Double tap to open verse details. Swipe left to remove bookmark.',
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScriptureChapterReaderScreen(
                chapterNumber: verse.section.sectionIndex,
                initialVerseNumber: verse.verseIndex,
              ),
            ),
          );
        },
        child: Dismissible(
          key: ValueKey('bookmark_${verse.verseIndex}'),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Remove Bookmark'),
                      content: Text(
                        'Are you sure you want to remove verse ${verse.verseIndex} from bookmarks?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(dialogContext).pop(false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(dialogContext).pop(true);
                          },
                          child: const Text('Remove'),
                        ),
                      ],
                    );
                  },
                ) ??
                false;
          },
          onDismissed: (_) {
            appState.toggleBookmark(verse);

            HapticFeedback.mediumImpact();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  'Verse ${verse.verseIndex} removed from bookmarks',
                  semanticsLabel:
                      'Verse ${verse.verseIndex} removed from bookmarks',
                ),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    appState.toggleBookmark(verse);
                  },
                ),
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScriptureChapterReaderScreen(
                      chapterNumber: verse.section.sectionIndex,
                      initialVerseNumber: verse.verseIndex,
                    ),
                  ),
                );
              },
              child: _verseCard(context, verse),
            ),
          ),
        ),
      ),
    );
  }

  Widget _verseCard(BuildContext context, ScriptureVerse verse) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kGold.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'VERSE ${verse.verseIndex}',
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ExcludeSemantics(
            child: Text(
              verse.originalText.replaceAll('\n', ' '),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Semantics(
      label: 'Delete bookmark',
      hint: 'Release to remove this saved verse',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Semantics(
        container: true,
        label:
            'No saved verses available. Bookmark verses to see them here.',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: kGold.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Saved Verses',
              style: theme.textTheme.titleMedium?.copyWith(
                color: kGold.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Bookmark your favorite verses to access them quickly later.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
