import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'meditation_screen.dart';
import 'breathing_screen.dart';
import 'chants_screen.dart';

/// Dhyana Hub — Unified spiritual practice space.
///
/// Merges three related screens into one cohesive experience with tabs:
/// - Dhyana: Timer-based meditation with ambient audio (was MeditationScreen)
/// - Pranayama: Structured breathing patterns (was BreathingScreen)
/// - Mantra: Sacred chanting with japa counter (was ChantsScreen)
///
/// Each sub-screen is preserved as a standalone component for maintainability.
/// The hub provides unified navigation, shared state awareness, and a cohesive
/// spiritual practice context.
class DhyanaHubScreen extends StatefulWidget {
  const DhyanaHubScreen({super.key});

  @override
  State<DhyanaHubScreen> createState() => _DhyanaHubScreenState();
}

class _DhyanaHubScreenState extends State<DhyanaHubScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    _HubTab(
      label: 'Dhyana',
      icon: Icons.self_improvement_rounded,
      semanticLabel: 'Dhyana meditation timer with guided sessions and ambient audio',
    ),
    _HubTab(
      label: 'Pranayama',
      icon: Icons.air_rounded,
      semanticLabel: 'Pranayama breathing exercises with visual guidance',
    ),
    _HubTab(
      label: 'Mantra',
      icon: Icons.music_note_rounded,
      semanticLabel: 'Sacred mantra chanting with japa bead counter',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(
            'Dhyana Hub',
            style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kGold,
          labelColor: kGold,
          unselectedLabelColor: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: _tabs.map((t) => Tab(
            icon: Icon(t.icon),
            text: t.label,
          )).toList(),
        ),
      ),
      body: Semantics(
        explicitChildNodes: true,
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            // Each tab preserves its original screen as a nested component.
            // This keeps code DRY (no duplication) while maintaining the
            // independent architecture of each practice mode.
            MeditationScreen(),
            BreathingScreen(),
            ChantsScreen(),
          ],
        ),
      ),
    );
  }
}

@immutable
class _HubTab {
  final String label;
  final IconData icon;
  final String semanticLabel;

  const _HubTab({
    required this.label,
    required this.icon,
    required this.semanticLabel,
  });
}
