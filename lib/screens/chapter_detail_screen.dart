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
    // 1. Fixed: Handling empty state properly
    if (chapter.name.isEmpty) {
      return const _ErrorStateWidget(message: "Chapter data not found");
    }

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: kBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: kGold, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Chapter ${chapter.number}',
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: _HeaderBackground(chapter: chapter),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChapterStats(chapter: chapter),
                  const SizedBox(height: 20),
                  _SummaryCard(summary: chapter.summary),
                  const SizedBox(height: 28),
                  Text(
                    'VERSES',
                    style: GoogleFonts.cinzel(
                      color: kGold,
                      fontSize: 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: kGoldDim, thickness: 0.5),
                  const SizedBox(height: 12),
                  _VerseList(verses: chapter.verses),
                  const SizedBox(height: 32),
                  _CompletionButton(chapterNumber: chapter.number),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final Chapter chapter;
  const _HeaderBackground({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A1F00), kBg],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                chapter.name,
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                chapter.nameSanskrit,
                style: GoogleFonts.notoSansDevanagari(
                  color: kGoldDim,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerseList extends StatelessWidget {
  final List<Verse> verses;
  const _VerseList({required this.verses});

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text("No verses found", style: TextStyle(color: kTextDim)),
        ),
      );
    }

    // 2. Fixed: shrinkWrap combined with NeverScrollableScrollPhysics for Slivers
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: verses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _VerseRowItem(verse: verses[index]),
    );
  }
}

class _VerseRowItem extends StatelessWidget {
  final Verse verse;
  const _VerseRowItem({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kDivider.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // 3. Fixed: Field names to match typical Gita API models (verse vs number)
        leading: CircleAvatar(
          backgroundColor: kBg,
          child: Text(
            '${verse.verseNumber}', 
            style: const TextStyle(color: kGold, fontSize: 12),
          ),
        ),
        title: Text(
          verse.translation.split('\n').first, // Clean preview
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.crimsonText(color: kText, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: kGoldDim, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerseDetailScreen(verse: verse),
            ),
          );
        },
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final int chapterNumber;
  const _CompletionButton({required this.chapterNumber});

  @override
  Widget build(BuildContext context) {
    // 4. Fixed: Removed syntax error (trailing comma and bracket issue)
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          foregroundColor: kBg,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          context.read<AppState>().markChapterComplete(chapterNumber);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chapter Marked as Completed!")),
          );
        },
        child: Text(
          "MARK AS COMPLETED",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}

// 5. Fixed: Added missing Stats and Summary Widget Logic
class _ChapterStats extends StatelessWidget {
  final Chapter chapter;
  const _ChapterStats({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(chapter.theme, Icons.auto_awesome),
        const SizedBox(width: 10),
        _pill('${chapter.verses.length} Verses', Icons.menu_book),
      ],
    );
  }

  Widget _pill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGoldDim.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGold, size: 14),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: kGold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: kGoldDim),
          Text(
            summary,
            style: GoogleFonts.crimsonText(
              color: kText,
              fontSize: 17,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  const _ErrorStateWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Text(message, style: const TextStyle(color: kGold)),
      ),
    );
  }
}
