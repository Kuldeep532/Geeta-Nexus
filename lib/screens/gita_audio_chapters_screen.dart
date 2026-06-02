import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../audio/audio_streaming_state.dart';
import '../data/gita_data.dart';
import '../models/audio_source.dart';
import '../models/models.dart';
import '../theme.dart';
import 'audio_streaming_player_screen.dart';

/// Gita Audio Chapters Screen — with language filter and chapter selection.
/// All audio is streamed dynamically from verified network URLs.
/// No local audio assets are used.
class GitaAudioChaptersScreen extends StatefulWidget {
  const GitaAudioChaptersScreen({super.key});

  @override
  State<GitaAudioChaptersScreen> createState() =>
      _GitaAudioChaptersScreenState();
}

class _GitaAudioChaptersScreenState extends State<GitaAudioChaptersScreen> {
  AudioLanguage _selectedLanguage = AudioLanguage.sanskrit;
  final List<AudioLanguage> _languages = AudioLanguage.values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audio = context.watch<AudioStreamingState>();
    final source = sourceForLanguage(_selectedLanguage);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Gita Audio',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Language filter chips
          _buildLanguageFilter(theme),

          // Source info banner
          _buildSourceBanner(theme, source),

          // Chapter list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: kChapters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final chapter = kChapters[index];
                final isActive =
                    audio.currentChapterNumber == chapter.number &&
                        audio.currentSource?.language == _selectedLanguage;

                return _ChapterTile(
                  chapter: chapter,
                  isActive: isActive,
                  isPlaying: audio.isPlaying && isActive,
                  source: source,
                  onTap: () => _openPlayer(ctx, chapter.number, source),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageFilter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _languages.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final lang = _languages[i];
            final isSelected = lang == _selectedLanguage;
            return ChoiceChip(
              label: Text(lang.shortName),
              selected: isSelected,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                setState(() => _selectedLanguage = lang);
              },
              selectedColor: kGold,
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.3),
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : theme.colorScheme.onSurface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSourceBanner(ThemeData theme, AudioSource? source) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kGold.withOpacity(0.12),
              kSaffron.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kGold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.headphones_rounded, color: kGold, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                source != null
                    ? '${source.displayName} \u2022 Streaming online'
                    : 'Select a language to begin listening.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlayer(BuildContext ctx, int chapterNumber, AudioSource? source) {
    if (source == null) return;
    HapticFeedback.lightImpact();
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => AudioStreamingPlayerScreen(
          chapterNumber: chapterNumber,
          initialSource: source,
        ),
      ),
    );
  }
}

// ── Chapter tile ──

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final bool isActive;
  final bool isPlaying;
  final AudioSource? source;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.isActive,
    required this.isPlaying,
    required this.source,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label:
          'Chapter ${chapter.number}, ${chapter.name}. ${chapter.nameSanskrit}. '
          '${chapter.verses.length} verses. '
          '${isPlaying ? "Currently playing in ${source?.language.shortName ?? ""}." : "Double-tap to listen."}',
      child: Material(
        color: isActive
            ? kGold.withOpacity(0.12)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isActive ? kGold : kGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isActive && isPlaying
                        ? const Icon(Icons.volume_up_rounded,
                            color: Colors.black, size: 22)
                        : Center(
                            child: Text(
                              '${chapter.number}',
                              style: GoogleFonts.cinzel(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.black : kGold,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive ? kGold : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chapter.nameSanskrit,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${chapter.verses.length} verses',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: kGold.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(
                    isActive
                        ? (isPlaying
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded)
                        : Icons.play_circle_outline_rounded,
                    color: isActive
                        ? kGold
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                    size: 28,
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
