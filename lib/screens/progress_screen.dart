import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('MY SPIRITUAL PROGRESS', 
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildLevelCard(state, theme),
          const SizedBox(height: 30),
          _buildSectionHeader('Your Statistics'),
          const SizedBox(height: 12),
          _buildStatsGrid(state, theme),
          const SizedBox(height: 30),
          _buildSectionHeader('Achievements'),
          const SizedBox(height: 12),
          _buildBadges(state, theme),
          const SizedBox(height: 30),
          _buildSectionHeader('Chapter Progress'),
          const SizedBox(height: 12),
          _buildChapterList(state, theme),
          const SizedBox(height: 100), // Space for FAB or Bottom Nav
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Semantics(
      header: true,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cinzel(
          color: kGold,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildLevelCard(AppState state, ThemeData theme) {
    const int xpPerLevel = 100;
    final double progress = state.xpinLevel; 
    final String levelTitle = _getLevelTitle(state.level);

    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Semantics(
        label: "Current Rank: $levelTitle. Level: ${state.level}. Total Experience: ${state.xp} points.",
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.brightness == Brightness.dark 
                ? [const Color(0xFF332600), const Color(0xFF1A1500)]
                : [const Color(0xFFFFF9E6), const Color(0xFFFFF1C1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kGold.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
            ]
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildLevelBadge(state.level),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(levelTitle, 
                          style: GoogleFonts.cinzel(color: kGold, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Total XP: ${state.xp}', 
                          style: TextStyle(color: theme.hintColor, fontSize: 14)),
                      ],
                    ),
                  ),
                  _buildStreakWidget(state.streak),
                ],
              ),
              const SizedBox(height: 25),
              _buildProgressSection((state.xp % xpPerLevel), xpPerLevel, progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(int level) {
    return Container(
      width: 70, height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kGold.withOpacity(0.1),
        border: Border.all(color: kGold, width: 2.5),
      ),
      child: Center(
        child: Text('$level', 
          style: GoogleFonts.cinzel(color: kGold, fontSize: 28, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProgressSection(int current, int max, double value) {
    return Semantics(
      label: "Progress to next level: ${(value * 100).toInt()} percent.",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Level Progress', style: TextStyle(color: kTextDim, fontSize: 13)),
              Text('$current / $max XP', 
                style: const TextStyle(color: kGoldDim, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: kDivider.withOpacity(0.2),
              color: kGold,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakWidget(int streak) {
    return Column(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 26)),
        Text('$streak', 
          style: GoogleFonts.cinzel(color: kGold, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getLevelTitle(int level) {
    const titles = ['Seeker', 'Student', 'Devotee', 'Practitioner', 'Disciple', 'Yogi', 'Sage', 'Master', 'Enlightened', 'Brahman'];
    return titles[(level - 1).clamp(0, titles.length - 1)];
  }

  Widget _buildStatsGrid(AppState state, ThemeData theme) {
    final stats = [
      {'label': 'Verses Read', 'value': '${state.readVerses.length}', 'icon': '📖'},
      {'label': 'Meditation', 'value': '${state.totalMeditationMinutes}m', 'icon': '🧘'},
      {'label': 'Japa Count', 'value': '${state.japaCount}', 'icon': '📿'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        crossAxisSpacing: 12, 
        mainAxisSpacing: 12, 
        childAspectRatio: 0.85,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) => Semantics(
        label: "${stats[i]['label']}: ${stats[i]['value']}",
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kDivider.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stats[i]['icon']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(stats[i]['value']!, 
                style: GoogleFonts.cinzel(color: kGold, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(stats[i]['label']!, 
                style: const TextStyle(color: kTextDim, fontSize: 10), 
                textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadges(AppState state, ThemeData theme) {
    if (state.badges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Start your journey to earn badges.", style: TextStyle(color: kTextDim)),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.badges.length,
        itemBuilder: (context, i) {
          final String badgeName = state.badges[i];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: theme.cardColor, 
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kGold.withOpacity(0.2))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎖️', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(badgeName, 
                  style: const TextStyle(color: kGold, fontSize: 12, fontWeight: FontWeight.w600), 
                  textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChapterList(AppState state, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kChapters.length,
      itemBuilder: (context, i) {
        final ch = kChapters[i];
        final bool isDone = state.isChapterCompleted(ch.number);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDone ? kGold.withOpacity(0.5) : kDivider.withOpacity(0.3)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDone ? kGold.withOpacity(0.2) : Colors.transparent,
              child: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked, 
                color: isDone ? kGold : kTextDim
              ),
            ),
            title: Text('Chapter ${ch.number}', 
              style: TextStyle(color: isDone ? kGold : theme.textTheme.bodyLarge?.color, fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(ch.name, style: const TextStyle(color: kTextDim, fontSize: 13)),
            trailing: isDone 
              ? const Text('+100 XP', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))
              : null,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        );
      },
    );
  }
}
