import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart'; 

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
      inhale: 4, hold: 4, exhale: 4, rest: 4,
      description: 'Nervous system balance',
    ),
    '4-7-8': BreathPattern(
      name: 'Deep Sleep',
      inhale: 4, hold: 7, exhale: 8, rest: 0,
      description: 'Relaxation & Sleep',
    ),
    '1-4-2': BreathPattern(
      name: 'Purification',
      inhale: 4, hold: 16, exhale: 8, rest: 0,
      description: 'Body Shuddhi (Yoga)',
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
    _anim = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void start() {
    setState(() {
      _running = true;
      _cycles = 0;
      _phase = Phase.inhale;
    });
    _runPhase();
  }

  void stop() {
    _timer?.cancel();
    _controller.stop();
    _controller.reset();
    setState(() {
      _running = false;
      _secondsRemaining = 0;
    });
    HapticFeedback.heavyImpact();
  }

  void _runPhase() {
    if (!_running || !mounted) return;

    final duration = _getDuration(_phase);
    if (duration == 0) {
      _nextPhase();
      return;
    }

    setState(() => _secondsRemaining = duration);
    _controller.duration = Duration(seconds: duration);

    if (_phase == Phase.inhale) {
      _controller.forward(from: 0);
    } else if (_phase == Phase.exhale) {
      _controller.reverse(from: 1);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !_running) {
        t.cancel();
        return;
      }

      if (_phase == Phase.inhale) {
        HapticFeedback.lightImpact();
      }

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
    HapticFeedback.mediumImpact();

    setState(() {
      switch (_phase) {
        case Phase.inhale: _phase = Phase.hold; break;
        case Phase.hold: _phase = Phase.exhale; break;
        case Phase.exhale: _phase = Phase.rest; break;
        case Phase.rest:
          _phase = Phase.inhale;
          _cycles++;
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
    final theme = Theme.of(context); // FIXED: Removed illegal formatting comma
    final total = _getDuration(_phase);
    final progress = total > 0 ? (_secondsRemaining / total) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: 'Pranayama and Breathing Practice Screen',
          child: Text('PRANA FLOW', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        leading: const BackButton(color: kGold),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _patternSelector(theme),
          const Spacer(),
          _visual(progress, theme),
          const Spacer(),
          _controls(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _visual(double progress, ThemeData theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        String phaseAnnouncement = _running 
            ? "${_phase.name.toUpperCase()} for $_secondsRemaining seconds remaining." 
            : "Sadhana Ready. Timer is stopped.";

        return Column(
          children: [
            // ACCESSIBILITY FIXED: Added semantic announcements for continuous breath phases
            Semantics(
              liveRegion: true,
              label: phaseAnnouncement,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _anim,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [kGold.withOpacity(0.3), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 240, height: 240,
                    child: CircularProgressIndicator(
                      value: _running ? progress : 1.0,
                      strokeWidth: 4,
                      color: kGold,
                      backgroundColor: kGold.withOpacity(0.1),
                    ),
                  ),
                  Text(
                    _running ? "$_secondsRemaining" : "OM",
                    style: GoogleFonts.cinzel(fontSize: 48, fontWeight: FontWeight.bold, color: kGold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _running ? _phase.name.toUpperCase() : "READY",
              style: GoogleFonts.cinzel(fontSize: 24, color: kGold, letterSpacing: 4),
            ),
            const SizedBox(height: 20),
            Semantics(
              label: "Completed Cycles count: $_cycles",
              child: Chip(
                backgroundColor: kGold.withOpacity(0.1),
                side: const BorderSide(color: kGoldDim),
                label: Text("Cycles: $_cycles", style: const TextStyle(color: kGold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _patternSelector(ThemeData theme) {
    return Semantics(
      label: "Select Breath Exercise Pattern List",
      child: SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: patterns.entries.map((e) {
            final selected = _selectedKey == e.key;
            String accessibilityHint = selected 
                ? "Selected exercise." 
                : "Double tap to switch to ${e.value.name}. Duration is ${e.value.inhale} inhale, ${e.value.hold} hold, ${e.value.exhale} exhale, and ${e.value.rest} rest.";

            return GestureDetector(
              onTap: _running ? null : () => setState(() => _selectedKey = e.key),
              child: Semantics(
                button: true,
                selected: selected,
                hint: _running ? "Cannot change pattern while sadhana is running" : accessibilityHint,
                excludeSemantics: true,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? kGold.withOpacity(0.2) : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? kGold : theme.dividerColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e.value.name, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? kGold : theme.hintColor)),
                      const SizedBox(height: 4),
                      Text(
                        e.value.description, 
                        textAlign: TextAlign.center, 
                        style: const TextStyle(fontSize: 10), // FIXED: Text style dangling commas fixed
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Semantics(
          button: true,
          label: _running ? "Stop Sadhana Button" : "Start Practice Button",
          hint: _running ? "Double tap to abort the current breathing session" : "Double tap to begin your breathing exercises",
          excludeSemantics: true,
          child: ElevatedButton(
            onPressed: _running ? stop : start,
            style: ElevatedButton.styleFrom(
              backgroundColor: _running ? Colors.red.withOpacity(0.1) : kGold,
              foregroundColor: _running ? Colors.red : Colors.black,
              side: _running ? const BorderSide(color: Colors.red) : BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(_running ? "STOP SADHANA" : "START PRACTICE", 
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ),
      ),
    );
  } // FIXED: Missing final structural closing braces restored cleanly
}
