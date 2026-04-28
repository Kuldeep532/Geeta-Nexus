import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';

import '../theme.dart'; // ERROR FIX: Theme file import ki gayi
import '../state/app_state.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  
  final Map<String, String> _shantiMusic = {
    'None': '',
    'Soul Flute': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'Om Chant': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'Nature Rain': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  };

  String _selectedMusic = 'None';
  final ValueNotifier<int> _secondsLeftNotifier = ValueNotifier<int>(300);
  int _selectedMinutes = 5;
  bool _running = false;
  bool _finished = false;
  
  Timer? _timer;
  DateTime? _endTime;
  
  final AudioPlayer _musicPlayer = AudioPlayer(); 
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _musicPlayer.dispose();
    _secondsLeftNotifier.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startStop() async {
    HapticFeedback.mediumImpact();
    if (_running) {
      _timer?.cancel();
      await _musicPlayer.pause();
      WakelockPlus.disable();
      setState(() => _running = false);
    } else {
      WakelockPlus.enable(); 
      
      if (_selectedMusic != 'None') {
        await _musicPlayer.play(UrlSource(_shantiMusic[_selectedMusic]!), volume: 0.5);
        _musicPlayer.setReleaseMode(ReleaseMode.loop);
      }

      setState(() {
        _running = true;
        _finished = false;
        _endTime = DateTime.now().add(Duration(seconds: _secondsLeftNotifier.value));
      });

      _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
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
    WakelockPlus.disable();
    HapticFeedback.heavyImpact();
    
    setState(() {
      _running = false;
      _finished = true;
      _secondsLeftNotifier.value = 0;
    });
  }

  Widget _buildDurationPicker(ThemeData theme) {
    return Column(
      children: [
        Text('SET DURATION',
            style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.bold)),
        Slider(
          value: _selectedMinutes.toDouble(),
          min: 1,
          max: 60,
          divisions: 12,
          activeColor: kGold,
          inactiveColor: kGold.withOpacity(0.2),
          onChanged: (val) {
            setState(() {
              _selectedMinutes = val.toInt();
              _secondsLeftNotifier.value = _selectedMinutes * 60;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMusicSelector(ThemeData theme) {
    return Column(
      children: [
        Text('SHANTI MUSIC',
            style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _shantiMusic.keys.map((musicName) {
              final isSelected = _selectedMusic == musicName;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(musicName),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedMusic = musicName);
                  },
                  selectedColor: kGold.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? kGold : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerUI(ThemeData theme) {
    return ValueListenableBuilder<int>(
      valueListenable: _secondsLeftNotifier,
      builder: (context, seconds, child) {
        final mins = (seconds / 60).floor();
        final secs = seconds % 60;
        final timeString = "$mins:${secs.toString().padLeft(2, '0')}";

        return Column(
          children: [
            ScaleTransition(
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
                  timeString,
                  style: GoogleFonts.cinzel(fontSize: 54, color: kGold, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _startStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                elevation: 8,
              ),
              child: Text(
                _running ? 'PAUSE' : 'START DHYANA',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Text(
                "ॐ शान्तिः शान्तिः शान्तिः",
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 24, 
                  color: kGold.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              
              if (!_running && !_finished) ...[
                _buildDurationPicker(theme),
                const SizedBox(height: 30),
                _buildMusicSelector(theme),
              ],
              
              const SizedBox(height: 40),
              
              if (_finished) 
                Column(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, size: 80, color: kGold),
                    const SizedBox(height: 20),
                    Text("PEACEFUL SESSION ENDED", 
                        style: GoogleFonts.cinzel(color: kGold, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => setState(() => _finished = false),
                      icon: const Icon(Icons.refresh, color: kGold),
                      label: const Text("PRACTICE AGAIN", style: TextStyle(color: kGold)),
                    )
                  ],
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
