import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../audio/audio_state.dart';
import '../data/gita_data.dart';
import '../services/chapter_audio_service.dart';
import '../theme.dart';
import 'audio_player_screen.dart';

/// Isolated screen dedicated to listening to Bhagavad Gita chapter audio.
/// Completely independent from the text-reading flow.
///
/// Each chapter tile pings its audio endpoint once on init to determine
/// availability. Dead endpoints show a muted state instead of the player.
class GitaAudioChaptersScreen extends StatefulWidget {
  const GitaAudioChaptersScreen({super.key});

  @override
  State<GitaAudioChaptersScreen> createState() =>
      _GitaAudioChaptersScreenState();
}

class _GitaAudioChaptersScreenState extends State<GitaAudioChaptersScreen> {
  final Set<int> _availableChapters = {};
  final Set<int> _pendingChapters = {};
  bool _pingDone = false;

  static const String _reciterId = 'sanskrit_original';
  static const _pingTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _pingAllChapters();
  }

  Future<void> _pingAllChapters() async {
    final futures = <Future<void>>[];
    for (final ch in kChapters) {
      _pendingChapters.add(ch.number);
      futures.add(_pingChapter(ch.number));
    }
    await Future.wait(futures, eagerError: false);
    if (mounted) setState(() => _pingDone = true);
  }

  Future<void> _pingChapter(int chapterNumber) async {
    final url =
        'https://www.everydaycodings.com/api/v1/audio/chapter/$chapterNumber/$_reciterId.mp3';
    try {
      final resp = await http
          .head(Uri.parse(url))
          .timeout(_pingTimeout);
      if (resp.statusCode >= 200 && resp.statusCode < 400) {
        if (mounted) {
          setState(() => _availableChapters.add(chapterNumber));
        }
      }
    } catch (_) {
      // Endpoint unreachable — leave unavailable
    } finally {
      if (mounted) setState(() => _pendingChapters.remove(chapterNumber));
    }
  }

  bool _isAvailable(int chapterNumber) =>
      _availableChapters.contains(chapterNumber);

  bool _isPending(int chapterNumber) =>
      _pendingChapters.contains(chapterNumber);

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
                      'Select a chapter to begin listening. '
                      'Audio plays in the background. '
                      '${_pingDone ? "Unavailable chapters are shown muted." : "Checking audio availability..."}',
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
                final available = _isAvailable(chapter.number);
                final pending = _isPending(chapter.number);

                return Semantics(
                  button: available || pending,
                  enabled: available && !pending,
                  label:
                      'Chapter ${chapter.number}, ${chapter.name}. '
                      '${chapter.nameSanskrit}. ${chapter.verses.length} verses. '
                      '${pending ? "Checking audio availability." : available ? (audio.isPlaying && isActive ? "Currently playing." : "Double-tap to listen.") : "Audio not available for this chapter."}',
                  child: Material(
                    color: isActive
                        ? kGold.withOpacity(0.12)
                        : theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: (!available || pending)
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) => AudioPlayerScreen(
                                    chapterNumber: chapter.number,
                                    initialReciter: audio.currentReciter ??
                                        kAvailableReciters.first,
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
                                      : available
                                          ? kGold.withOpacity(0.12)
                                          : Colors.grey.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: isActive && audio.isPlaying
                                    ? const Icon(Icons.volume_up_rounded,
                                        color: Colors.black, size: 22)
                                    : pending
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: kGoldDim,
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              '${chapter.number}',
                                              style: GoogleFonts.cinzel(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isActive
                                                    ? Colors.black
                                                    : available
                                                        ? kGold
                                                        : Colors.grey,
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
                                      color: isActive
                                          ? kGold
                                          : available
                                              ? null
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.4),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    chapter.nameSanskrit,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: available
                                          ? theme.colorScheme.onSurface
                                              .withOpacity(0.55)
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.3),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${chapter.verses.length} verses',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: available
                                          ? kGold.withOpacity(0.7)
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Availability / Play indicator
                            ExcludeSemantics(
                              child: pending
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kGold.withOpacity(0.5),
                                      ),
                                    )
                                  : !available
                                      ? Icon(
                                          Icons.headset_off_outlined,
                                          color: Colors.grey.withOpacity(0.4),
                                          size: 24,
                                        )
                                      : Icon(
                                          isActive
                                              ? (audio.isPlaying
                                                  ? Icons
                                                      .pause_circle_outline_rounded
                                                  : Icons
                                                      .play_circle_outline_rounded)
                                              : Icons.play_circle_outline_rounded,
                                          color: isActive
                                              ? kGold
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.3),
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
