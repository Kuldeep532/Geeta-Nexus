import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../audio/audio_state.dart';
import '../data/gita_data.dart';
import '../services/chapter_audio_service.dart';
import '../theme.dart';
import 'audio_player_screen.dart';

/// Isolated screen dedicated to listening to Bhagavad Gita chapter audio.
/// Completely independent from the text-reading flow.
class GitaAudioChaptersScreen extends StatelessWidget {
  const GitaAudioChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audio = context.watch<AudioState>();

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
          // Header info banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                      'Select a chapter to begin listening. Audio plays in the background.',
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
          ),

          // Chapter list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: kChapters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final chapter = kChapters[index];
                final isActive = audio.currentChapterNumber == chapter.number;

                return Semantics(
                  button: true,
                  label:
                      'Chapter ${chapter.number}, ${chapter.name}. ${chapter.nameSanskrit}. ${chapter.verses.length} verses. '
                      '${isActive ? (audio.isPlaying ? "Currently playing." : "Paused.") : "Double-tap to listen."}',
                  child: Material(
                    color: isActive
                        ? kGold.withOpacity(0.12)
                        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => AudioPlayerScreen(
                              chapterNumber: chapter.number,
                              initialReciter:
                                  audio.currentReciter ?? kAvailableReciters.first,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            // Chapter number badge
                            ExcludeSemantics(
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? kGold
                                      : kGold.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: isActive && audio.isPlaying
                                    ? const Icon(Icons.volume_up_rounded,
                                        color: Colors.black, size: 22)
                                    : Center(
                                        child: Text(
                                          '${chapter.number}',
                                          style: GoogleFonts.cinzel(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isActive
                                                ? Colors.black
                                                : kGold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Chapter titles
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
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.55),
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

                            // Play indicator
                            ExcludeSemantics(
                              child: Icon(
                                isActive
                                    ? (audio.isPlaying
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
