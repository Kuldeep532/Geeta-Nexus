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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dailyVerse = getDailyVerse();

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: kBg,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Bhagavad Gita',
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
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
                icon: const Icon(Icons.search, color: kGold),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchScreen())),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreakBar(context, state),
                  const SizedBox(height: 20),
                  _buildDailyVerse(context, dailyVerse),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Today\'s Wisdom'),
                  const SizedBox(height: 12),
                  _buildWisdomPreview(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          _statChip('🔥', '${state.streak}', 'Day Streak'),
          const SizedBox(width: 12),
          _statChip('⚡', '${state.xp}', 'XP'),
          const SizedBox(width: 12),
          _statChip('📖', '${state.readVerses.length}', 'Verses'),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Level ${state.level}',
                  style: GoogleFonts.cinzel(
                      color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: LinearProgressIndicator(
                  value: state.xpInLevel / 100,
                  backgroundColor: kDivider,
                  color: kGold,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 2),
              Text('${state.xpInLevel}/100 XP',
                  style: const TextStyle(color: kTextDim, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(value,
            style: const TextStyle(
                color: kGold, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(color: kTextDim, fontSize: 10)),
      ],
    );
  }

  Widget _buildDailyVerse(BuildContext context, verse) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: verse))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2000), Color(0xFF1A1500)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGoldDim.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kGoldDim),
                  ),
                  child: Text('✨ Verse of the Day',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 11, letterSpacing: 0.5)),
                ),
                const Spacer(),
                Text('${verse.id}',
                    style: const TextStyle(color: kGoldDim, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              verse.sanskrit.split('\n').first,
              style: GoogleFonts.notoSansDevanagari(
                color: kGoldLight,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '"${verse.translation}"',
              style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: (verse.keywords as List<String>).take(3).map((k) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(k,
                      style:
                          const TextStyle(color: kGoldDim, fontSize: 11)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Tap to read more →',
                    style:
                        const TextStyle(color: kGoldDim, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cinzel(
          color: kGold, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.shuffle, 'label': 'Random\nVerse', 'color': const Color(0xFF4A3000)},
      {'icon': Icons.style, 'label': 'Wisdom\nCards', 'color': const Color(0xFF003040)},
      {'icon': Icons.format_quote, 'label': 'Affir-\nmations', 'color': const Color(0xFF300040)},
      {'icon': Icons.map, 'label': 'Reading\nPlan', 'color': const Color(0xFF003020)},
    ];

    final screens = [
      () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const RandomVerseScreen())),
      () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const WisdomCardsScreen())),
      () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AffirmationsScreen())),
      () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ReadingPlanScreen())),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(actions.length, (i) {
        final a = actions[i];
        return GestureDetector(
          onTap: screens[i],
          child: Container(
            decoration: BoxDecoration(
              color: a['color'] as Color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kDivider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a['icon'] as IconData, color: kGold, size: 24),
                const SizedBox(height: 6),
                Text(
                  a['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kText, fontSize: 10, height: 1.3),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWisdomPreview(BuildContext context) {
    final card = kWisdomCards.first;
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const WisdomCardsScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF001A30), Color(0xFF001020)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1A4060)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Color(0xFF4AA8FF), size: 18),
                const SizedBox(width: 8),
                Text(card['title']!,
                    style: GoogleFonts.cinzel(
                        color: const Color(0xFF4AA8FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Text(card['wisdom']!,
                style: GoogleFonts.crimsonText(
                    color: kText, fontSize: 14, height: 1.6),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('Gita ${card["verse"]}',
                style: const TextStyle(color: kTextDim, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
