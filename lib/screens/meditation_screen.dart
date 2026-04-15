import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  int _selectedMinutes = 5;
  int _secondsLeft = 0;
  bool _running = false;
  bool _finished = false;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<int> _durations = [1, 3, 5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    _secondsLeft = _selectedMinutes * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startStop() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() {
        _running = true;
        _finished = false;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 0) {
          _timer?.cancel();
          final mins = _selectedMinutes;
          context.read<AppState>().addMeditationMinutes(mins);
          setState(() {
            _running = false;
            _finished = true;
          });
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _finished = false;
      _secondsLeft = _selectedMinutes * 60;
    });
  }

  String get _timeDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = _selectedMinutes * 60;
    return total == 0 ? 0 : 1 - (_secondsLeft / total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Meditation'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'सर्वं ब्रह्मार्पणं कुरु',
                style: GoogleFonts.notoSansDevanagari(
                    color: kGoldDim, fontSize: 18, height: 1.6),
              ),
              Text('Offer everything to the Divine',
                  style: const TextStyle(
                      color: kTextDim, fontSize: 13, fontStyle: FontStyle.italic)),
              const SizedBox(height: 32),
              if (!_running && !_finished) _buildDurationPicker(),
              const SizedBox(height: 32),
              if (_finished)
                _buildFinished()
              else
                _buildTimer(),
              const SizedBox(height: 32),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Duration',
            style: GoogleFonts.cinzel(
                color: kGold, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _durations.map((d) {
            final selected = d == _selectedMinutes;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedMinutes = d;
                _secondsLeft = d * 60;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? kGold.withOpacity(0.2) : kCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? kGold : kDivider, width: selected ? 1.5 : 1),
                ),
                child: Text(
                  '${d}m',
                  style: TextStyle(
                      color: selected ? kGold : kTextDim,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold.withOpacity(0.05),
                  border: Border.all(color: kGoldDim.withOpacity(0.3), width: 2),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 6,
                backgroundColor: kDivider,
                color: kGold,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeDisplay,
                  style: GoogleFonts.cinzel(
                      color: kGold, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  _running ? 'Meditating...' : 'Ready',
                  style: const TextStyle(color: kTextDim, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _startStop,
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              label: Text(_running ? 'Pause' : 'Begin'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: kGold,
                side: const BorderSide(color: kGold),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinished() {
    return Column(
      children: [
        const Text('🧘', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 12),
        Text('Session Complete',
            style: GoogleFonts.cinzel(
                color: kGold, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('+${_selectedMinutes * 5} XP earned!',
            style: const TextStyle(color: kGoldDim, fontSize: 15)),
        const SizedBox(height: 8),
        Text(
          'You meditated for $_selectedMinutes minutes.\nMay this practice bring you peace.',
          style: const TextStyle(color: kTextDim, fontSize: 14, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Meditate Again'),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How to Meditate',
              style: GoogleFonts.cinzel(
                  color: kGold, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          const _Step(
              num: '1', text: 'Sit comfortably with your spine erect'),
          const _Step(num: '2', text: 'Close your eyes and breathe naturally'),
          const _Step(num: '3', text: 'Focus on the mantra: "Om" or "So-Ham"'),
          const _Step(
              num: '4',
              text:
                  'When thoughts arise, gently return to your breath and mantra'),
          const _Step(
              num: '5',
              text: 'Rest in the awareness beneath all thoughts'),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String num;
  final String text;
  const _Step({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGold.withOpacity(0.15),
              border: Border.all(color: kGoldDim),
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: kGold, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: kText, fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}
