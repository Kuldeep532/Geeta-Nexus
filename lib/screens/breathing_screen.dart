import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const kGold = Color(0xFFD4AF37);
const kBg = Color(0xFF121212);
const kCard = Color(0xFF1E1E1E);
const kTextDim = Colors.white54;

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

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BreathingScreen(),
    ));

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});
  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  Phase _phase = Phase.inhale;
  int _cycles = 0;
  bool _running = false;
  String _selectedPatternKey = '4-4-4-4';
  int _secondsRemaining = 0;

  Timer? _phaseTimer;
  Timer? _countdownTimer;
  late AnimationController _controller;
  late Animation<double> _anim;

  static const Map<String, BreathPattern> _patterns = {
    '4-4-4-4': BreathPattern(
        name: 'Box Breathing',
        inhale: 4,
        hold: 4,
        exhale: 4,
        rest: 4,
        description: 'Navy SEAL technique for calm.'),
    '4-7-8': BreathPattern(
        name: 'Relaxation',
        inhale: 4,
        hold: 7,
        exhale: 8,
        rest: 0,
        description: 'Natural tranquilizer for sleep.'),
    '6-0-6': BreathPattern(
        name: 'Equal Breathing',
        inhale: 6,
        hold: 0,
        exhale: 6,
        rest: 0,
        description: 'Improves focus and balance.'),
  };

  BreathPattern get _current => _patterns[_selectedPatternKey]!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _anim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggleSession() {
    setState(() {
      _running = !_running;
      if (_running) {
        _cycles = 0;
        _phase = Phase.inhale;
        _startPhase();
      } else {
        _resetSession();
      }
    });
  }

  void _resetSession() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _controller.stop();
    _controller.value = 0;
    _secondsRemaining = 0;
  }

  void _startPhase() {
    if (!_running) return;

    final duration = _getPhaseDuration(_phase);

    if (duration <= 0) {
      _advancePhase();
      return;
    }

    setState(() => _secondsRemaining = duration);
    
    // Accessibility announcement for screen readers
    SemanticsService.announce("${_phase.name} for $duration seconds", TextDirection.ltr);

    // Visual & Haptic feedback
    if (_phase == Phase.inhale) {
      HapticFeedback.lightImpact();
      _controller.duration = Duration(seconds: duration);
      _controller.forward(from: 0);
    } else if (_phase == Phase.exhale) {
      HapticFeedback.mediumImpact();
      _controller.duration = Duration(seconds: duration);
      _controller.reverse(from: 1);
    } else {
      _controller.stop();
    }

    // Countdown logic
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: duration), () {
      if (mounted && _running),  _advancePhase();
    });
  }

  void _advancePhase() {
    if (!mounted || !_running) return;
    setState(() {
      switch (_phase) {
        case Phase.inhale:
          _phase = Phase.hold;
          break;
        case Phase.hold:
          _phase = Phase.exhale;
          break;
        case Phase.exhale:
          _phase = Phase.rest;
          break;
        case Phase.rest:
          _phase = Phase.inhale;
          _cycles++;
          break;
      }
    });
    _startPhase();
  }

  int _getPhaseDuration(Phase phase) {
    switch (phase) {
      case Phase.inhale: return _current.inhale;
      case Phase.hold: return _current.hold;
      case Phase.exhale: return _current.exhale;
      case Phase.rest: return _current.rest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('DIVINE BREATH', 
          style: GoogleFonts.cinzel(color: kGold, letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildPatternSelector(),
              const SizedBox(height: 60),
              _buildVisual(),
              const SizedBox(height: 60),
              _buildControls(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisual() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            Semantics(
              label: _running ? "Current phase: ${_phase.name}. Seconds remaining: $_secondsRemaining" : "Ready to begin",
              value: _secondsRemaining.toString(),
              child: Container(
                width: 240 * _anim.value,
                height: 240 * _anim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGold, width: 4),
                  boxShadow: [
                    BoxShadow(
                        color: kGold.withOpacity(0.15),
                        blurRadius: 40,
                        spreadRadius: 5)
                  ],
                ),
                child: Center(
                  child: Text(
                    _running ? _secondsRemaining.toString() : "Ready",
                    style: GoogleFonts.cinzel(fontSize: 54, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _phase.name.toUpperCase(),
              style: GoogleFonts.cinzel(
                  fontSize: 28, color: kGold, letterSpacing: 5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: _running ? 1.0 : 0.0,
              child: Text(
                "Completed Cycles: $_cycles",
                style: const TextStyle(color: kTextDim, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPatternSelector() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _patterns.keys.map((key) {
          bool selected = _selectedPatternKey == key;
          return GestureDetector(
            onTap: () {
              if (!_running) {
                setState(() => _selectedPatternKey = key);
              }
            },
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 15, bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:,  selected ? kGold.withOpacity(0.1) : kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? kGold : Colors.white10, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_patterns[key]!.name,
                      style: TextStyle(
                          color: selected ? kGold : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(_patterns[key]!.description,
                      style: const TextStyle(color: kTextDim, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControls() {
    return ElevatedButton(
      onPressed: _toggleSession,
      style: ElevatedButton.styleFrom(
        backgroundColor: _running ? Colors.redAccent.withOpacity(0.1) : kGold,
        foregroundColor: _running ? Colors.redAccent : Colors.black,
        side: _running ? const BorderSide(color: Colors.redAccent) : BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        elevation: _running ? 0 : 8,
      ),
      child: Text(
        _running ? "STOP SESSION" : "BEGIN PRACTICE",
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
 ,  }
}
