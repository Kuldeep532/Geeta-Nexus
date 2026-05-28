import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../audio/audio_state.dart';
import '../services/chapter_audio_service.dart';
import '../theme.dart';

/// Full-screen dedicated audio player for Bhagavad Gita chapter narrations.
/// Opened from GitaAudioChaptersScreen or any "Listen" action in the app.
class AudioPlayerScreen extends StatefulWidget {
  final int chapterNumber;
  final AudioReciter? initialReciter;

  const AudioPlayerScreen({
    super.key,
    required this.chapterNumber,
    this.initialReciter,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioState _audio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio = context.read<AudioState>();
      final reciter =
          widget.initialReciter ?? _audio.currentReciter ?? kAvailableReciters.first;
      if (_audio.currentChapterNumber != widget.chapterNumber ||
          _audio.currentReciter?.id != reciter.id) {
        _audio.play(widget.chapterNumber, reciter);
      }
    });
  }

  void _showReciterPicker(BuildContext ctx, AudioState audio) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: ctx,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Select Reciter',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kGold,
                  ),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              ...kAvailableReciters.map((r) => ListTile(
                    leading: Icon(
                      audio.currentReciter?.id == r.id
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: kGold,
                    ),
                    title: Text(r.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text('${r.language} · ${r.accent}'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      audio.play(widget.chapterNumber, r);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AudioState>(
      builder: (context, audio, _) {
        final chapter = audio.currentChapterNumber ?? widget.chapterNumber;
        final reciterName =
            audio.currentReciterName.isNotEmpty ? audio.currentReciterName : 'Select Reciter';
        final position = audio.position;
        final duration = audio.duration;
        final progress = audio.progress;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: Semantics(
              button: true,
              label: 'Go back',
              child: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kGold, size: 28),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
            title: Text(
              'Now Playing',
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Om / Album Art
                Semantics(
                  image: true,
                  label: 'Bhagavad Gita audio player',
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isDark
                            ? [kGold.withOpacity(0.3), kSurface]
                            : [kGold.withOpacity(0.25), const Color(0xFFFFF1CE)],
                      ),
                      border: Border.all(color: kGold.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'ॐ',
                        style: TextStyle(
                          fontSize: 80,
                          color: kGold,
                          fontFamily: 'NotoSansDevanagari',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Chapter info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Semantics(
                    header: true,
                    label: 'Chapter $chapter. Reciter: $reciterName.',
                    child: Column(
                      children: [
                        Text(
                          'Chapter $chapter',
                          style: GoogleFonts.cinzel(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: kGold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bhagavad Gita',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Reciter chip — tappable
                        Semantics(
                          button: true,
                          label: 'Current reciter: $reciterName. Double-tap to change.',
                          child: GestureDetector(
                            onTap: () => _showReciterPicker(context, audio),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: kGold.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kGold.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.mic_rounded,
                                      color: kGold, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    reciterName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: kGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down_rounded,
                                      color: kGold, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Semantics(
                        slider: true,
                        label:
                            'Playback progress. ${_formatDuration(position)} of ${_formatDuration(duration)}.',
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: kGold,
                            inactiveTrackColor: kGold.withOpacity(0.2),
                            thumbColor: kGold,
                            overlayColor: kGold.withOpacity(0.15),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: progress,
                            onChanged: duration.inSeconds > 0
                                ? (v) {
                                    final target = Duration(
                                        milliseconds:
                                            (v * duration.inMilliseconds).round());
                                    audio.seekTo(target);
                                  }
                                : null,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Main controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous chapter
                      Semantics(
                        button: true,
                        enabled: audio.canGoPrev,
                        label: 'Previous chapter',
                        child: IconButton(
                          tooltip: 'Previous chapter',
                          iconSize: 36,
                          onPressed: audio.canGoPrev
                              ? () {
                                  HapticFeedback.lightImpact();
                                  audio.prevChapter();
                                }
                              : null,
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: audio.canGoPrev
                                ? kGold
                                : kGold.withOpacity(0.3),
                          ),
                        ),
                      ),

                      // Rewind 10s
                      Semantics(
                        button: true,
                        label: 'Rewind 10 seconds',
                        child: IconButton(
                          tooltip: 'Rewind 10 seconds',
                          iconSize: 32,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            audio.rewind();
                          },
                          icon: const Icon(Icons.replay_10_rounded, color: kGold),
                        ),
                      ),

                      // Play / Pause — large central button
                      Semantics(
                        button: true,
                        label: audio.isPlaying ? 'Pause' : 'Play',
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if (audio.hasTrack) {
                              audio.togglePlay();
                            } else {
                              audio.play(
                                widget.chapterNumber,
                                kAvailableReciters.first,
                              );
                            }
                          },
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kGold,
                              boxShadow: [
                                BoxShadow(
                                  color: kGold.withOpacity(0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              audio.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 36,
                            ),
                          ),
                        ),
                      ),

                      // Forward 10s
                      Semantics(
                        button: true,
                        label: 'Forward 10 seconds',
                        child: IconButton(
                          tooltip: 'Forward 10 seconds',
                          iconSize: 32,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            audio.fastForward();
                          },
                          icon: const Icon(Icons.forward_10_rounded, color: kGold),
                        ),
                      ),

                      // Next chapter
                      Semantics(
                        button: true,
                        enabled: audio.canGoNext,
                        label: 'Next chapter',
                        child: IconButton(
                          tooltip: 'Next chapter',
                          iconSize: 36,
                          onPressed: audio.canGoNext
                              ? () {
                                  HapticFeedback.lightImpact();
                                  audio.nextChapter();
                                }
                              : null,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: audio.canGoNext
                                ? kGold
                                : kGold.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Change reciter button
                Semantics(
                  button: true,
                  label: 'Change reciter',
                  child: TextButton.icon(
                    onPressed: () => _showReciterPicker(context, audio),
                    icon: const Icon(Icons.person_search_rounded,
                        color: kGold, size: 18),
                    label: Text(
                      'Change Reciter',
                      style: GoogleFonts.poppins(color: kGold, fontSize: 13),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
