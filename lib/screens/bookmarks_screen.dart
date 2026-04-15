import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';
import '../models/models.dart';
import 'verse_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allVerses = getAllVerses();
    final bookmarked = allVerses
        .where((v) => state.isBookmarked(v.id))
        .toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        leading: const BackButton(),
      ),
      body: bookmarked.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarked.length,
              itemBuilder: (ctx, i) {
                final verse = bookmarked[i];
                return Dismissible(
                  key: Key(verse.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red.withOpacity(0.2),
                    child: const Icon(Icons.bookmark_remove, color: Colors.red),
                  ),
                  onDismissed: (_) => state.toggleBookmark(verse.id),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                            builder: (_) => VerseDetailScreen(verse: verse))),
                    child: _verseCard(verse),
                  ),
                );
              },
            ),
    );
  }

  Widget _verseCard(Verse verse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGoldDim.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark, color: kGold, size: 16),
              const SizedBox(width: 6),
              Text('Verse ${verse.id}',
                  style: GoogleFonts.cinzel(color: kGold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            verse.sanskrit.split('\n').first,
            style: GoogleFonts.notoSansDevanagari(
                color: kGoldLight, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 8),
          Text(
            '"${verse.translation}"',
            style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Wrap(
                spacing: 6,
                children: verse.keywords.take(2).map((k) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kDivider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(k,
                          style: const TextStyle(
                              color: kTextDim, fontSize: 10)),
                    )).toList(),
              ),
              const Spacer(),
              const Text('Swipe to remove',
                  style: TextStyle(color: kTextDim, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔖', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No Bookmarks Yet',
              style: GoogleFonts.cinzel(color: kGold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Bookmark verses while reading\nto find them here.',
            style: TextStyle(color: kTextDim, fontSize: 14, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
