import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; // Isse SemanticsService ka error solve hoga
import 'package:google_fonts/google_fonts.dart';

// Import your theme file
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
    _anim = Tween<double>(begin: 0.85, end: 1.1).animate(
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
    _controller.reset();
    setState(() {
      _running = false;
      _secondsRemaining = 0;
    });
    // Announcement for accessibility
    SemanticsService.announce("Exercise stopped", TextDirection.ltr);
  }

  void _runPhase() {
    if (!_running || !mounted) return;

    final duration = _getDuration(_phase);
    if (duration == 0) {
      _nextPhase();
      return;
    }

    setState(() => _secondsRemaining = duration);

    // Ye line ab error nahi degi
    SemanticsService.announce("${_phase.name} for $duration seconds", TextDirection.ltr);

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

    HapticFeedback.vibrate(); 

    setState(() {
      switch (_phase) {
        case Phase.inhale: _phase = Phase.hold; break;
        case Phase.hold: _phase = Phase.exhale; break;
        case Phase.exhale: _phase = Phase.rest; break;
        case Phase.rest:
          _phase = Phase.inhale;
          _cycles++;
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
    final theme = Theme.of(context);
    final total = _getDuration(_phase);
    final progress = total > 0 ? (_secondsRemaining / total).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'DIVINE BREATH',
          style: GoogleFonts.cinzel(
            color: theme.colorScheme.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _patternSelector(theme),
          const Spacer(),
          _visual(progress, theme),
          const Spacer(),
          _controls(theme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _visual(double progress, ThemeData theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Column(
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
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                ScaleTransition(
                  scale: _anim,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _running ? "$_secondsRemaining" : "Ready",
                        style: GoogleFonts.cinzel(
                          fontSize: 40,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              _running ? _phase.name.toUpperCase() : "Peace",
              style: GoogleFonts.cinzel(
                fontSize: 24,
                color: theme.colorScheme.secondary,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Cycles: $_cycles",
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  Widget _patternSelector(ThemeData theme) {
    return SizedBox(
      height: 100,
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
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.value.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(e.value.description, 
                       textAlign: TextAlign.center, 
                       style: const TextStyle(fontSize: 10), 
                       maxLines: 2),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _controls(ThemeData theme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: _running ? stop : start,
      child: Text(_running ? "STOP" : "START SESSION"),
    );
  }
}
