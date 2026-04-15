import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLevelCard(state),
            const SizedBox(height: 20),
            _buildStatsGrid(state),
            const SizedBox(height: 20),
            _sectionTitle('Achievements'),
            const SizedBox(height: 12),
            _buildBadges(state),
            const SizedBox(height: 20),
            _sectionTitle('Chapter Progress'),
            const SizedBox(height: 12),
            _buildChapterProgress(state),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.cinzel(
          color: kGold, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8));

  Widget _buildLevelCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGoldDim.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold.withOpacity(0.2),
                  border: Border.all(color: kGold, width: 2),
                ),
                child: Center(
                  child: Text('${state.level}',
                      style: GoogleFonts.cinzel(
                          color: kGold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelTitle(state.level),
                      style: GoogleFonts.cinzel(
                          color: kGold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${state.xp} total XP earned',
                      style: const TextStyle(color: kTextDim, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('🔥',
                      style: const TextStyle(fontSize: 22)),
                  Text('${state.streak}',
                      style: GoogleFonts.cinzel(
                          color: kGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const Text('Streak',
                      style: TextStyle(color: kTextDim, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress to Level ${state.level + 1}',
                  style: const TextStyle(color: kTextDim, fontSize: 12)),
              Text('${state.xpInLevel}/100 XP',
                  style: const TextStyle(color: kGoldDim, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.xpInLevel / 100,
            backgroundColor: kDivider,
            color: kGold,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    const titles = [
      'Seeker', 'Student', 'Devotee', 'Practitioner',
      'Disciple', 'Yogi', 'Sage', 'Master', 'Enlightened', 'Brahman'
    ];
    return titles[(level - 1).clamp(0, titles.length - 1)];
  }

  Widget _buildStatsGrid(AppState state) {
    final stats = [
      {'icon': '📖', 'value': '${state.readVerses.length}', 'label': 'Verses Read'},
      {'icon': '🎯', 'value': '${state.quizScore}', 'label': 'Quiz Correct'},
      {'icon': '📿', 'value': '${state.japaCount}', 'label': 'Japa Count'},
      {'icon': '🧘', 'value': '${state.totalMeditationMinutes}m', 'label': 'Meditation'},
      {'icon': '🔖', 'value': '${state.bookmarks.length}', 'label': 'Bookmarks'},
      {'icon': '✍️', 'value': '${state.journalEntries.length}', 'label': 'Journal Entries'},
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: stats.map((s) {
        return Container(
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kDivider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s['icon']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(s['value']!,
                  style: GoogleFonts.cinzel(
                      color: kGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(s['label']!,
                  style: const TextStyle(color: kTextDim, fontSize: 10),
                  textAlign: TextAlign.center),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadges(AppState state) {
    final badges = state.badges;
    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDivider),
        ),
        child: const Center(
          child: Text(
            'Keep practicing to earn your first badge! 🌟',
            style: TextStyle(color: kTextDim, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: badges.map((b) {
        return Container(
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGoldDim.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(b['icon']!, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(b['name']!,
                  style: GoogleFonts.cinzel(
                      color: kGold, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(b['desc']!,
                    style: const TextStyle(color: kTextDim, fontSize: 9),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChapterProgress(AppState state) {
    return Column(
      children: kChapters.map((ch) {
        final done = state.isChapterCompleted(ch.number);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: done ? kGoldDim : kDivider),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: done ? kGold : kTextDim,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ch. ${ch.number}: ${ch.name}',
                  style: TextStyle(
                      color: done ? kGold : kText,
                      fontSize: 13),
                ),
              ),
              if (done)
                const Text('✓', style: TextStyle(color: kGold, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
