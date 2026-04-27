import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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
      description: 'Nervous system ko balance karne ke liye',
    ),
    '4-7-8': BreathPattern(
      name: 'Deep Sleep',
      inhale: 4, hold: 7, exhale: 8, rest: 0,
      description: 'Acchi neend aur relaxation ke liye',
    ),
    '1-4-2': BreathPattern(
      name: 'Purification',
      inhale: 4, hold: 16, exhale: 8, rest: 0,
      description: 'Sharir ki shuddhi (Yoga style)',
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
    _anim = Tween<double>(begin: 0.8, end: 1.2).animate(
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
    SemanticsService.announce("Sadhana samapt", TextDirection.ltr);
  }

  void _runPhase() {
    if (!_running || !mounted) return;

    final duration = _getDuration(_phase);
    if (duration == 0) {
      _nextPhase();
      return;
    }

    setState(() => _secondsRemaining = duration);
    
    // Accessibility announcement
    SemanticsService.announce("${_phase.name} shuru: $duration seconds", TextDirection.ltr);

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

      // Advance Vibration Logic
      if (_phase == Phase.inhale) {
        HapticFeedback.lightImpact(); // Saans lete waqt halki vibration
      } else if (_phase == Phase.exhale) {
        HapticFeedback.mediumImpact(); // Saans chhodte waqt thodi heavy vibration
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

    // Transition Vibration (Double Tap feel)
    HapticFeedback.selectionClick();
    Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.selectionClick());

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
    final total = _getDuration(_phase);
    final progress = total > 0 ? (_secondsRemaining / total).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'PRANA FLOW',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 30),
              _patternSelector(theme),
              const Spacer(),
              _visual(progress, theme),
              const Spacer(),
              _controls(theme),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
                // Inner breathing circle
                ScaleTransition(
                  scale: _anim,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.4),
                          theme.colorScheme.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Timer Circle
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: _running ? progress : 1,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: theme.colorScheme.outlineVariant,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _running ? "$_secondsRemaining" : "OM",
                  style: GoogleFonts.cinzel(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Text(
              _running ? _phase.name.toUpperCase() : "SHANTI",
              style: GoogleFonts.cinzel(
                fontSize: 32,
                color: theme.colorScheme.secondary,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text("Cycles Done: $_cycles"),
              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
            ),
          ],
        );
      },
    );
  }

  Widget _patternSelector(ThemeData theme) {
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
              HapticFeedback.heavyImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 150,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(
                  color: selected ? Colors.transparent : theme.colorScheme.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e.value.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    e.value.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? theme.colorScheme.onPrimary.withOpacity(0.8) : theme.colorScheme.onSurfaceVariant,
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
    return InkWell(
      onTap: _running ? stop : start,
      borderRadius: BorderRadius.circular(40),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: _running ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: (_running ? theme.colorScheme.error : theme.colorScheme.primary).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Text(
          _running ? "STOP" : "START SADHANA",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: _running ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
