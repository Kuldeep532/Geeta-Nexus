import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart'; // Ensure these constants (kGold, kBg, etc.) are defined in your theme file

enum Phase { inhale, hold, exhale, rest }

class BreathPattern {
  final String name;
  final int inhale, hold, exhale, rest;
  final String description;

  const BreathPattern({
    required this.name,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.rest,
    required this.description,
  });
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  Phase _phase = Phase.inhale;
  bool _running = false;
  int _secondsRemaining = 0;
  int _cycles = 0;

  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _anim;

  String _selectedKey = '4-4-4-4';

  static const Map<String, BreathPattern> patterns = {
    '4-4-4-4': BreathPattern(
      name: 'Box Breathing',
      inhale: 4,
      hold: 4,
      exhale: 4,
      rest: 4,
      description: 'Calm & control for nervous system',
    ),
    '4-7-8': BreathPattern(
      name: 'Relaxation',
      inhale: 4,
      hold: 7,
      exhale: 8,
      rest: 0,
      description: 'Effective for falling asleep',
    ),
    '6-0-6': BreathPattern(
      name: 'Equal Breathing',
      inhale: 6,
      hold: 0,
      exhale: 6,
      rest: 0,
      description: 'Enhances focus and balance',
    ),
  };

  BreathPattern get current => patterns[_selectedKey] ?? patterns['4-4-4-4']!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
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

  void start() {
    if (!mounted) return;
    setState(() {
      _running = true;
      _cycles = 0;
      _phase = Phase.inhale;
    });
    _runPhase();
  }

  void stop() {
    if (!mounted) return;
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _running = false;
      _secondsRemaining = 0;
    });
    SemanticsService.announce("Breathing exercise stopped", TextDirection.ltr);
  }

  void _runPhase() {
    if (!_running || !mounted) return;

    final duration = _getDuration(_phase);
    if (duration == 0) {
      _nextPhase();
      return;
    }

    setState(() => _secondsRemaining = duration);

    // Precise accessibility announcement
    SemanticsService.announce(
      "${_phase.name} for $duration seconds",
      TextDirection.ltr,
    );

    _controller.duration = Duration(seconds: duration);

    if (_phase == Phase.inhale) {
      _controller.forward(from: 0);
    } else if (_phase == Phase.exhale) {
      _controller.reverse(from: 1);
    } else {
      _controller.stop();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !_running) {
        t.cancel();
        return;
      }

      // Stronger tick vibration
      HapticFeedback.lightImpact();

      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    if (!mounted || !_running) return;

    // Advanced vibration level for phase change
    HapticFeedback.vibrate(); 

    setState(() {
      switch (_phase) {
        case Phase.inhale: _phase = Phase.hold; break;
        case Phase.hold: _phase = Phase.exhale; break;
        case Phase.exhale: _phase = Phase.rest; break;
        case Phase.rest:
          _phase = Phase.inhale;
          _cycles++;
          // Extra vibration for completed cycle
          HapticFeedback.heavyImpact();
          break;
      }
    });
    _runPhase();
  }

  int _getDuration(Phase p) {
    switch (p) {
      case Phase.inhale: return current.inhale;
      case Phase.hold: return current.hold;
      case Phase.exhale: return current.exhale;
      case Phase.rest: return current.rest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _getDuration(_phase);
    final progress = total > 0 ? (_secondsRemaining / total).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'DIVINE BREATH',
          style: GoogleFonts.cinzel(
            color: kGold,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _patternSelector(),
          const Spacer(),
          _visual(progress),
          const Spacer(),
          _controls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _visual(double progress) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return MergeSemantics(
          child: Semantics(
            liveRegion: true,
            label: _running 
              ? "Current phase: ${_phase.name}. Time remaining: $_secondsRemaining seconds. Total cycles completed: $_cycles."
              : "Breathing exercise ready. Select a pattern above and press start.",
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: _running ? progress : 0,
                        strokeWidth: 4,
                        color: kGold.withOpacity(0.3),
                      ),
                    ),
                    ScaleTransition(
                      scale: _anim,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kGold, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: kGold.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _running ? "$_secondsRemaining" : "Start",
                            style: GoogleFonts.cinzel(
                              fontSize: 48,
                              color: kText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  _phase.name.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 26,
                    color: kSaffron,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_cycles > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Cycles: $_cycles",
                      style: const TextStyle(color: kTextDim, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _patternSelector() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: patterns.entries.map((e) {
          final selected = _selectedKey == e.key;
          return GestureDetector(
            onTap: _running ? null : () {
              setState(() => _selectedKey = e.key);
              HapticFeedback.mediumImpact();
            },
            child: Semantics(
              selected: selected,
              button: true,
              hint: "Selects the ${e.value.name} breathing pattern",
              child: Container(
                width: 170,
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? kGold.withOpacity(0.15) : kCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? kGold : kDivider,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.value.name,
                      style: TextStyle(
                        color: selected ? kGold : kText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.value.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12, 
                        color: kTextDim
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _controls() {
    return Semantics(
      label: _running ? "Stop exercise" : "Start exercise",
      child: ElevatedButton.icon(
        onPressed: () {
          _running ? stop() : start();
          HapticFeedback.heavyImpact();
        },
        icon: Icon(_running ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 32),
        label: Text(
          _running ? "STOP" : "START",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _running ? kError : kGold,
          foregroundColor: _running ? kText : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          elevation: 8,
        ),
      ),
    );
  }
}
