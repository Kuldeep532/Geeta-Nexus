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
    // Logic: Agar chapter data corrupt hai ya null hai
    if (chapter.name.isEmpty) {
      return const _ErrorStateWidget(message: "Chapter data not found");
    }

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kBg,
            flexibleSpace: FlexibleSpaceBar(
              title: Semantics(
                header: true,
                child: Text(
                  'Chapter ${chapter.number}',
                  style: GoogleFonts.cinzel(color: kGold, fontSize: 16, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 16),
                  _SummaryCard(summary: chapter.summary),
                  const SizedBox(height: 24),
                  Text(
                    'Key Verses',
                    style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _VerseList(verses: chapter.verses),
                  const SizedBox(height: 24),
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

// 1. Header Background with Placeholder logic
class _HeaderBackground extends StatelessWidget {
  final Chapter chapter;
  const _HeaderBackground({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A1F00), kBg],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              chapter.name,
              style: GoogleFonts.cinzel(color: kGold, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              chapter.nameSanskrit,
              style: const TextStyle(color: kGoldDim, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Separate Verse List with Error Handling
class _VerseList extends StatelessWidget {
  final List<Verse> verses;
  const _VerseList({required this.verses});

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons. find_in_page, color: kTextDim, size: 40),
            const SizedBox(height: 10),
            Text("No verses found for this chapter.", style: TextStyle(color: kTextDim)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: verses.length,
      itemBuilder: (context, index) => _VerseRowItem(verse: verses[index]),
    );
  }
}

// 3. Error UI Widget
class _ErrorStateWidget extends StatelessWidget {
  final String message;
  const _ErrorStateWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: kGold, size: 60),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: kText)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back", style: TextStyle(color: kGold)),
            )
          ],
        ),
      ),
    );
  }
}

// Stats Pill Component
class _ChapterStats extends StatelessWidget {
  final Chapter chapter;
  const _ChapterStats({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(chapter.theme, Icons.auto_awesome),
        const SizedBox(width: 10),
        _pill('${chapter.verseCount} Verses', Icons.format_list_numbered),
      ],
    );
  }

  Widget _pill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGold, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: kGold, fontSize: 12)),
        ],
      ),
    );
  }
}

// Summary Card Component
class _SummaryCard extends StatelessWidget {
  final String summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
      child: Text(
        summary,
        style: GoogleFonts.crimsonText(color: kText, fontSize: 15, height: 1.7),
      ),
    );
  }
}

// (Baki ke components _VerseRowItem aur _CompletionButton pehle wale code jaise hi rahenge)
