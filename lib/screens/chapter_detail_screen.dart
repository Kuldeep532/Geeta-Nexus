import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'verse_detail_screen.dart';

class ChapterDetailScreen extends StatelessWidget {
  final Chapter chapter;
  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (chapter.name.isEmpty) {
      return const _ErrorStateWidget(message: "Chapter data not found");
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            leading: Semantics(
              label: "Back",
              button: true,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, 
                  color: colorScheme.primary, 
                  size: 20
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Chapter ${chapter.number}',
                style: GoogleFonts.cinzel(
                  color: colorScheme.primary,
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
                  Semantics(
                    header: true,
                    child: Text(
                      'VERSES',
                      style: GoogleFonts.cinzel(
                        color: colorScheme.primary,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color: colorScheme.outlineVariant, thickness: 0.5),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer.withOpacity(0.4),
                colorScheme.surface
              ],
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
                  color: colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                chapter.nameSanskrit,
                style: GoogleFonts.notoSansDevanagari(
                  color: colorScheme.onSurfaceVariant,
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
          child: Text("No verses found"),
        ),
      );
    }

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
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: "Verse ${verse.verseNumber}",
      button: true,
      child: Card(
        color: colorScheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Text(
              '${verse.verseNumber}', 
              style: TextStyle(color: colorScheme.primary, fontSize: 12),
            ),
          ),
          title: Text(
            verse.translation.split('\n').first,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.crimsonText(
              color: colorScheme.onSurface, 
              fontSize: 16
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, 
            color: colorScheme.onSurfaceVariant, 
            size: 14
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerseDetailScreen(verse: verse),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final int chapterNumber;
  const _CompletionButton({required this.chapterNumber});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: "Mark chapter $chapterNumber as completed",
        button: true,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            context.read<AppState>().markChapterComplete(chapterNumber);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Chapter $chapterNumber Marked as Completed!")),
            );
          },
          child: Text(
            "MARK AS COMPLETED",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}

class _ChapterStats extends StatelessWidget {
  final Chapter chapter;
  const _ChapterStats({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(context, chapter.theme, Icons.auto_awesome),
        const SizedBox(width: 10),
        _pill(context, '${chapter.verses.length} Verses', Icons.menu_book),
      ],
    );
  }

  Widget _pill(BuildContext context, String text, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary, size: 14),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: colorScheme.primary, fontSize: 12)),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: "Chapter Summary",
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              summary,
              style: GoogleFonts.crimsonText(
                color: colorScheme.onSurface,
                fontSize: 17,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  const _ErrorStateWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Text(message, style: TextStyle(color: colorScheme.error)),
      ),
    );
  }
}
