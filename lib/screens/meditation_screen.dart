import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // Local Caching ke liye

import '../theme.dart'; 
// AppState ko yahan se poori tarah hta diya gaya hai as per your instruction!

import MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  
  // 1. Background Music Map
  final Map<String, String> _shantiMusic = {
    'None': '',
    'Campfire': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/fire.mp3',
    'Forest Ambient': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/forest.mp3',
    'Om Chant': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/om.mp3',
    'Soft Rain': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/rain.mp3',
    'Sea Waves': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/sea.mp3',
    'Wind Echoes': 'https://raw.githubusercontent.com/ccsCoder/Dhyanam/master/res/sounds/wind.mp3',
    'Birds Chirping': 'https://raw.githubusercontent.com/musiyenko/Sleep-aid/master/sound/birds.mp3',
    'Boat Rowing': 'https://raw.githubusercontent.com/musiyenko/Sleep-aid/master/sound/boat.mp3',
    'Steady Rain': 'https://raw.githubusercontent.com/musiyenko/Sleep-aid/master/sound/rain.mp3',
    'Thunderstorm': 'https://raw.githubusercontent.com/musiyenko/Sleep-aid/master/sound/thunderstorm.mp3',
    'Train Journey': 'https://raw.githubusercontent.com/musiyenko/Sleep-aid/master/sound/train.mp3',
    'Birds with River': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/sounds/nature/birds-with-river.mp3',
    'Forest with Birds': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/sounds/nature/forest-with-birds.mp3',
    'Water in Stream': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/sounds/nature/water-in-stream.mp3',
    'Nature Birds': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/sounds/nature/birds.mp3',
  };

  // 2. Meditation Guide Map
  final Map<String, String> _meditationGuides = {
    'None': '',
    'Anapana English 1': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/instructions/anapana/english-1.mp3',
    'Anapana English 2': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/instructions/anapana/english-2.mp3',
    'Anapana Hindi Instructions': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/instructions/anapana/hindi.mp3',
    'Mangal Maitri Chanting': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/instructions/anapana/mangal-maitri.mp3',
    'Anapana Nepali Instructions': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/instructions/anapana/nepali.mp3',
  };

  // 3. Bell Sounds Map
  final Map<String, String> _bellSounds = {
    'Gong Bell 1': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/bell/gong-1.mp3',
    'Gong Bell 2': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/bell/gong-2.mp3',
    'Gong Bell 3': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/bell/gong-3.mp3',
    'Gong Bell 4': 'https://raw.githubusercontent.com/thesamanshakya/meditation-timer/main/public/media/bell/gong-4.mp3',
  };

  // Selection States
  String _selectedMusic = 'None';
  String _selectedGuide = 'None';
  String _selectedBell = 'Gong Bell 1';
  
  bool _isBellEnabled = true;
  bool _isAutoMixEnabled = true; 
  double _musicVolume = 0.5;
  double _guideVolume = 0.7;

  final ValueNotifier<int> _secondsLeftNotifier = ValueNotifier<int>(300);
  int _selectedMinutes = 5;
  bool _running = false;
  bool _finished = false;
  
  Timer? _timer;
  DateTime? _endTime;
  
  // Audio Player Instances
  final AudioPlayer _musicPlayer = AudioPlayer(); 
  final AudioPlayer _guidePlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // BACKGROUND SILENT AUTO-DOWNLOAD TRIGGER 🚀
    // Screen khulte hi saare audios chupchaap download hona shuru ho jayenge
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

  // Chupchaap Background Mein Download Karne Wala Agent 🕵️‍♂️
  Future<void> _preCacheAllAudios() async {
    final cacheManager = DefaultCacheManager();
    
    // 1. Saari Bells Cache karo
    for (var url in _bellSounds.values) {
      if (url.isNotEmpty) cacheManager.downloadFile(url);
    }
    // 2. Saari Music Cache karo
    for (var url in _shantiMusic.values) {
      if (url.isNotEmpty) cacheManager.downloadFile(url);
    }
    // 3. Saare Guides Cache karo
    for (var url in _meditationGuides.values) {
      if (url.isNotEmpty) cacheManager.downloadFile(url);
    }
  }

  // Local file fetch karne ya online stream karne wala helper function
  Future<Source> _getAudioSource(String url) async {
    try {
      // Pehle check karo kya yeh file local cache mein download ho chuki hai
      final fileInfo = await DefaultCacheManager().getFileFromCache(url);
      if (fileInfo != null) {
        debugPrint("🎯 Playing 100% Offline from Cache: ${fileInfo.file.path}");
        return DeviceFileSource(fileInfo.file.path); // Offline source
      }
    } catch (e) {
      debugPrint("Cache read bypass: $e");
    }
    debugPrint("🌐 Streaming online (Not cached yet): $url");
    return UrlSource(url); // Backup: Online source
  }

  void _applyVolumeMixing() {
    if (_isAutoMixEnabled && _selectedGuide != 'None' && _selectedMusic != 'None') {
      _musicPlayer.setVolume(0.25);
      _guidePlayer.setVolume(0.85);
    } else {
      _musicPlayer.setVolume(_musicVolume);
      _guidePlayer.setVolume(_guideVolume);
    }
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
      
      // Starting Bell Trigger (Offline/Online auto-handled)
      if (_isBellEnabled) {
        final bellUrl = _bellSounds[_selectedBell];
        if (bellUrl != null && bellUrl.isNotEmpty) {
          final source = await _getAudioSource(bellUrl);
          await _bellPlayer.play(source, volume: 0.8);
        }
      }

      _applyVolumeMixing();

      // Intelligent Solo/Dual Dynamic Player Execution
      if (_selectedMusic != 'None') {
        final musicUrl = _shantiMusic[_selectedMusic];
        if (musicUrl != null && musicUrl.isNotEmpty) {
          try {
            final source = await _getAudioSource(musicUrl);
            await _musicPlayer.play(source);
            _musicPlayer.setReleaseMode(ReleaseMode.loop);
          } catch (e) {
            debugPrint("Music stream failure: $e");
          }
        }
      }

      if (_selectedGuide != 'None') {
        final guideUrl = _meditationGuides[_selectedGuide];
        if (guideUrl != null && guideUrl.isNotEmpty) {
          try {
            final source = await _getAudioSource(guideUrl);
            await _guidePlayer.play(source);
          } catch (e) {
            debugPrint("Guide stream failure: $e");
          }
        }
      }

      setState(() {
        _running = true;
        _finished = false;
        _endTime = DateTime.now().add(Duration(seconds: _secondsLeftNotifier.value));
      });

      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
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
    
    if (_isBellEnabled) {
      final bellUrl = _bellSounds[_selectedBell];
      if (bellUrl != null && bellUrl.isNotEmpty) {
        final source = await _getAudioSource(bellUrl);
        await _bellPlayer.play(source, volume: 0.9);
      }
    }

    setState(() {
      _running = false;
      _finished = true;
      _secondsLeftNotifier.value = 0;
    });
  }

  Widget _buildDurationPicker(ThemeData theme) {
    return Column(
      children: [
        ExcludeSemantics(
          child: Text('SET DURATION', style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: "Meditation Duration Selection Slider",
          value: "$_selectedMinutes minutes",
          hint: "Double-tap and drag horizontally to adjust session duration.",
          child: Slider(
            value: _selectedMinutes.toDouble(),
            min: 1,
            max: 60,
            divisions: 59, 
            activeColor: kGold,
            inactiveColor: kGold.withOpacity(0.2),
            onChanged: (val) {
              setState(() {
                _selectedMinutes = val.toInt();
                _secondsLeftNotifier.value = _selectedMinutes * 60;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdowns(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15);
    final dropdownDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kGold.withOpacity(0.3), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kGold, width: 2),
      ),
    );

    return Column(
      children: [
        Semantics(
          label: "Meditation Guide Audio Dropdown",
          hint: "Currently set to $_selectedGuide. Double-tap to choose a vocal guide or select None to practice with ambient music only.",
          child: DropdownButtonFormField<String>(
            value: _selectedGuide,
            isExpanded: true,
            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            style: textStyle,
            decoration: dropdownDecoration.copyWith(
              labelText: 'MEDITATION GUIDE', 
              labelStyle: GoogleFonts.cinzel(color: kGold, fontSize: 12, fontWeight: FontWeight.bold)
            ),
            icon: const Icon(Icons.interpreter_mode_outlined, color: kGold, size: 20),
            items: _meditationGuides.keys.map((String guideName) {
              return DropdownMenuItem<String>(
                value: guideName,
                child: Text(guideName),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedGuide = val ?? 'None'),
          ),
        ),
        const SizedBox(height: 20),

        Semantics(
          label: "Background Shanti Music Dropdown",
          hint: "Currently set to $_selectedMusic. Double-tap to choose background sounds or select None to practice with vocal instructions only.",
          child: DropdownButtonFormField<String>(
            value: _selectedMusic,
            isExpanded: true,
            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            style: textStyle,
            decoration: dropdownDecoration.copyWith(
              labelText: 'BACKGROUND MUSIC', 
              labelStyle: GoogleFonts.cinzel(color: kGold, fontSize: 12, fontWeight: FontWeight.bold)
            ),
            icon: const Icon(Icons.music_note_outlined, color: kGold, size: 20),
            items: _shantiMusic.keys.map((String musicName) {
              return DropdownMenuItem<String>(
                value: musicName,
                child: Text(musicName),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedMusic = val ?? 'None'),
          ),
        ),
      ],
    );
  }

  void _showSettingsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[950] : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text('AUDIO SETTINGS', style: GoogleFonts.cinzel(color: kGold, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: kGold), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(color: kGold, thickness: 0.5),
                    const SizedBox(height: 15),

                    Semantics(
                      label: "Toggle Bell Alerts",
                      value: _isBellEnabled ? "Bell sound is On" : "Bell sound is Off",
                      child: SwitchListTile(
                        title: Text('BELL ALERT (START/END)', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                        value: _isBellEnabled,
                        activeColor: kGold,
                        onChanged: (val) {
                          setModalState(() => _isBellEnabled = val);
                          setState(() => _isBellEnabled = val);
                        },
                      ),
                    ),

                    if (_isBellEnabled) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedBell,
                        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kGold.withOpacity(0.3))),
                          labelText: "SELECT BELL TYPE", labelStyle: const TextStyle(color: kGold, fontSize: 11),
                        ),
                        items: _bellSounds.keys.map((String bellName) {
                          return DropdownMenuItem<String>(value: bellName, child: Text(bellName));
                        }).toList(),
                        onChanged: (val) async {
                          if (val != null) {
                            setModalState(() => _selectedBell = val);
                            setState(() => _selectedBell = val);
                            final selectedBellUrl = _bellSounds[val];
                            if (selectedBellUrl != null && selectedBellUrl.isNotEmpty) {
                              final source = await _getAudioSource(selectedBellUrl);
                              _bellPlayer.play(source, volume: 0.5);
                            }
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 20),

                    Semantics(
                      label: "Automatic Volume Smart Mixing",
                      value: _isAutoMixEnabled ? "Auto-Mix active" : "Manual levels active",
                      child: SwitchListTile(
                        title: Text('AUTOMATIC INTELLIGENT MIX', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Lowers ambient background music automatically when guide instructions play.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        value: _isAutoMixEnabled,
                        activeColor: kGold,
                        onChanged: (val) {
                          setModalState(() => _isAutoMixEnabled = val);
                          setState(() => _isAutoMixEnabled = val);
                          _applyVolumeMixing();
                        },
                      ),
                    ),

                    if (!_isAutoMixEnabled) ...[
                      const SizedBox(height: 15),
                      Text('GUIDE VOLUME', style: GoogleFonts.cinzel(color: kGold, fontSize: 12)),
                      Slider(
                        value: _guideVolume,
                        activeColor: kGold,
                        onChanged: (val) {
                          setModalState(() => _guideVolume = val);
                          setState(() {
                            _guideVolume = val;
                            _guidePlayer.setVolume(_guideVolume);
                          });
                        },
                      ),
                      Text('BACKGROUND MUSIC VOLUME', style: GoogleFonts.cinzel(color: kGold, fontSize: 12)),
                      Slider(
                        value: _musicVolume,
                        activeColor: kGold,
                        onChanged: (val) {
                          setModalState(() => _musicVolume = val);
                          setState(() {
                            _musicVolume = val;
                            _musicPlayer.setVolume(_musicVolume);
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimerUI(ThemeData theme) {
    return ValueListenableBuilder<int>(
      valueListenable: _secondsLeftNotifier,
      builder: (context, seconds, child) {
        final mins = (seconds / 60).floor();
        final secs = seconds % 60;
        
        final accessibilityTimeString = "$mins minutes and ${secs.toString().padLeft(2, '0')} seconds remaining";
        final displayTime = "$mins:${secs.toString().padLeft(2, '0')}";

        return Column(
          children: [
            Semantics(
              label: "Meditation Timer Countdown",
              value: accessibilityTimeString,
              liveRegion: _running, 
              child: ScaleTransition(
                scale: _running ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kGold.withOpacity(0.5), width: 3),
                    boxShadow: [
                      if (_running) BoxShadow(color: kGold.withOpacity(0.1), blurRadius: 30, spreadRadius: 10)
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayTime,
                    style: GoogleFonts.cinzel(fontSize: 54, color: kGold, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Semantics(
              button: true,
              label: _running ? "Pause Meditation Button" : "Start Meditation Button",
              hint: _running ? "Double-tap to pause session." : "Double-tap to begin your custom synchronized meditation session.",
              child: ElevatedButton(
                onPressed: _startStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  elevation: 8,
                ),
                child: Text(
                  _running ? 'PAUSE' : 'START MEDITATION',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('MEDITATION', style: GoogleFonts.cinzel(letterSpacing: 2, fontWeight: FontWeight.bold, color: kGold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          Semantics(
            label: "Open Audio and Bell Settings",
            button: true,
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: kGold),
              onPressed: () => _showSettingsPanel(context),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Semantics(
                label: "Spiritual Greeting",
                semanticsLabel: "Om Shanti Shanti Shanti", 
                child: Text(
                  "ॐ शान्तिः शान्तिः शान्तिः",
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 24, 
                    color: kGold.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              
              if (!_running && !_finished) ...[
                _buildDurationPicker(theme),
                const SizedBox(height: 25),
                _buildDropdowns(theme),
              ],
              
              const SizedBox(height: 35),
              
              if (_finished) 
                Semantics(
                  liveRegion: true,
                  label: "Meditation Session Finished Alert",
                  child: Column(
                    children: [
                      const Icon(Icons.wb_sunny_rounded, size: 80, color: kGold),
                      const SizedBox(height: 20),
                      Text("PEACEFUL SESSION ENDED", 
                          style: GoogleFonts.cinzel(color: kGold, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Semantics(
                        button: true,
                        label: "Practice Again Button",
                        hint: "Double-tap to clear status and return to setup controls.",
                        child: TextButton.icon(
                          onPressed: () => setState(() => _finished = false),
                          icon: const Icon(Icons.refresh, color: kGold),
                          label: const Text("PRACTICE AGAIN", style: TextStyle(color: kGold)),
                        ),
                      )
                    ],
                  ),
                )
              else 
                _buildTimerUI(theme),
            ],
          ),
        ),
      ),
    );
  }
}
