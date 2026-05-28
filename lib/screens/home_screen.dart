import 'package:flutter/material.dart';
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

import 'glossary_screen.dart';
import 'journal_screen.dart';
import 'meditation_screen.dart';
import 'reading_plan_screen.dart';
import 'wisdom_cards_screen.dart';

class _NavItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;
  final bool isNew;
  const _NavItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
    this.isNew = false,
  });
}

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
  ];

  void _open(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Gita Nexus',
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kGold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: Icon(Icons.search_rounded, color: colorScheme.onSurface),
            onPressed: () => _open(context, const SearchScreen()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Daily Verse Card
          _DailyVerseCard(isDark: isDark),
          const SizedBox(height: 24),
          // AI Tools Section
          _SectionTitle(title: 'AI Tools', icon: Icons.auto_awesome_rounded),
          const SizedBox(height: 12),
          ..._aiItems.map((item) => _FeatureCard(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            isNew: item.isNew,
            onTap: () => _open(context, item.screen),
          )),
          const SizedBox(height: 24),
          // Daily Guidance Section
          _SectionTitle(title: 'Daily Guidance', icon: Icons.lightbulb_outline_rounded),
          const SizedBox(height: 12),
          ..._guideItems.map((item) => _FeatureCard(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            onTap: () => _open(context, item.screen),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DailyVerseCard extends StatelessWidget {
  final bool isDark;
  const _DailyVerseCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [kGold.withOpacity(0.15), kSaffron.withOpacity(0.08)]
              : [kGold.withOpacity(0.12), kSaffron.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, color: kGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Verse of the Day',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions.',
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— Bhagavad Gita 2.47',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: kGold.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kGold),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: kGold,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isNew;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isNew = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: kGold, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isNew) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: kSaffron.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'NEW',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: kSaffron,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

