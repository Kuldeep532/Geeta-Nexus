import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

enum Phase {
  inhale,
  hold,
  exhale,
  rest,
}

class BreathPattern {
  final String name;
  final int inhale;
  final int hold;
  final int exhale;
  final int rest;
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

  late final AnimationController _controller;
  late final Animation<double> _animation;

  String _selectedKey = '4-4-4-4';

  static const Map<String, BreathPattern> patterns = {
    '4-4-4-4': BreathPattern(
      name: 'Box Breathing',
      inhale: 4,
      hold: 4,
      exhale: 4,
      rest: 4,
      description: 'Balances the nervous system',
    ),
    '4-7-8': BreathPattern(
      name: 'Deep Sleep',
      inhale: 4,
      hold: 7,
      exhale: 8,
      rest: 0,
      description: 'Relaxation and sleep support',
    ),
    '1-4-2': BreathPattern(
      name: 'Purification',
      inhale: 4,
      hold: 16,
      exhale: 8,
      rest: 0,
      description: 'Traditional yoga purification breathing',
    ),
  };

  BreathPattern get current =>
      patterns[_selectedKey] ?? patterns['4-4-4-4']!;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuart,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void start() {
    HapticFeedback.mediumImpact();

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
    if (!_running || !mounted) {
      return;
    }

    final int duration = _getDuration(_phase);

    if (duration == 0) {
      _nextPhase();
      return;
    }

    setState(() {
      _secondsRemaining = duration;
    });

    _controller.duration = Duration(seconds: duration);

    switch (_phase) {
      case Phase.inhale:
        _controller.forward(from: 0);
        break;

      case Phase.exhale:
        _controller.reverse(from: 1);
        break;

      case Phase.hold:
      case Phase.rest:
        break;
    }

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!_running || !mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining > 1) {
          setState(() {
            _secondsRemaining--;
          });

          if (_phase == Phase.inhale) {
            HapticFeedback.lightImpact();
          }
        } else {
          timer.cancel();
          _nextPhase();
        }
      },
    );
  }

  void _nextPhase() {
    if (!_running || !mounted) {
      return;
    }

    HapticFeedback.mediumImpact();

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

    _runPhase();
  }

  int _getDuration(Phase phase) {
    switch (phase) {
      case Phase.inhale:
        return current.inhale;

      case Phase.hold:
        return current.hold;

      case Phase.exhale:
        return current.exhale;

      case Phase.rest:
        return current.rest;
    }
  }

  String _phaseText() {
    switch (_phase) {
      case Phase.inhale:
        return 'Inhale';

      case Phase.hold:
        return 'Hold';

      case Phase.exhale:
        return 'Exhale';

      case Phase.rest:
        return 'Rest';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final int total = _getDuration(_phase);

    final double progress = total > 0
        ? (_secondsRemaining / total).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: const BackButton(
            color: kGold,
          ),
        ),
        title: Semantics(
          header: true,
          child: Text(
            'PRANA FLOW',
            style: GoogleFonts.cinzel(
              color: kGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
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
      ),
    );
  }

  Widget _visual(double progress, ThemeData theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final String phaseAnnouncement = _running
            ? '${_phaseText()} phase with $_secondsRemaining seconds remaining'
            : 'Breathing exercise ready';

        return Column(
          children: [
            Semantics(
              container: true,
              liveRegion: true,
              label: phaseAnnouncement,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ExcludeSemantics(
                    child: ScaleTransition(
                      scale: _animation,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              kGold.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: _running ? progress : 1.0,
                      strokeWidth: 4,
                      color: kGold,
                      backgroundColor: kGold.withOpacity(0.1),
                      semanticsLabel: 'Breathing cycle progress',
                    ),
                  ),

                  Text(
                    _running ? '$_secondsRemaining' : 'OM',
                    style: GoogleFonts.cinzel(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: kGold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Semantics(
              liveRegion: true,
              label: _running
                  ? 'Current phase ${_phaseText()}'
                  : 'Ready to begin',
              child: Text(
                _running ? _phaseText().toUpperCase() : 'READY',
                style: GoogleFonts.cinzel(
                  fontSize: 24,
                  color: kGold,
                  letterSpacing: 4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Semantics(
              label: 'Completed cycles $_cycles',
              child: Chip(
                backgroundColor: kGold.withOpacity(0.1),
                side: const BorderSide(
                  color: kGoldDim,
                ),
                label: Text(
                  'Cycles: $_cycles',
                  style: const TextStyle(
                    color: kGold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _patternSelector(ThemeData theme) {
    return Semantics(
      container: true,
      label: 'Breathing pattern selector',
      child: SizedBox(
        height: 110,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: patterns.entries.map((entry) {
            final bool selected = _selectedKey == entry.key;

            final BreathPattern pattern = entry.value;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Semantics(
                button: true,
                selected: selected,
                enabled: !_running,
                label: pattern.name,
                hint: _running
                    ? 'Cannot change pattern while session is running'
                    : 'Double tap to select ${pattern.name}',
                value:
                    'Inhale ${pattern.inhale} seconds, hold ${pattern.hold} seconds, exhale ${pattern.exhale} seconds, rest ${pattern.rest} seconds',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _running
                      ? null
                      : () {
                          setState(() {
                            _selectedKey = entry.key;
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 160,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? kGold.withOpacity(0.2)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? kGold
                            : theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pattern.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? kGold
                                : theme.colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          pattern.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _controls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Semantics(
          button: true,
          enabled: true,
          label: _running
              ? 'Stop breathing exercise'
              : 'Start breathing exercise',
          hint: _running
              ? 'Double tap to stop the current breathing session'
              : 'Double tap to begin the selected breathing session',
          child: ElevatedButton(
            onPressed: _running ? stop : start,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              _running ? 'STOP PRACTICE' : 'START PRACTICE',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
