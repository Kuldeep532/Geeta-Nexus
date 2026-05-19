import 'dart:math' as math; // Required for generating random indexes safely
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';
import '../models/models.dart'; 

import 'search_screen.dart';
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
import 'wisdom_cards_screen.dart'; // Retained for Wisdom Cards if needed under another configuration

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Verse? _dailyVerse; 
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyVerse();
    });
    _initTts();
  }

  void _loadDailyVerse() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.allVerses.isNotEmpty) {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      setState(() {
        _dailyVerse = state.allVerses[dayOfYear % state.allVerses.length];
      });
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
  }

  String _getGreetingText(String userName) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    String spiritualGreeting = 'Jai Shri Krishna';

    if (hour >= 5 && hour < 12) {
      timeGreeting = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      timeGreeting = 'Good Evening';
    } else {
      timeGreeting = 'Good Night';
      spiritualGreeting = 'Hare Krishna';
    }

    if (userName.isNotEmpty) {
      return '$timeGreeting, Namaste $userName, $spiritualGreeting';
    } else {
      return '$timeGreeting, $spiritualGreeting';
    }
  }

  String _getGreetingPrefix() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Picks a completely random shlok from the dataset and pushes directly to detail view
  void _navigateToRandomShlok(AppState state) {
    if (state.allVerses.isNotEmpty) {
      final random = math.Random();
      final randomIndex = random.nextInt(state.allVerses.length);
      final randomVerse = state.allVerses[randomIndex];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScriptureVerseDetailScreen(
            allVerses: [ScriptureVerse.fromLocalVerse(randomVerse)],
            initialIndex: 0,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(state, isDark),
                  const SizedBox(height: 16),
                  _buildStreakBar(state, isDark, theme),
                  const SizedBox(height: 24),
                  if (_dailyVerse != null) _buildDailyVerseCard(context, _dailyVerse!, isDark, theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Explore'),
                  const SizedBox(height: 12),
                  _buildLibraryCard(context, isDark), 
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActions(context, isDark, state), 
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Semantics(
        header: true,
        label: 'Geeta Nexus Home Screen',
        child: Text(
          'GEETA NEXUS', 
          style: GoogleFonts.cinzel(
            color: kGold, 
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 2.0
          )
        ),
      ),
    );
  }

  Widget _buildGreetingSection(AppState state, bool isDark) {
    final combinedGreeting = _getGreetingText(state.userName);
    final hour = DateTime.now().hour;
    final isNight = hour >= 21 || hour < 5;

    return Semantics(
      container: true,
      label: combinedGreeting,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNight ? 'Good Night · Hare Krishna' : '${_getGreetingPrefix()} · Jai Shri Krishna', 
            style: GoogleFonts.crimsonText(
              color: isDark ? kGoldLight : kGoldDim, 
              fontSize: 18, 
              fontStyle: FontStyle.italic
            )
          ),
          if (state.userName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Namaste, ${state.userName}', 
              style: GoogleFonts.cinzel(
                color: kGold, 
                fontSize: 22, 
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakBar(AppState state, bool isDark, ThemeData theme) {
    return Semantics(
      container: true,
      label: 'Your Progress: Streak ${state.streak} Days, Verses read ${state.readVerses.length}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1500) : const Color(0xFFFFF9E5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kGold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            _buildStatItem('🔥', '${state.streak}', 'Days'),
            const SizedBox(width: 20),
            _buildStatItem('📖', '${state.readVerses.length}', 'Verses'),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Daily Progress', style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: LinearProgressIndicator(
                    value: (state.readVerses.length / 700).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    color: kGold,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon), 
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: kGold)), 
        Text(label, style: const TextStyle(fontSize: 10))
      ]
    );
  }

  Widget _buildDailyVerseCard(BuildContext context, Verse verse, bool isDark, ThemeData theme) {
    return Semantics(
      button: true,
      label: 'Daily Verse Card. Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}. Text: ${verse.translation}',
      hint: 'Double tap to open verse details',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScriptureVerseDetailScreen(
              allVerses: [ScriptureVerse.fromLocalVerse(verse)],
              initialIndex: 0,
            ),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: isDark ? [const Color(0xFF2A2000), Colors.black] : [const Color(0xFFFFF6DD), Colors.white]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGold.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DAILY VERSE', style: TextStyle(letterSpacing: 2, fontSize: 12, color: kGold)),
              const SizedBox(height: 12),
              Text(
                verse.translation, 
                maxLines: 3, 
                overflow: TextOverflow.ellipsis, 
                style: GoogleFonts.crimsonText(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text('Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cinzel(
        color: kGold,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildLibraryCard(BuildContext context, bool isDark) {
    return Semantics(
      button: true,
      label: 'Scripture Library. Explore all religious and spiritual texts.',
      hint: 'Double tap to open Library',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const ScriptureLibraryScreen()),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151515) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kGold.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scripture Library',
                      style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: kGold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Access Bhagavad Gita, Shiv Mahapuran, and other sacred texts.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: kGold, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark, AppState state) {
    // Verified 12 unique items setup. 'random_verse_screen' completely eliminated.
    final List<Map<String, dynamic>> actions = [
      {'icon': '🧘', 'title': 'Meditation', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeditationScreen()))},
      {'icon': '📿', 'title': 'Chants', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChantsScreen()))},
      {'icon': '🌬️', 'title': 'Breathing', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingScreen()))},
      {'icon': '🗣️', 'title': 'Voice Practice', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeetaVoicePracticeScreen()))},
      {'icon': '✨', 'title': 'Affirmations', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AffirmationsScreen()))},
      {'icon': '📅', 'title': 'Reading Plan', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingPlanScreen()))},
      {'icon': '📓', 'title': 'Journal', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen()))},
      {'icon': '🔖', 'title': 'Bookmarks', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))},
      {'icon': '🌌', 'title': 'Astrology', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AstrologyScreen()))},
      {'icon': '📖', 'title': 'Glossary', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlossaryScreen()))},
      {'icon': '🃏', 'title': 'Wisdom Cards', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WisdomCardsScreen()))},
      {'icon': '🕉️', 'title': 'Random Shlok', 'onTap': () => _navigateToRandomShlok(state)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return Semantics(
          button: true,
          label: '${action['title']} feature',
          hint: 'Double tap to open ${action['title']}',
          excludeSemantics: true,
          child: InkWell(
            onTap: action['onTap'] as VoidCallback,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151515) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGold.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(action['icon'] as String, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    action['title'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
