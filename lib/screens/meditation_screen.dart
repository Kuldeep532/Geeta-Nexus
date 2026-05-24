import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() =>
      _MeditationScreenState();
}

class _MeditationScreenState
    extends State<MeditationScreen>
    with TickerProviderStateMixin {

  // =========================================================
  // AUDIO SOURCES
  // =========================================================

  final Map<String, String> _musicTracks = {
    'None': '',
    'Forest Ambient':
        'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/forest.mp3',
    'Campfire':
        'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/fire.mp3',
    'Om Chant':
        'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/om.mp3',
  };

  final Map<String, String> _guides = {
    'None': '',
    'Anapana English':
        'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/instructions/anapana/english-1.mp3',
  };

  final Map<String, String> _bells = {
    'Gong Bell':
        'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/bell/gong-1.mp3',
  };

  // =========================================================
  // AUDIO PLAYERS
  // =========================================================

  AudioPlayer? _musicPlayer;
  AudioPlayer? _guidePlayer;
  AudioPlayer? _bellPlayer;

  StreamSubscription<PlayerState>?
      _guidePlayerSubscription;

  // =========================================================
  // TIMER
  // =========================================================

  Timer? _timer;

  DateTime? _endTime;

  // =========================================================
  // CONTROLLERS
  // =========================================================

  late final AnimationController
      _breathingController;

  late final Animation<double>
      _breathingAnimation;

  final TextEditingController
      _customMinutesController =
      TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  final ValueNotifier<int> _secondsLeft =
      ValueNotifier<int>(600);

  bool _running = false;

  bool _immersiveMode = false;

  bool _isLoading = false;

  bool _disposed = false;

  bool _guideOnly = false;

  bool _musicOnly = false;

  bool _autoVolume = true;

  bool _bellEnabled = true;

  bool _showSettings = false;

  // =========================================================
  // VOLUME
  // =========================================================

  double _musicVolume = 0.4;

  double _guideVolume = 1.0;

  // =========================================================
  // DURATION
  // =========================================================

  int _selectedMinutes = 10;

  // =========================================================
  // SELECTED OPTIONS
  // =========================================================

  String _selectedMusic =
      'Forest Ambient';

  String _selectedGuide =
      'Anapana English';

  String _selectedBell =
      'Gong Bell';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {

    super.initState();

    _initializePlayers();

    _initializeAnimations();

    _preCacheAudio();
  }

  // =========================================================
  // INITIALIZE PLAYERS
  // =========================================================

  void _initializePlayers() {

    _musicPlayer = AudioPlayer();

    _guidePlayer = AudioPlayer();

    _bellPlayer = AudioPlayer();
  }

  // =========================================================
  // INITIALIZE ANIMATION
  // =========================================================

  void _initializeAnimations() {

    _breathingController =
        AnimationController(

      vsync: this,

      duration: const Duration(
        seconds: 8,
      ),
    );

    _breathingAnimation =
        Tween<double>(

      begin: 0.92,

      end: 1.08,

    ).animate(

      CurvedAnimation(

        parent: _breathingController,

        curve: Curves.easeInOut,
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {

    _disposed = true;

    _timer?.cancel();

    _guidePlayerSubscription?.cancel();

    _customMinutesController.dispose();

    _secondsLeft.dispose();

    _breathingController.dispose();

    _musicPlayer?.dispose();

    _guidePlayer?.dispose();

    _bellPlayer?.dispose();

    WakelockPlus.disable();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    super.dispose();
  }

  // =========================================================
  // SAFE UI MESSAGE
  // =========================================================

  void _showError(
    String message,
  ) {

    if (!mounted) return;

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            'Notice',
          ),

          content: Text(message),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // PRECACHE AUDIO
  // =========================================================

  Future<void> _preCacheAudio() async {

    try {

      final cache =
          DefaultCacheManager();

      final urls = [

        ..._musicTracks.values,

        ..._guides.values,

        ..._bells.values,
      ];

      for (final url in urls) {

        if (url.isEmpty) continue;

        await cache.downloadFile(url);
      }

    } catch (_) {

      _showError(
        'Audio preloading failed. Please check your connection.',
      );
    }
  }

  // =========================================================
  // CACHE SOURCE
  // =========================================================

  Future<Source> _getSource(
    String url,
  ) async {

    try {

      final cache =
          await DefaultCacheManager()
              .getFileFromCache(url);

      if (cache != null) {

        return DeviceFileSource(
          cache.file.path,
        );
      }

      return UrlSource(url);

    } catch (_) {

      return UrlSource(url);
    }
  }

  // =========================================================
  // FORMAT TIMER
  // =========================================================

  String _formatTime(
    int seconds,
  ) {

    final minutes =
        (seconds ~/ 60)
            .toString()
            .padLeft(2, '0');

    final remaining =
        (seconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$minutes:$remaining';
  }

  // =========================================================
  // APPLY CUSTOM TIME
  // =========================================================

  void _applyDuration() {

    final text =
        _customMinutesController.text.trim();

    if (text.isNotEmpty) {

      final parsed =
          int.tryParse(text);

      if (parsed != null &&
          parsed > 0) {

        _selectedMinutes = parsed;
      }
    }

    _secondsLeft.value =
        _selectedMinutes * 60;
  }

  // =========================================================
  // PLAY BELL
  // =========================================================

  Future<void> _playBell() async {

    if (!_bellEnabled) return;

    try {

      final url =
          _bells[_selectedBell];

      if (url == null ||
          url.isEmpty) return;

      final source =
          await _getSource(url);

      await _bellPlayer?.play(
        source,
        volume: 0.9,
      );

    } catch (_) {

      _showError(
        'Bell playback unavailable.',
      );
    }
  }

  // =========================================================
  // PLAY AUDIO
  // =========================================================

  Future<void> _playAudio() async {

    try {

      // MUSIC

      if (!_guideOnly &&
          _selectedMusic != 'None') {

        final musicUrl =
            _musicTracks[
                _selectedMusic]!;

        final musicSource =
            await _getSource(
          musicUrl,
        );

        await _musicPlayer
            ?.setReleaseMode(
          ReleaseMode.loop,
        );

        await _musicPlayer?.setVolume(
          _musicVolume,
        );

        await _musicPlayer?.play(
          musicSource,
        );
      }

      // GUIDE

      if (!_musicOnly &&
          _selectedGuide != 'None') {

        final guideUrl =
            _guides[
                _selectedGuide]!;

        final guideSource =
            await _getSource(
          guideUrl,
        );

        await _guidePlayer?.setVolume(
          _guideVolume,
        );

        await _guidePlayer?.play(
          guideSource,
        );

        await _guidePlayerSubscription
            ?.cancel();

        _guidePlayerSubscription =
            _guidePlayer
                ?.onPlayerStateChanged
                .listen((state) async {

          if (_disposed) return;

          if (_autoVolume) {

            try {

              if (state ==
                  PlayerState.playing) {

                await _musicPlayer
                    ?.setVolume(
                  0.15,
                );

              } else {

                await _musicPlayer
                    ?.setVolume(
                  _musicVolume,
                );
              }

            } catch (_) {}
          }
        });
      }

    } catch (_) {

      _showError(
        'Audio playback unavailable. Please check your connection.',
      );
    }
  }

  // =========================================================
  // START MEDITATION
  // =========================================================

  Future<void>
      _startMeditation() async {

    if (_isLoading) return;

    setState(() {

      _isLoading = true;
    });

    try {

      _applyDuration();

      HapticFeedback.mediumImpact();

      await WakelockPlus.enable();

      SystemChrome
          .setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );

      _breathingController.repeat(
        reverse: true,
      );

      await _playBell();

      await _playAudio();

      _endTime =
          DateTime.now().add(

        Duration(
          seconds:
              _secondsLeft.value,
        ),
      );

      _timer?.cancel();

      _timer = Timer.periodic(

        const Duration(seconds: 1),

        (timer) {

          if (_disposed ||
              _endTime == null) {

            timer.cancel();

            return;
          }

          final remaining =
              _endTime!
                  .difference(
                    DateTime.now(),
                  )
                  .inSeconds;

          if (remaining <= 0) {

            timer.cancel();

            _finishMeditation();

          } else {

            _secondsLeft.value =
                remaining;
          }
        },
      );

      if (!_disposed) {

        setState(() {

          _running = true;

          _immersiveMode = true;
        });
      }

    } catch (_) {

      _showError(
        'Unable to start meditation.',
      );

    } finally {

      if (!_disposed) {

        setState(() {

          _isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // PAUSE
  // =========================================================

  Future<void>
      _pauseMeditation() async {

    try {

      _timer?.cancel();

      _breathingController.stop();

      await _musicPlayer?.pause();

      await _guidePlayer?.pause();

      await WakelockPlus.disable();

      if (!_disposed) {

        setState(() {

          _running = false;
        });
      }

    } catch (_) {

      _showError(
        'Unable to pause meditation.',
      );
    }
  }

  // =========================================================
  // RESET
  // =========================================================

  Future<void>
      _resetMeditation() async {

    try {

      _timer?.cancel();

      await _musicPlayer?.stop();

      await _guidePlayer?.stop();

      _breathingController.reset();

      _applyDuration();

      await WakelockPlus.disable();

      SystemChrome
          .setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );

      if (!_disposed) {

        setState(() {

          _running = false;

          _immersiveMode = false;
        });
      }

    } catch (_) {

      _showError(
        'Unable to reset meditation.',
      );
    }
  }

  // =========================================================
  // FINISH
  // =========================================================

  Future<void>
      _finishMeditation() async {

    try {

      _timer?.cancel();

      await _musicPlayer?.stop();

      await _guidePlayer?.stop();

      await _playBell();

      _breathingController.stop();

      await WakelockPlus.disable();

      SystemChrome
          .setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );

      HapticFeedback.heavyImpact();

      if (!_disposed) {

        setState(() {

          _running = false;

          _immersiveMode = false;

          _secondsLeft.value = 0;
        });
      }

    } catch (_) {

      _showError(
        'Unable to finish meditation.',
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    final theme =
        Theme.of(context);

    return Scaffold(

      backgroundColor:
          AppTheme.background(
        context,
      ),

      body: SafeArea(

        child: Stack(

          children: [

            // =================================================
            // MAIN ANIMATION
            // =================================================

            Center(

              child: AnimatedBuilder(

                animation:
                    _breathingAnimation,

                builder:
                    (_, child) {

                  return Transform.scale(

                    scale: _running
                        ? _breathingAnimation
                            .value
                        : 1,

                    child: child,
                  );
                },

                child: Container(

                  width: 280,

                  height: 280,

                  decoration:
                      BoxDecoration(

                    shape:
                        BoxShape.circle,

                    gradient:
                        AppTheme
                            .meditationGradient(
                      context,
                    ),
                  ),

                  child: Center(

                    child:
                        ValueListenableBuilder<int>(

                      valueListenable:
                          _secondsLeft,

                      builder:
                          (_, value, __) {

                        return Column(

                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [

                            Text(

                              _formatTime(
                                value,
                              ),

                              style:
                                  GoogleFonts.inter(

                                fontSize:
                                    52,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                color: theme
                                    .colorScheme
                                    .onPrimary,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(

                              _running
                                  ? 'Meditating...'
                                  : 'Ready',

                              style:
                                  GoogleFonts.inter(

                                color: theme
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(
                                      0.8,
                                    ),
                              ),
                            ),

                            if (_isLoading)

                              const Padding(

                                padding:
                                    EdgeInsets.only(
                                  top: 20,
                                ),

                                child:
                                    CircularProgressIndicator(),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // =================================================
            // SETTINGS PANEL — shown only before/after session
            // =================================================

            if (!_immersiveMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.62,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Drag handle ──────────────────────────────────
                        Center(
                          child: ExcludeSemantics(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: theme.dividerColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                        // ── Duration presets ─────────────────────────────
                        Semantics(
                          label: 'Duration presets',
                          container: true,
                          child: Wrap(
                            spacing: 8,
                            children: [5, 10, 15, 20, 30].map((min) {
                              final selected = _selectedMinutes == min;
                              return Semantics(
                                button: true,
                                selected: selected,
                                label: '$min minute${min == 1 ? '' : 's'}, '
                                    '${selected ? 'selected' : 'not selected'}',
                                excludeSemantics: true,
                                child: ChoiceChip(
                                  label: Text('$min min'),
                                  selected: selected,
                                  onSelected: (_) => setState(() {
                                    _selectedMinutes = min;
                                    _secondsLeft.value = min * 60;
                                    _customMinutesController.clear();
                                  }),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Custom duration input ────────────────────────
                        TextField(
                          controller: _customMinutesController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSubmitted: (_) => _applyDuration(),
                          decoration: const InputDecoration(
                            labelText: 'Custom duration (minutes)',
                            hintText: 'e.g. 45',
                            prefixIcon: Icon(Icons.timer_outlined),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Ambient music selector ───────────────────────
                        DropdownButtonFormField<String>(
                          value: _selectedMusic,
                          decoration: const InputDecoration(
                            labelText: 'Ambient Music',
                            prefixIcon: Icon(Icons.music_note_outlined),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          items: _musicTracks.keys
                              .map((track) => DropdownMenuItem(
                                    value: track,
                                    child: Text(track),
                                  ))
                              .toList(),
                          onChanged: _running
                              ? null
                              : (val) => setState(
                                  () => _selectedMusic = val ?? 'None'),
                        ),
                        const SizedBox(height: 12),

                        // ── Guided meditation selector ───────────────────
                        DropdownButtonFormField<String>(
                          value: _selectedGuide,
                          decoration: const InputDecoration(
                            labelText: 'Guided Meditation',
                            prefixIcon:
                                Icon(Icons.record_voice_over_outlined),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          items: _guides.keys
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ))
                              .toList(),
                          onChanged: _running
                              ? null
                              : (val) => setState(
                                  () => _selectedGuide = val ?? 'None'),
                        ),
                        const SizedBox(height: 16),

                        // ── Music volume slider ──────────────────────────
                        Semantics(
                          label:
                              'Music volume, ${(_musicVolume * 100).round()} percent',
                          slider: true,
                          excludeSemantics: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Music volume  ${(_musicVolume * 100).round()}%',
                                style: theme.textTheme.bodySmall,
                              ),
                              Slider(
                                value: _musicVolume,
                                onChanged: (v) =>
                                    setState(() => _musicVolume = v),
                              ),
                            ],
                          ),
                        ),

                        // ── Guide volume slider ──────────────────────────
                        Semantics(
                          label:
                              'Guide volume, ${(_guideVolume * 100).round()} percent',
                          slider: true,
                          excludeSemantics: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guide volume  ${(_guideVolume * 100).round()}%',
                                style: theme.textTheme.bodySmall,
                              ),
                              Slider(
                                value: _guideVolume,
                                onChanged: (v) =>
                                    setState(() => _guideVolume = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // ── Toggles row ──────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                toggled: _autoVolume,
                                label: 'Auto-lower music during guide',
                                excludeSemantics: true,
                                child: SwitchListTile.adaptive(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Auto-lower music',
                                      style: TextStyle(fontSize: 13)),
                                  value: _autoVolume,
                                  onChanged: (v) =>
                                      setState(() => _autoVolume = v),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Semantics(
                                toggled: _bellEnabled,
                                label: 'Bell on session start and end',
                                excludeSemantics: true,
                                child: SwitchListTile.adaptive(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Bell',
                                      style: TextStyle(fontSize: 13)),
                                  value: _bellEnabled,
                                  onChanged: (v) =>
                                      setState(() => _bellEnabled = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Start / Pause button ─────────────────────────
                        Semantics(
                          button: true,
                          enabled: !_isLoading,
                          label: _isLoading
                              ? 'Loading audio, please wait'
                              : (_running
                                  ? 'Pause meditation'
                                  : 'Start meditation'),
                          excludeSemantics: true,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : (_running
                                      ? _pauseMeditation
                                      : _startMeditation),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black),
                                    )
                                  : Icon(_running
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded),
                              label: Text(
                                _isLoading
                                    ? 'Loading…'
                                    : (_running
                                        ? 'Pause Meditation'
                                        : 'Start Meditation'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Reset button ─────────────────────────────────
                        Semantics(
                          button: true,
                          label: 'Reset timer and stop all audio',
                          excludeSemantics: true,
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _resetMeditation,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reset'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
