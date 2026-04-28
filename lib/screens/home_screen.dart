import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';
import '../models/models.dart'; 

// Screens imports
import 'search_screen.dart';
import 'verse_detail_screen.dart';
import 'random_verse_screen.dart';
import 'wisdom_cards_screen.dart';
import 'affirmations_screen.dart';

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
    // AppState ke initialize hone ke baad verse load hoga
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning · Jai Shri Krishna';
    if (hour >= 12 && hour < 17) return 'Good Afternoon · Jai Shri Krishna';
    if (hour >= 17 && hour < 21) return 'Good Evening · Jai Shri Krishna';
    return 'Good Night · Hare Krishna';
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
                  const SizedBox(height: 32),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, isDark),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
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
        _actionCard(context, 'Search', Icons.search, const SearchScreen(), isDark),
        _actionCard(context, 'Random', Icons.casino, const RandomVerseScreen(), isDark),
        _actionCard(context, 'Wisdom', Icons.auto_awesome, const WisdomCardsScreen(), isDark),
        _actionCard(context, 'Affirm', Icons.favorite, const AffirmationsScreen(), isDark),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String title, IconData icon, Widget target, bool isDark) {
    return InkWell(
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
            Icon(icon, color: kGold, size: 20),
            const SizedBox(width: 10),
            Text(title, style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
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
      title: Text('BHAGAVAD GITA', style: GoogleFonts.cinzel(color: kGold, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildGreetingSection(AppState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_getGreeting(), style: GoogleFonts.crimsonText(color: isDark ? kGoldLight : kGoldDim, fontSize: 18, fontStyle: FontStyle.italic)),
        if (state.userName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Namaste, ${state.userName}', style: GoogleFonts.cinzel(color: kGold, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildStreakBar(AppState state, bool isDark, ThemeData theme) {
    return Container(
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
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(children: [Text(icon), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: kGold)), Text(label, style: const TextStyle(fontSize: 10))]);
  }

  Widget _buildDailyVerseCard(BuildContext context, Verse verse, bool isDark, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: verse))),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: kGold, letterSpacing: 1.2));
  }
}
