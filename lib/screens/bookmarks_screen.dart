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
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(
          'Saved Verses', 
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 20)
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        // UI Fix: BackButton color ensure karna
        leading: const BackButton(color: kGold),
      ),
      body: Selector<AppState, List<Verse>>(
        selector: (context, state) {
          // Logic: Filter verses
          final allVerses = getAllVerses(); // Ensure this is imported correctly
          return allVerses.where((v) => state.isBookmarked(v.id)).toList();
        },
        builder: (context, bookmarked, child) {
          if (bookmarked.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            // 80 padding niche di hai taaki FAB ya navigation bar se text na chupe
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
            itemCount: bookmarked.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (ctx, i) {
              final verse = bookmarked[i];
              // Key unique honi chahiye animation ke liye
              return _buildDismissibleCard(context, verse);
            },
          );
        },
      ),
    );
  }

  Widget _buildDismissibleCard(BuildContext context, Verse verse) {
    final messenger = ScaffoldMessenger.of(context);
    // listen: false zaroori hai function calls ke liye
    final appState = Provider.of<AppState>(context, listen: false);

    return Dismissible(
      key: ValueKey('bookmark_${verse.id}'), // More descriptive key
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) async => true,
      onDismissed: (direction) {
        appState.toggleBookmark(verse.id);
        
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Removed Verse ${verse.id}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: kGold,
              onPressed: () => appState.toggleBookmark(verse.id),
            ),
          ),
        );
      },
      child: Semantics(
        label: "Chapter ${verse.chapter} Verse ${verse.id}. Tap to read details.",
        button: true,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: verse)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: _verseCard(verse),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        // withAlpha ki jagah withOpacity zyada readable aur stable hai
        color: Colors.redAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_sweep, color: Colors.white, size: 28),
          Text('Remove', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _verseCard(Verse verse) {
    final sanskritText = (verse.sanskrit.isNotEmpty) 
        ? verse.sanskrit.split('\n').first 
        : 'Sanskrit text unavailable';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.9), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: kGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'CHAPTER ${verse.chapter} • VERSE ${verse.id}',
                    style: GoogleFonts.cinzel(
                      color: kGold, 
                      fontSize: 11, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: kTextDim, size: 12),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            sanskritText,
            style: GoogleFonts.notoSansDevanagari(
              color: kGoldLight, 
              fontSize: 16, 
              height: 1.6,
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 12),
          Text(
            verse.translation,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lora(
              color: kText.withOpacity(0.9),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 80, color: kGold.withOpacity(0.2)),
            const SizedBox(height: 20),
            Text(
              'Your spiritual library is empty',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(color: kGold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save your favorite verses for daily wisdom.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextDim, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
