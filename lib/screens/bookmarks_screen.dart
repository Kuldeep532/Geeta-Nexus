import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart'; // Direct access to allVerses
import '../models/models.dart';
import '../models/scripture_model.dart';
import 'scripture_verse_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(
          'Saved Verses', 
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18, color: kGold)
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: const BackButton(color: kGold),
      ),
      body: Selector<AppState, List<Verse>>(
        selector: (context, state) {
          if (allVerses.isEmpty) return [];
          return allVerses.where((v) => state.isBookmarked(v.id)).toList();
        },
        builder: (context, bookmarkedList, child) {
          if (bookmarkedList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
            itemCount: bookmarkedList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (ctx, i) {
              final verse = bookmarkedList[i];
              return _buildDismissibleCard(context, verse);
            },
          );
        },
      ),
    );
  }

  Widget _buildDismissibleCard(BuildContext context, Verse verse) {
    final messenger = ScaffoldMessenger.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    return Dismissible(
      key: ValueKey('bookmark_${verse.id}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (direction) {
        appState.toggleBookmark(verse.id);
        
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: kCard,
            content: Text('Removed from bookmarks', style: TextStyle(color: kText)),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'UNDO',
              textColor: kGold,
              onPressed: () => appState.toggleBookmark(verse.id),
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScriptureVerseDetailScreen(
              allVerses: [ScriptureVerse.fromLocalVerse(verse)],
              initialIndex: 0,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: _verseCard(verse),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          Text('Remove', style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _verseCard(Verse verse) {
    final String sanskritPreview = verse.sanskrit.split('\n').first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(16),
        // FIXED: Removed the leading comma before kGold
        border: Border.all(color: kGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHAPTER ${verse.chapter} • VERSE ${verse.verse}',
                style: GoogleFonts.cinzel(
                  color: kGold, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: kGoldDim, size: 10),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sanskritPreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansDevanagari(
              color: kGoldLight, 
              fontSize: 16, 
              height: 1.5
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verse.translation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lora(
              color: kTextDim,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded, size: 60, color: kGold.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Saved Verses',
            style: GoogleFonts.cinzel(color: kGold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verses you bookmark will appear here.',
            style: TextStyle(color: kTextDim, fontSize: 14),
          ),
        ],
      ),
    );
  } // FIXED: Removed extra comma before final closing bracket
}
