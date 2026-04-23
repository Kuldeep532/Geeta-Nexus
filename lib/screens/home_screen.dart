import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';

import 'search_screen.dart';
import 'random_verse_screen.dart';
import 'wisdom_cards_screen.dart';
import 'affirmations_screen.dart';
import 'reading_plan_screen.dart';
import 'verse_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late dynamic _dailyVerse;

  @override
  void initState() {
    super.initState();
    _dailyVerse = _loadAutomatedVerse();
  }

  dynamic _loadAutomatedVerse() {
    if (allVerses.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return allVerses[dayOfYear % allVerses.length];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  if (state.userName.isNotEmpty) ...[
                    Text(
                      'Namaste, ${state.userName} 🙏',
                      style: GoogleFonts.cinzel(
                        color: kGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildStreakBar(state),
                  const SizedBox(height: 24),
                  _buildDailyVerse(context, _dailyVerse),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Today's Wisdom"),
                  const SizedBox(height: 12),
                  _buildWisdomPreview(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: kBg,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'BHAGAVAD GITA',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1500), kBg],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Search Verses',
          icon: const Icon(Icons.search, color: kGold),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBar(AppState state) {
    return Semantics(
      label: "Progress Overview: Level ${state.level}, Streak ${state.streak} days",
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDivider.withOpacity(0.5)), // FIXED: Removed leading comma
        ),
        child: Row(
          children: [
            _statChip('🔥', '${state.streak}', 'Days'),
            _statChip('📖', '${state.readVerses.length}', 'Verses'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Level ${state.level}',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (state.xp / 100).clamp(0.0, 1.0),
                      backgroundColor: kDivider,
                      color: kGold,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${state.xp} XP', 
                      style: const TextStyle(color: kTextDim, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: kGold, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: kTextDim, fontSize: 9)),
      ],
    );
  }

  Widget _buildDailyVerse(BuildContext context, dynamic verse) {
    if (verse == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: verse)),
      ),
      child: Semantics(
        button: true,
        label: "Daily Verse from Chapter ${verse.chapter}. Tap to read details.",
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A2000), Color(0xFF1A1500)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGoldDim.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('✨ DAILY VERSE',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Ch. ${verse.chapter}',
                      style: const TextStyle(color: kGoldDim, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                verse.sanskrit ?? '',
                style: GoogleFonts.notoSansDevanagari(
                  color: kGoldLight,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"${verse.translation ?? ''}"',
                style: GoogleFonts.crimsonText(
                  color: kText,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.cinzel( // FIXED: Removed leading comma
        color: kGold,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.shuffle, 'label': 'Random', 'color': const Color(0xFF3E2723), 'screen': const RandomVerseScreen()},
      {'icon': Icons.style, 'label': 'Cards', 'color': const Color(0xFF1A237E), 'screen': const WisdomCardsScreen()},
      {'icon': Icons.format_quote, 'label': 'Quotes', 'color': const Color(0xFF311B92), 'screen': const AffirmationsScreen()},
      {'icon': Icons.map, 'label': 'Plan', 'color': const Color(0xFF1B5E20), 'screen': const ReadingPlanScreen()},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget)),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: action['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(action['icon'] as IconData, color: kGold, size: 22),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWisdomPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: kDivider,
            child: Icon(Icons.lightbulb_outline, color: kGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deepen your practice",
                  style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Meditation is the journey of the self, through the self, to the self.",
                  style: TextStyle(color: kTextDim, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
