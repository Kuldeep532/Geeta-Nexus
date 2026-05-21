import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../theme.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  
  final Map<String, String> _shantiMusic = {
    'None': '',
    'Campfire': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/fire.mp3',
    'Forest Ambient': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/forest.mp3',
    'Om Chant': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/om.mp3',
  };

  final Map<String, String> _meditationGuides = {
    'None': '',
    'Anapana English 1': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/instructions/anapana/english-1.mp3',
  };

  final Map<String, String> _bellSounds = {
    'Gong Bell 1': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/bell/gong-1.mp3',
  };

  String _selectedMusic = 'None';
  String _selectedGuide = 'None';
  String _selectedBell = 'Gong Bell 1';
  
  bool _isBellEnabled = true;
  bool _isAutoMixEnabled = true; 
  double _musicVolume = 0.5;
  double _guideVolume = 0.7;

  final ValueNotifier<int> _secondsLeftNotifier = ValueNotifier<int>(300);
  bool _running = false;
  bool _finished = false;
  
  Timer? _timer;
  DateTime? _endTime;
  
  final AudioPlayer _musicPlayer = AudioPlayer(); 
  final AudioPlayer _guidePlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preCacheAllAudios();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _musicPlayer.dispose();
    _guidePlayer.dispose();
    _bellPlayer.dispose();
    _secondsLeftNotifier.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _preCacheAllAudios() async {
    final cacheManager = DefaultCacheManager();
    for (var url in _bellSounds.values) if (url.isNotEmpty) cacheManager.downloadFile(url);
    for (var url in _shantiMusic.values) if (url.isNotEmpty) cacheManager.downloadFile(url);
  }

  Future<Source> _getAudioSource(String url) async {
    final fileInfo = await DefaultCacheManager().getFileFromCache(url);
    if (fileInfo != null) return DeviceFileSource(fileInfo.file.path);
    return UrlSource(url);
  }

  void _startStop() async {
    HapticFeedback.mediumImpact();
    if (_running) {
      _timer?.cancel();
      _pulseController.stop();
      await _musicPlayer.pause();
      await _guidePlayer.pause();
      WakelockPlus.disable();
      setState(() => _running = false);
    } else {
      WakelockPlus.enable(); 
      _pulseController.repeat(reverse: true);
      
      if (_isBellEnabled) {
        final bellUrl = _bellSounds[_selectedBell];
        if (bellUrl != null && bellUrl.isNotEmpty) {
          final source = await _getAudioSource(bellUrl);
          await _bellPlayer.play(source, volume: 0.8);
        }
      }

      if (_selectedMusic != 'None') {
        final musicUrl = _shantiMusic[_selectedMusic];
        if (musicUrl != null && musicUrl.isNotEmpty) {
          final source = await _getAudioSource(musicUrl);
          await _musicPlayer.play(source);
          _musicPlayer.setReleaseMode(ReleaseMode.loop);
        }
      }

      setState(() {
        _running = true;
        _finished = false;
        _endTime = DateTime.now().add(Duration(seconds: _secondsLeftNotifier.value));
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        final remaining = _endTime!.difference(DateTime.now()).inSeconds;
        if (remaining <= 0) {
          timer.cancel();
          _onFinish();
        } else {
          _secondsLeftNotifier.value = remaining;
        }
      });
    }
  }

  void _onFinish() async {
    await _musicPlayer.stop();
    await _guidePlayer.stop();
    _pulseController.stop();
    WakelockPlus.disable();
    HapticFeedback.heavyImpact();
    setState(() {
      _running = false;
      _finished = true;
      _secondsLeftNotifier.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _startStop,
          child: Text(_running ? "Stop Meditation" : "Start Meditation"),
        ),
      ),
    );
  }
}
