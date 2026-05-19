import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../models/scripture_model.dart';
import 'scripture_verse_detail_screen.dart';

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
        leading: BackButton(color: kGold),
        title: Text(
          'Saved Verses', 
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18, color: kGold)
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final bookmarkedList = state.bookmarkedVerses;

          if (bookmarkedList.isEmpty) {
            return Semantics(
              liveRegion: true,
              child: _buildEmptyState(theme),
            );
          }

          return Semantics(
            liveRegion: true,
            label: 'List of ${bookmarkedList.length} saved verses. Swipe left to delete.',
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              itemCount: bookmarkedList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) => _buildDismissibleCard(context, bookmarkedList[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissibleCard(BuildContext context, ScriptureVerse verse) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Dismissible(
      key: ValueKey('bookmark_${verse.verseIndex}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (direction) {
        appState.toggleBookmark(verse);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed verse ${verse.verseIndex} from bookmarks'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () => appState.toggleBookmark(verse),
            ),
          ),
        );
      },
      child: Semantics(
        button: true,
        label: 'Verse ${verse.verseIndex}. ${verse.originalText.substring(0, 20)}. Double tap to open details.',
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ScriptureVerseDetailScreen(allVerses: [verse], initialIndex: 0)),
          ),
          child: _verseCard(verse),
        ),
      ),
    );
  }

  Widget _verseCard(ScriptureVerse verse) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VERSE ${verse.verseIndex}', style: GoogleFonts.cinzel(color: kGold, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(verse.originalText.replaceAll('\n', ' '), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, semanticLabel: 'Delete Bookmark'),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 60, color: kGold.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No Saved Verses', style: TextStyle(color: kGold.withOpacity(0.5))),
        ],
      ),
    );
  }
}
