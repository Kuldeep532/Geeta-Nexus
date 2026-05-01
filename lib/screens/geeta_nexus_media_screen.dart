import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class GeetaNexusMediaScreen extends StatefulWidget {
  const GeetaNexusMediaScreen({super.key});

  @override
  State<GeetaNexusMediaScreen> createState() => _GeetaNexusMediaScreenState();
}

class _GeetaNexusMediaScreenState extends State<GeetaNexusMediaScreen> {
  final AudioPlayer _player = AudioPlayer();

  String _shloka = "धृतराष्ट्र उवाच |\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |";
  String _translation = "Loading scripture media...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMediaNexus();
  }

  Future<void> _initializeMediaNexus() async {
    try {
      await _fetchVerseData(1, 1);
      await _setupAudioStream("shrimad-bhagavad-gita-hindi-audiobook");
    } catch (e) {
      debugPrint("Media Initialization Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchVerseData(int ch, int v) async {
    final url = Uri.parse('https://bhagavadgitaapi.in/slok/$ch/$v/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _shloka = (data['slok'] as String?) ?? _shloka;
          _translation = (data['hindi'] as String?) ?? "Translation not available";
        });
      }
    } catch (e) {
      debugPrint("Verse Data Fetch Error: $e");
    }
  }

  Future<void> _setupAudioStream(String identifier) async {
    final streamUrl = "https://archive.org/download/$identifier/01.mp3";
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(streamUrl), tag: 'Shloka Audio Stream'));
    } catch (e) {
      debugPrint("Audio Player Error: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("NEXUS MEDIA PLAYER"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Semantics(
                    label: "Scripture Text Reader",
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        child: MergeSemantics(
                          child: Column(
                            children: [
                              Text(
                                _shloka,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(),
                              ),
                              Text(
                                _translation,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      StreamBuilder<Duration?>(
                        stream: _player.durationStream,
                        builder: (context, durationSnapshot) {
                          final duration = durationSnapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration>(
                            stream: _player.positionStream,
                            builder: (context, positionSnapshot) {
                              final position = positionSnapshot.data ?? Duration.zero;
                              final clampedPosition = position > duration && duration > Duration.zero ? duration : position;

                              return Semantics(
                                label: "Media seek bar",
                                value: "Played ${_semanticDuration(clampedPosition)} of ${_semanticDuration(duration)}",
                                increasedValue: "Forward 10 seconds",
                                decreasedValue: "Rewind 10 seconds",
                                child: ProgressBar(
                                  progress: clampedPosition,
                                  total: duration,
                                  onSeek: (d) => _player.seek(d),
                                  progressBarColor: theme.colorScheme.primary,
                                  baseBarColor: theme.colorScheme.onSurface.withOpacity(0.1),
                                  thumbColor: theme.colorScheme.primary,
                                  timeLabelTextStyle: theme.textTheme.labelSmall,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAccessibleIcon(Icons.replay_10, "Rewind 10s", () {
                            _triggerHaptic();
                            _player.seek(_safeRewind(_player.position));
                          }, theme),
                          StreamBuilder<PlayerState>(
                            stream: _player.playerStateStream,
                            builder: (context, snapshot) {
                              final playing = snapshot.data?.playing ?? false;
                              return _buildAccessibleIcon(
                                playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                playing ? "Pause Audio" : "Play Audio",
                                () {
                                  _triggerHaptic();
                                  playing ? _player.pause() : _player.play();
                                },
                                theme,
                                size: 80,
                              );
                            },
                          ),
                          _buildAccessibleIcon(Icons.forward_10, "Forward 10s", () {
                            _triggerHaptic();
                            _player.seek(_safeForward(_player.position, _player.duration ?? Duration.zero));
                          }, theme),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }


  Duration _safeRewind(Duration current) {
    final target = current - const Duration(seconds: 10);
    return target.isNegative ? Duration.zero : target;
  }

  Duration _safeForward(Duration current, Duration total) {
    final target = current + const Duration(seconds: 10);
    if (total == Duration.zero) return target;
    return target > total ? total : target;
  }

  String _semanticDuration(Duration value) {
    final h = value.inHours;
    final m = value.inMinutes.remainder(60);
    final s = value.inSeconds.remainder(60);
    if (h > 0) return '$h hours $m minutes $s seconds';
    if (m > 0) return '$m minutes $s seconds';
    return '$s seconds';
  }

  Widget _buildAccessibleIcon(
    IconData icon,
    String label,
    VoidCallback onTap,
    ThemeData theme, {
    double size = 42,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        tooltip: label,
        iconSize: size,
        icon: Icon(icon, color: theme.colorScheme.primary),
        onPressed: onTap,
      ),
    );
  }
}
