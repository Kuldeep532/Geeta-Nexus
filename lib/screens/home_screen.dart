import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';
import '../models/models.dart'; 

// Purani aur nayi saari screens ka shudh import yahan hai:
import 'search_screen.dart';
import '../models/scripture_model.dart';
import 'scripture_verse_detail_screen.dart';
import 'random_verse_screen.dart';
import 'wisdom_cards_screen.dart';
import 'scripture_library_screen.dart';

// Tumhari gusse wali missing screens jo ab sahi jagah par hain:
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

importt _HomeScreenState extends State<HomeScreen> {
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
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
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
                  _buildQuickActions(context, isDark), // Ab iske andar saari screens fit hain
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

  Widget _buildLibraryCard(BuildContext context, bool isDark) {
    return Semantics(
      button: true,
      label: 'Scripture Library. Explore all religious and spiritual texts.',
      hint: 'Double tap to open Library',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const ScriptureLibraryScreen())
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: kGold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: kGold, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories, color: kGold, size: 24),
              const SizedBox(width: 12),
              Text(
                'SCRIPTURE LIBRARY', 
                style: GoogleFonts.cinzel(
                  color: kGold, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 15,
                  letterSpacing: 1.2
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Semantics(
      header: true,
      child: Text(
        title.toUpperCase(), 
        style: GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.bold, color: kGold, letterSpacing: 1.2)
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        // Purani Actions Screens
        _actionCard(context, 'Search', Icons.search, const SearchScreen(), isDark),
        _actionCard(context, 'Random', Icons.casino, const RandomVerseScreen(), isDark),
        _actionCard(context, 'Wisdom', Icons.auto_awesome, const WisdomCardsScreen(), isDark),
        
        // Tumhari saari nayi bhatki hui screens ab line se ekdum sahi jagah par hain:
        _actionCard(context, 'Affirm', Icons.favorite, const AffirmationsScreen(), isDark),
        _actionCard(context, 'Astrology', Icons.brightness_3, const AstrologyScreen(), isDark),
        _actionCard(context, 'Chants', Icons.spatial_audio_off, const ChantsScreen(), isDark),
        _actionCard(context, 'Bookmarks', Icons.bookmark, const BookmarksScreen(), isDark),
        _actionCard(context, 'Breathing', Icons.air, const BreathingScreen(), isDark),
        _actionCard(context, 'Voice Practice', Icons.mic, const GeetaVoicePracticeScreen(), isDark),
        _actionCard(context, 'Glossary', Icons.g_translate, const GlossaryScreen(), isDark),
        _actionCard(context, 'Journal', Icons.edit_note, const JournalScreen(), isDark),
        _actionCard(context, 'Meditation', Icons.spa, const MeditationScreen(), isDark),
        _actionCard(context, 'Reading Plan', Icons.calendar_month, const ReadingPlanScreen(), isDark),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String title, IconData icon, Widget target, bool isDark) {
    return Semantics(
      button: true,
      label: '$title Button',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1500) : const Color(0xFFFFF9E5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: kGold.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(child: Icon(icon, color: kGold, size: 20)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title, 
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
