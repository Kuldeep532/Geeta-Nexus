import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/scripture_sources.dart';
import '../models/scripture_model.dart';
import '../services/scripture_service.dart';
import '../theme.dart';

import 'scripture_chapter_reader_screen.dart';
import 'scripture_dharmicdata_verse_list_screen.dart';
import 'scripture_upanishads_screen.dart';
import 'chapters_screen.dart';

/// Redesigned Scripture Library — top-level categories only on the main screen.
/// Tapping a category opens a custom bottom sheet with texts in that category.
/// Clean, minimal, and handles 40+ sources without clutter.
class ScriptureLibraryScreen extends StatelessWidget {
  const ScriptureLibraryScreen({super.key});

  void _openCategory(BuildContext context, ScriptureCategory cat) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategorySheet(category: cat),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Semantics(
          header: true,
          namesRoute: true,
          label: 'Scripture Library',
          child: Text(
            'Scripture Library',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              color: isDark ? kGold : kGoldDim,
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: kScriptureCatalog.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (ctx, index) {
          final cat = kScriptureCatalog[index];
          return _CategoryCard(
            category: cat,
            onTap: () => _openCategory(ctx, cat),
          );
        },
      ),
    );
  }
}

// ── Category Card (main screen) ───────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final ScriptureCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label:
          '${category.title}. ${category.subtitle.replaceAll('•', ',')}. '
          '${category.texts.length} texts available. Double-tap to explore.',
      hint: 'Opens a list of texts in this category.',
      child: Material(
        color: isDark
            ? category.accent.withOpacity(0.08)
            : category.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Category icon
                ExcludeSemantics(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: category.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.accent,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? kGold : kGoldDim,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.4,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text count chip
                      ExcludeSemantics(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: category.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${category.texts.length} texts',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: category.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category Bottom Sheet (text list) ──────────────────────────────────────

class _CategorySheet extends StatelessWidget {
  final ScriptureCategory category;

  const _CategorySheet({required this.category});

  void _openText(BuildContext context, ScriptureTextDef text) {
    HapticFeedback.lightImpact();
    Navigator.pop(context); // close sheet

    // Route to the appropriate reader based on text type
    switch (text.type) {
      case ScriptureTextType.chapterVerse:
      case ScriptureTextType.mixed:
        if (text.id == 'gita') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChaptersScreen()),
          );
        } else {
          // For other chapter-verse texts, show a placeholder
          _showComingSoon(context, text.title);
        }
        break;
      case ScriptureTextType.sectionVerse:
        if (text.id == 'ramayana_valmiki') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChaptersScreen(),
            ),
          );
        } else {
          _showComingSoon(context, text.title);
        }
        break;
      case ScriptureTextType.verseList:
        if (text.id == 'upanishads') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScriptureUpanishadsScreen(
                name: text.title,
                verses: const [],
              ),
            ),
          );
        } else {
          _showComingSoon(context, text.title);
        }
        break;
    }
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('$title is coming soon in a future update.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '${category.title} texts. ${category.texts.length} texts listed.',
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Sheet header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(category.icon,
                          color: category.accent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          category.title,
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Close',
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                indent: 20,
                endIndent: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),

              // Text list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: category.texts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final text = category.texts[i];
                    return _TextTile(
                      text: text,
                      accent: category.accent,
                      onTap: () => _openText(ctx, text),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextTile extends StatelessWidget {
  final ScriptureTextDef text;
  final Color accent;
  final VoidCallback onTap;

  const _TextTile({
    required this.text,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String countLabel = '';
    if (text.knownChapterCount != null) {
      countLabel = '${text.knownChapterCount} chapters';
    } else if (text.knownVerseCount != null) {
      countLabel = '${text.knownVerseCount} verses';
    }

    return Semantics(
      button: true,
      label:
          '${text.title}. ${text.devanagariTitle.isNotEmpty ? text.devanagariTitle + ". " : ""}'
          '${text.subtitle}. ${countLabel.isNotEmpty ? countLabel + ". " : ""}'
          'Double-tap to open.',
      hint: 'Opens the reader for this text.',
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(text.icon, color: accent, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              text.title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (text.audioBaseUrl != null)
                            ExcludeSemantics(
                              child: Icon(
                                Icons.headphones_outlined,
                                size: 16,
                                color: accent.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        text.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                      if (countLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ExcludeSemantics(
                          child: Text(
                            countLabel,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: accent.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
