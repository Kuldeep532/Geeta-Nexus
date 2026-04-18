import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme.dart';
import '../state/app_state.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  
  // High-performance state variables
  final ValueNotifier<int> _secondsLeftNotifier = ValueNotifier<int>(300);
  int _selectedMinutes = 5;
  bool _running = false;
  bool _finished = false;
  
  Timer? _timer;
  DateTime? _endTime;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<int> _durations = [1, 3, 5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    _secondsLeftNotifier.dispose();
    WakelockPlus.disable(); // Ensure screen lock is released
    super.dispose();
  }

  // Safe Audio Logic: Won't crash if file is missing
  Future<void> _playFinishSound() async {
    try {
      // Logic: Only attempts play if the file exists in your future assets
      await _audioPlayer.play(AssetSource('audio/meditation_bell.mp3'));
    } catch (e) {
      // Silently catch error if file is not yet uploaded
      debugPrint("Audio ignored: File likely missing from assets. Error: $e");
    }
  }

  void _startStop() {
    if (_running) {
      _timer?.cancel();
      WakelockPlus.disable();
      setState(() => _running = false);
    } else {
      WakelockPlus.enable(); // Keep screen on during meditation
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
          // Updates only the listener, not the whole build method
          _secondsLeftNotifier.value = remaining;
        }
      });
    }
  }

  void _onFinish() {
    _playFinishSound();
    WakelockPlus.disable();
    
    // Safety check for Provider context
    if (mounted) {
      context.read<AppState>().addMeditationMinutes(_selectedMinutes);
    }
    
    setState(() {
      _running = false;
      _finished = true;
      _secondsLeftNotifier.value = 0;
    });
  }

  void _reset() {
    _timer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _running = false;
      _finished = false;
      _secondsLeftNotifier.value = _selectedMinutes * 60;
    });
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Meditation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: kGold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Text(
                'सर्वं ब्रह्मार्पणं कुरु',
                style: GoogleFonts.notoSansDevanagari(
                    color: kGoldDim, fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text('Offer everything to the Divine',
                  style: GoogleFonts.inter(
                      color: kTextDim, fontSize: 14, fontStyle: FontStyle.italic)),
              const SizedBox(height: 50),
              
              if (!_running && !_finished) _buildDurationPicker(),
              
              const SizedBox(height: 20),
              if (_finished) _buildFinished() else _buildTimerUI(),
              
              const SizedBox(height: 50),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Column(
      children: [
        Text('SELECT DURATION',
            style: GoogleFonts.cinzel(
                color: kGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: _durations.map((d) {
            final isSelected = d == _selectedMinutes;
            return ChoiceChip(
              label: Text('${d}m'),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _timer?.cancel();
                    _running = false;
                    _selectedMinutes = d;
                    _secondsLeftNotifier.value = d * 60;
                  });
                }
              },
              backgroundColor: kCard,
              selectedColor: kGold.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? kGold : kTextDim,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: StadiumBorder(
                side: BorderSide(color: isSelected ? kGold : kDivider),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimerUI() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (_running)
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGold.withOpacity(0.03),
                  ),
                ),
              ),
            if (_running)
              const Positioned(
                top: 20,
                child: Icon(Icons.self_improvement, size: 40, color: kGoldDim),
              ),
            ValueListenableBuilder<int>(
              valueListenable: _secondsLeftNotifier,
              builder: (context, seconds, child) {
                final total = _selectedMinutes * 60;
                final progress = total == 0 ? 0.0 : 1 - (seconds / total);
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: kDivider,
                    valueColor: const AlwaysStoppedAnimation<Color>(kGold),
                  ),
                );
              },
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _secondsLeftNotifier,
                  builder: (context, seconds, child) {
                    return Text(
                      _formatTime(seconds),
                      style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 48, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Text(
                  _running ? 'SHANTI' : 'READY',
                  style: GoogleFonts.inter(
                      color: kGoldDim.withOpacity(0.7), fontSize: 12, letterSpacing: 3),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _startStop,
              icon: Icon(_running ? Icons.pause_circle_filled : Icons.play_circle_filled),
              label: Text(_running ? 'PAUSE' : 'BEGIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            if (!_running && _secondsLeftNotifier.value < (_selectedMinutes * 60)) ...[
              const SizedBox(width: 15),
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: kGoldDim),
                tooltip: 'Reset Timer',
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildFinished() {
    return Column(
      children: [
        const Text('🕉️', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 20),
        Text('Peace Attained',
            style: GoogleFonts.cinzel(
                color: kGold, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Practice completed successfully.\nMay your day be filled with mindfulness.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: kTextDim, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 35),
        TextButton(
          onPressed: _reset,
          child: const Text('RESTART SESSION', style: TextStyle(color: kGold, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: kGold, size: 18),
              const SizedBox(width: 10),
              Text('GUIDELINES',
                  style: GoogleFonts.cinzel(
                      color: kGold, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          const _Step(text: 'Sit with a straight back, hands on your knees.'),
          const _Step(text: 'Focus your gaze inward or close your eyes.'),
          const _Step(text: 'Let thoughts pass like clouds in the sky.'),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String text;
  const _Step({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: kGold, fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(color: kTextDim, fontSize: 14))),
        ],
      ),
    );
  }
}
