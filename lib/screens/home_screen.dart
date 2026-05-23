import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import 'search_screen.dart';
import 'aira_screen.dart';
import 'karma_planner_screen.dart';
import 'habit_tracker_screen.dart';
import 'antakshari_screen.dart';
import '../models/scripture_model.dart';
import 'scripture_verse_detail_screen.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  final List<_FeatureItem> _features = [
    _FeatureItem(
      title: 'Scripture Library',
      subtitle: 'Explore verses and teachings',
      icon: Icons.menu_book_rounded,
      screen: const ScriptureLibraryScreen(),
    ),
    _FeatureItem(
      title: 'Meditation',
      subtitle: 'Relax your mind with guided sessions',
      icon: Icons.self_improvement_rounded,
      screen: const MeditationScreen(),
    ),
    _FeatureItem(
      title: 'Breathing Practice',
      subtitle: 'Improve calmness and focus',
      icon: Icons.air_rounded,
      screen: const BreathingScreen(),
    ),
    _FeatureItem(
      title: 'Affirmations',
      subtitle: 'Daily positive affirmations',
      icon: Icons.favorite_rounded,
      screen: const AffirmationsScreen(),
    ),
    _FeatureItem(
      title: 'Bookmarks',
      subtitle: 'Quick access to saved content',
      icon: Icons.bookmark_rounded,
      screen: const BookmarksScreen(),
    ),
    _FeatureItem(
      title: 'Reading Plan',
      subtitle: 'Track your spiritual journey',
      icon: Icons.checklist_rounded,
      screen: const ReadingPlanScreen(),
    ),
    _FeatureItem(
      title: 'Wisdom Cards',
      subtitle: 'Get daily wisdom inspiration',
      icon: Icons.style_rounded,
      screen: const WisdomCardsScreen(),
    ),
    _FeatureItem(
      title: 'Journal',
      subtitle: 'Write your thoughts and reflections',
      icon: Icons.edit_note_rounded,
      screen: const JournalScreen(),
    ),
    _FeatureItem(
      title: 'Glossary',
      subtitle: 'Understand spiritual terms',
      icon: Icons.translate_rounded,
      screen: const GlossaryScreen(),
    ),
    _FeatureItem(
      title: 'Astrology',
      subtitle: 'Discover cosmic insights',
      icon: Icons.auto_awesome_rounded,
      screen: const AstrologyScreen(),
    ),
    _FeatureItem(
      title: 'Chants',
      subtitle: 'Listen and practice chants',
      icon: Icons.music_note_rounded,
      screen: const ChantsScreen(),
    ),
    _FeatureItem(
      title: 'Voice Practice',
      subtitle: 'Practice pronunciation and recitation',
      icon: Icons.record_voice_over_rounded,
      screen: const GeetaVoicePracticeScreen(),
    ),
  ];

  final List<_AiFeatureItem> _aiFeatures = const [
    _AiFeatureItem(
      title: 'Karma-Yogi Planner',
      subtitle: 'Plan your day through Krishna\'s teachings',
      icon: Icons.event_note_rounded,
      color: Color(0xFFFF9933),
      tag: 'karma',
    ),
    _AiFeatureItem(
      title: 'Habit Tracker',
      subtitle: 'Track daily spiritual resolutions',
      icon: Icons.track_changes_rounded,
      color: Color(0xFF4CAF50),
      tag: 'habit',
    ),
    _AiFeatureItem(
      title: 'Shloka Antakshari',
      subtitle: 'Voice word-chain game with Aira',
      icon: Icons.music_note_rounded,
      color: Color(0xFF9C27B0),
      tag: 'antakshari',
    ),
  ];

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.speak(text);
  }

  void _navigateTo(Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _openAira() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiraScreen()),
    );
  }

  void _openAiFeature(String tag) {
    HapticFeedback.lightImpact();
    Widget screen;
    switch (tag) {
      case 'karma':
        screen = const KarmaPlannerScreen();
        break;
      case 'habit':
        screen = const HabitTrackerScreen();
        break;
      case 'antakshari':
        screen = const AntakshariScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 20,
                  bottom: 16,
                ),
                title: Semantics(
                  header: true,
                  child: Text(
                    'Spiritual Home',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              actions: [
                Semantics(
                  button: true,
                  label: 'Search spiritual content',
                  child: IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ─── CUSTOMER SUPPORT BANNER ───────────────────────────
                    Semantics(
                      button: true,
                      label: 'Customer Support — Aira AI assistant',
                      hint: 'Double tap to open Aira, your spiritual support companion',
                      child: GestureDetector(
                        onTap: _openAira,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      kGold.withOpacity(0.18),
                                      kSaffron.withOpacity(0.10),
                                    ]
                                  : [
                                      kGold.withOpacity(0.22),
                                      kSaffron.withOpacity(0.12),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kGold.withOpacity(0.45),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                                color: kGold.withOpacity(0.12),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [kGold, kSaffron],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.support_agent_rounded,
                                  color: Colors.black,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer Support',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: isDark ? kGoldLight : kGoldDim,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Chat or speak with Aira — your AI companion',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isDark
                                            ? kTextDim
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: kGold),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── AI ECOSYSTEM FEATURES ─────────────────────────────
                    Semantics(
                      header: true,
                      child: Text(
                        'AI Ecosystem',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Powered by Aira — your free, open-source AI companion',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 112,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _aiFeatures.length,
                        itemBuilder: (ctx, i) {
                          final item = _aiFeatures[i];
                          return Semantics(
                            button: true,
                            label: item.title,
                            hint: item.subtitle,
                            child: GestureDetector(
                              onTap: () => _openAiFeature(item.tag),
                              child: Container(
                                width: 150,
                                margin: EdgeInsets.only(
                                    right: i < _aiFeatures.length - 1 ? 12 : 0),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? item.color.withOpacity(0.12)
                                      : item.color.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: item.color.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(item.icon,
                                        color: item.color, size: 26),
                                    const Spacer(),
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── DAILY GUIDANCE ────────────────────────────────────
                    Semantics(
                      header: true,
                      child: Text(
                        'Daily Guidance',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Choose a spiritual practice to continue your journey.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.4,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 18),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _features.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.02,
                      ),
                      itemBuilder: (context, index) {
                        final item = _features[index];

                        return Semantics(
                          button: true,
                          label: item.title,
                          hint: item.subtitle,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _navigateTo(item.screen),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white,
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                    color: Colors.black.withOpacity(0.04),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.10),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 24,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        item.subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Semantics(
                                      button: true,
                                      label: 'Listen to ${item.title}',
                                      child: IconButton(
                                        tooltip: 'Speak ${item.title}',
                                        icon: const Icon(
                                          Icons.volume_up_rounded,
                                          size: 20,
                                        ),
                                        onPressed: () => _speak(item.title),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
  });
}

class _AiFeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String tag;

  const _AiFeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tag,
  });
}
