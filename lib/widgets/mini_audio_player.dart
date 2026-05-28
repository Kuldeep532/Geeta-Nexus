import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../audio/audio_state.dart';
import '../screens/audio_player_screen.dart';
import '../theme.dart';

/// Persistent mini audio player bar that floats above the bottom nav bar
/// whenever a chapter is loaded.  Tapping it opens the full AudioPlayerScreen.
class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioState>(
      builder: (context, audio, _) {
        // Only show when we have a track loaded
        final visible = audio.hasTrack;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
          child: visible
              ? KeyedSubtree(
                  key: const ValueKey('mini_player'),
                  child: _MiniPlayerBar(audio: audio, fmt: _fmt),
                )
              : const SizedBox.shrink(key: ValueKey('hidden')),
        );
      },
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  final AudioState audio;
  final String Function(Duration) fmt;

  const _MiniPlayerBar({required this.audio, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = audio.progress;
    final chapter = audio.currentChapterNumber ?? 0;
    final reciter = audio.currentReciterName;

    return Semantics(
      container: true,
      label:
          'Now playing: Chapter $chapter, $reciter. ${audio.isPlaying ? "Playing." : "Paused."} '
          'Tap to open full player.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerScreen(chapterNumber: chapter),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1500) : const Color(0xFFFFFAEA),
            border: Border(
              top: BorderSide(color: kGold.withOpacity(0.25)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thin progress bar
              ExcludeSemantics(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: kGold.withOpacity(0.12),
                  color: kGold,
                ),
              ),

              // Content row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                child: Row(
                  children: [
                    // Om icon
                    ExcludeSemantics(
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kGold.withOpacity(0.12),
                          border:
                              Border.all(color: kGold.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Text(
                            'ॐ',
                            style: TextStyle(
                              fontSize: 18,
                              color: kGold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Track info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chapter $chapter',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kGold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            reciter.isNotEmpty
                                ? reciter
                                : 'Bhagavad Gita',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.55),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Time
                    ExcludeSemantics(
                      child: Text(
                        fmt(audio.position),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Rewind 10
                    Semantics(
                      button: true,
                      label: 'Rewind 10 seconds',
                      child: _MiniIconButton(
                        icon: Icons.replay_10_rounded,
                        size: 22,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          audio.rewind();
                        },
                      ),
                    ),

                    // Play / Pause
                    Semantics(
                      button: true,
                      label: audio.isPlaying ? 'Pause' : 'Play',
                      child: _MiniIconButton(
                        icon: audio.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        size: 34,
                        color: kGold,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          audio.togglePlay();
                        },
                      ),
                    ),

                    // Forward 10
                    Semantics(
                      button: true,
                      label: 'Forward 10 seconds',
                      child: _MiniIconButton(
                        icon: Icons.forward_10_rounded,
                        size: 22,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          audio.fastForward();
                        },
                      ),
                    ),

                    // Stop / dismiss
                    Semantics(
                      button: true,
                      label: 'Stop and dismiss player',
                      child: _MiniIconButton(
                        icon: Icons.close_rounded,
                        size: 18,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          audio.stop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final VoidCallback onPressed;

  const _MiniIconButton({
    required this.icon,
    required this.onPressed,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: size,
        color: color ?? theme.colorScheme.onSurface.withOpacity(0.75),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      visualDensity: VisualDensity.compact,
    );
  }
}
