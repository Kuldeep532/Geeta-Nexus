import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // The colors will be inherited from here
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFD700), // Gold Seed
        primary: const Color(0xFFFFD700),
        surface: const Color(0xFF0D0A04),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0A04),
    ),
    home: const BreathingScreen(),
  ));
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
      description: 'Calm & control',
    ),
    '4-7-8': BreathPattern(
      name: 'Relaxation',
      inhale: 4,
      hold: 7,
      exhale: 8,
      rest: 0,
      description: 'Sleep support',
    ),
    '6-0-6': BreathPattern(
      name: 'Equal Breathing',
      inhale: 6,
      hold: 0,
      exhale: 6,
      rest: 0,
      description: 'Focus',
    ),
  };

  // Safe getter to prevent null errors
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
  }

  void _runPhase() {
    if (!_running || !mounted) return;

    final duration = _getDuration(_phase);
    if (duration == 0) {
      _nextPhase();
      return;
    }

    setState(() => _secondsRemaining = duration);

    // Accessibility: Dynamic voice feedback
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

      HapticFeedback.selectionClick();

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final total = _getDuration(_phase);
    final progress = total > 0 ? (_secondsRemaining / total).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'DIVINE BREATH',
          style: GoogleFonts.cinzel(
            color: colorScheme.primary,
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
    final colorScheme = theme.colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Semantics(
          liveRegion: true,
          label: "Phase ${_phase.name}, $_secondsRemaining seconds, $_cycles cycles",
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
                      strokeWidth: 3,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  Container(
                    width: 240 * _anim.value,
                    height: 240 * _anim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        _running ? "$_secondsRemaining" : "Ready",
                        style: GoogleFonts.cinzel(
                          fontSize: 48,
                          color: colorScheme.onSurface,
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
                  color: colorScheme.primary,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _patternSelector(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: patterns.entries.map((e) {
          final selected = _selectedKey == e.key;
          return GestureDetector(
            onTap: _running ? null : () {
              setState(() => _selectedKey = e.key);
              HapticFeedback.selectionClick();
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected 
                    ? colorScheme.primary.withOpacity(0.1) 
                    : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? colorScheme.primary : colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e.value.name,
                    style: TextStyle(
                      color: selected ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    e.value.description,
                    style: TextStyle(
                      fontSize: 11, 
                      color: colorScheme.onSurfaceVariant
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _controls(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return ElevatedButton(
      onPressed: () {
        _running ? stop() : start();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _running ? colorScheme.errorContainer : colorScheme.primary,
        foregroundColor: _running ? colorScheme.onErrorContainer : colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(_running ? "STOP" : "START"),
    );
  }
}
