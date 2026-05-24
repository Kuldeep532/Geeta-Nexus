import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'search_screen.dart';
import 'karma_planner_screen.dart';
import 'habit_tracker_screen.dart';
import 'antakshari_screen.dart';
import 'scripture_library_screen.dart';
import 'affirmations_screen.dart';
import 'astrology_screen.dart';
import 'chants_screen.dart';
import 'bookmarks_screen.dart';
import 'breathing_screen.dart';
import 'geeta_voice_practice_screen.dart';
import 'glossary_screen.dart';
import 'journal_screen.dart';
import 'meditation_screen.dart';
import 'reading_plan_screen.dart';
import 'wisdom_cards_screen.dart';

// ─── Data models ────────────────────────────────────────────────────────────

class _NavItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;
  const _NavItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
  });
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_NavItem> _aiItems = [
    _NavItem(
      title: 'Karma-Yogi Planner',
      subtitle: 'Plan your day through Krishna\'s teachings',
      icon: Icons.event_note_rounded,
      screen: KarmaPlannerScreen(),
    ),
    _NavItem(
      title: 'Habit Tracker',
      subtitle: 'Track your daily spiritual resolutions',
      icon: Icons.track_changes_rounded,
      screen: HabitTrackerScreen(),
    ),
    _NavItem(
      title: 'Shloka Antakshari',
      subtitle: 'Voice word-chain game with Aira',
      icon: Icons.music_note_rounded,
      screen: AntakshariScreen(),
    ),
  ];

  static const List<_NavItem> _guideItems = [
    _NavItem(
      title: 'Scripture Library',
      subtitle: 'Explore Gita verses and teachings',
      icon: Icons.menu_book_rounded,
      screen: ScriptureLibraryScreen(),
    ),
    _NavItem(
      title: 'Meditation',
      subtitle: 'Guided meditation sessions',
      icon: Icons.self_improvement_rounded,
      screen: MeditationScreen(),
    ),
    _NavItem(
      title: 'Breathing Practice',
      subtitle: 'Improve calmness and focus',
      icon: Icons.air_rounded,
      screen: BreathingScreen(),
    ),
    _NavItem(
      title: 'Affirmations',
      subtitle: 'Daily positive affirmations',
      icon: Icons.favorite_rounded,
      screen: AffirmationsScreen(),
    ),
    _NavItem(
      title: 'Bookmarks',
      subtitle: 'Quick access to saved content',
      icon: Icons.bookmark_rounded,
      screen: BookmarksScreen(),
    ),
    _NavItem(
      title: 'Reading Plan',
      subtitle: 'Track your spiritual journey',
      icon: Icons.checklist_rounded,
      screen: ReadingPlanScreen(),
    ),
    _NavItem(
      title: 'Wisdom Cards',
      subtitle: 'Daily wisdom inspiration',
      icon: Icons.style_rounded,
      screen: WisdomCardsScreen(),
    ),
    _NavItem(
      title: 'Journal',
      subtitle: 'Write your thoughts and reflections',
      icon: Icons.edit_note_rounded,
      screen: JournalScreen(),
    ),
    _NavItem(
      title: 'Glossary',
      subtitle: 'Understand spiritual terms',
      icon: Icons.translate_rounded,
      screen: GlossaryScreen(),
    ),
    _NavItem(
      title: 'Astrology',
      subtitle: 'Discover cosmic insights',
      icon: Icons.auto_awesome_rounded,
      screen: AstrologyScreen(),
    ),
    _NavItem(
      title: 'Chants',
      subtitle: 'Listen and practice sacred chants',
      icon: Icons.music_note_rounded,
      screen: ChantsScreen(),
    ),
    _NavItem(
      title: 'Voice Practice',
      subtitle: 'Practice Sanskrit pronunciation',
      icon: Icons.record_voice_over_rounded,
      screen: GeetaVoicePracticeScreen(),
    ),
  ];

  void _open(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    SemanticsService.announce(
      'Opening screen',
      TextDirection.ltr,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        // Single clear heading — announced by screen reader when screen loads
        title: Semantics(
          header: true,
          namesRoute: true,
          label: 'Geeta Nexus',
          child: Text(
            'Geeta Nexus',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Search spiritual content',
            hint: 'Double tap to open search',
            child: IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => _open(context, const SearchScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ── AI Tools section ─────────────────────────────────────────
          _SectionHeader(title: 'AI Tools'),
          ..._aiItems.map(
            (item) => _AccessibleTile(
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              iconColor: colorScheme.primary,
              onTap: () => _open(context, item.screen),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(indent: 16, endIndent: 16),
          const SizedBox(height: 8),

          // ── Daily Guidance section ───────────────────────────────────
          _SectionHeader(title: 'Daily Guidance'),
          ..._guideItems.map(
            (item) => _AccessibleTile(
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              iconColor: colorScheme.primary,
              onTap: () => _open(context, item.screen),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable section header ────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── Single accessible list tile ────────────────────────────────────────────
// One tap target per item. No nested buttons. Screen reader reads:
// "Title. Subtitle. Button. Double tap to activate."

class _AccessibleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _AccessibleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      hint: 'Double tap to open',
      // ExcludeSemantics on children so the label above is
      // the ONLY thing TalkBack reads — no duplicate words.
      child: ExcludeSemantics(
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: iconColor, size: 26),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          minVerticalPadding: 12,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}
