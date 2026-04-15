import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

enum _Phase { inhale, hold, exhale, rest }

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.inhale;
  int _count = 0;
  int _cycles = 0;
  bool _running = false;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _anim;
  String _selectedPattern = '4-4-4-4';

  static const _patterns = {
    '4-4-4-4': {'name': 'Box Breathing', 'inhale': 4, 'hold': 4, 'exhale': 4, 'rest': 4},
    '4-7-8': {'name': '4-7-8 Relaxation', 'inhale': 4, 'hold': 7, 'exhale': 8, 'rest': 0},
    '6-0-6': {'name': 'Equal Breathing', 'inhale': 6, 'hold': 0, 'exhale': 6, 'rest': 0},
    '5-5-0': {'name': 'Pranayama', 'inhale': 5, 'hold': 5, 'exhale': 5, 'rest': 0},
  };

  Map<String, dynamic> get _current =>
      Map<String, dynamic>.from(_patterns[_selectedPattern]!);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4));
    _anim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startStop() {
    if (_running) {
      _timer?.cancel();
      _controller.stop();
      setState(() {
        _running = false;
        _phase = _Phase.inhale;
        _count = 0;
      });
    } else {
      setState(() {
        _running = true;
        _phase = _Phase.inhale;
        _count = 0;
      });
      _runPhase();
    }
  }

  void _runPhase() {
    final pat = _current;
    int duration;
    switch (_phase) {
      case _Phase.inhale:
        duration = (pat['inhale'] as int);
        _controller.forward(from: 0);
        break;
      case _Phase.hold:
        duration = (pat['hold'] as int);
        break;
      case _Phase.exhale:
        duration = (pat['exhale'] as int);
        _controller.reverse();
        break;
      case _Phase.rest:
        duration = (pat['rest'] as int);
        break;
    }
    if (duration == 0) {
      _advancePhase();
      return;
    }
    setState(() => _count = duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _count--);
      if (_count <= 0) {
        t.cancel();
        _advancePhase();
      }
    });
  }

  void _advancePhase() {
    if (!_running) return;
    _Phase next;
    switch (_phase) {
      case _Phase.inhale:
        next = _current['hold'] > 0 ? _Phase.hold : _Phase.exhale;
        break;
      case _Phase.hold:
        next = _Phase.exhale;
        break;
      case _Phase.exhale:
        next = _current['rest'] > 0 ? _Phase.rest : _Phase.inhale;
        if (next == _Phase.inhale) setState(() => _cycles++);
        break;
      case _Phase.rest:
        next = _Phase.inhale;
        setState(() => _cycles++);
        break;
    }
    setState(() => _phase = next);
    _runPhase();
  }

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.inhale: return 'Breathe In';
      case _Phase.hold: return 'Hold';
      case _Phase.exhale: return 'Breathe Out';
      case _Phase.rest: return 'Rest';
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case _Phase.inhale: return const Color(0xFF4AA8FF);
      case _Phase.hold: return kGold;
      case _Phase.exhale: return const Color(0xFF88FF88);
      case _Phase.rest: return kTextDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Pranayama Breathing'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPatternSelector(),
            const SizedBox(height: 32),
            Expanded(child: _buildBreathingVisual()),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _startStop,
                  icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                  label: Text(_running ? 'Stop' : 'Begin'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('$_cycles cycles completed',
                style: const TextStyle(color: kTextDim, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Breathing Pattern',
            style: GoogleFonts.cinzel(
                color: kGold, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _patterns.entries.map((e) {
              final selected = _selectedPattern == e.key;
              return GestureDetector(
                onTap: _running
                    ? null
                    : () => setState(() => _selectedPattern = e.key),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? kGold.withOpacity(0.2) : kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? kGold : kDivider, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(e.value['name'] as String,
                          style: TextStyle(
                              color: selected ? kGold : kTextDim,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      Text(e.key,
                          style: const TextStyle(
                              color: kTextDim, fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingVisual() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              final scale = _running ? _anim.value : 0.85;
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (i) {
                    return Container(
                      width: 180.0 + i * 20,
                      height: 180.0 + i * 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _phaseColor.withOpacity(0.03 * (3 - i)),
                      ),
                    );
                  }),
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _phaseColor.withOpacity(0.4),
                            _phaseColor.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(color: _phaseColor, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _running ? '$_count' : '∞',
                            style: GoogleFonts.cinzel(
                                color: _phaseColor,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _running ? _phaseLabel : 'Ready to begin',
            style: GoogleFonts.cinzel(
                color: _running ? _phaseColor : kTextDim,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
