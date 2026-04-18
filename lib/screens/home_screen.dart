import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';
// Screens import
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
    // Build method ke bahar verse set karne se rebuild par data change nahi hoga
    _dailyVerse = getDailyVerse();
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
                  const SizedBox(height: 120), // Bottom padding for scrolling
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
      label: "User Progress Summary",
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDivider.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statChip('🔥', '${state.streak}', 'Days'),
            _statChip('⚡', '${state.xp}', 'XP'),
            _statChip('📖', '${state.readVerses.length}', 'Verses'),
            const SizedBox(width: 8),
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
                      value: (state.xpInLevel / 100).clamp(0.0, 1.0),
                      backgroundColor: kDivider,
                      color: kGold,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${state.xpInLevel}/100 XP',
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
    return Semantics(
      label: "$label: $value",
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: kGold, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: const TextStyle(color: kTextDim, fontSize: 9)),
          ],
        ),
      ),
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
        label: "Verse of the Day. Chapter ${verse.chapter}. Double tap to read.",
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
                  Text('✨ VERSE OF THE DAY',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Chapter ${verse.chapter}',
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
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, color: kGoldDim, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return ExcludeSemantics(
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cinzel(
            color: kGold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.shuffle, 'label': 'Random', 'color': const Color(0xFF4A3000), 'screen': const RandomVerseScreen()},
      {'icon': Icons.style, 'label': 'Cards', 'color': const Color(0xFF003040), 'screen': const WisdomCardsScreen()},
      {'icon': Icons.format_quote, 'label': 'Quotes', 'color': const Color(0xFF300040), 'screen': const AffirmationsScreen()},
      {'icon': Icons.map, 'label': 'Plan', 'color': const Color(0xFF003020), 'screen': const ReadingPlanScreen()},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget)),
              borderRadius: BorderRadius.circular(12),
              child: Semantics(
                label: "Go to ${action['label']}",
                button: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: action['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kDivider.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(action['icon'] as IconData, color: kGold, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDivider.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.AutoAwesome, color: kGoldDim, size: 24),
          const SizedBox(height: 12),
          Text(
            "Wisdom is the reward for surviving our own mistakes.",
            textAlign: TextAlign.center,
            style: GoogleFonts.crimsonText(color: kTextDim, fontSize: 15, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
