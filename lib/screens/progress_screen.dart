import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart'; // Ensure kChapters is imported

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    
    // Logic constants
    const int totalVersesTarget = 700;
    const int xpPerChapterBonus = 1000;
    final int completedVerses = state.readVerses.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('SPIRITUAL PROGRESS', 
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 1. Level & XP Overview
          _buildLevelCard(state, theme),
          const SizedBox(height: 30),
          
          // 2. Total Verses Tracker (New Logic)
          _buildSectionHeader('Overall Progress'),
          const SizedBox(height: 12),
          _buildVersesProgress(completedVerses, totalVersesTarget, theme),
          
          const SizedBox(height: 30),
          
          // 3. Chapter Progress with XP Bonus
          _buildSectionHeader('Chapter Mastery'),
          const SizedBox(height: 12),
          _buildChapterList(state, theme, xpPerChapterBonus),
          
          const SizedBox(height: 100), 
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
    );
  }

  Widget _buildVersesProgress(int completed, int total, ThemeData theme) {
    final double progress = (completed / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Verses Completed', style: TextStyle(color: Colors.grey)),
              Text('$completed / $total', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, color: kGold, backgroundColor: kGold.withOpacity(0.1), minHeight: 8),
        ],
      ),
    );
  }

  Widget _buildChapterList(AppState state, ThemeData theme, int bonus) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kChapters.length,
      itemBuilder: (context, i) {
        final ch = kChapters[i];
        final bool isDone = state.isChapterCompleted(ch.number.toString());
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDone ? kGold.withOpacity(0.4) : theme.dividerColor),
          ),
          child: ListTile(
            leading: Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? kGold : Colors.grey),
            title: Text('Chapter ${ch.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(isDone ? "Bonus $bonus XP Claimed" : "Complete for $bonus XP Bonus", 
              style: TextStyle(fontSize: 11, color: isDone ? kGold : Colors.grey)),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(AppState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 35, backgroundColor: kGold.withOpacity(0.1), child: Text('${state.level}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spiritual Rank', style: TextStyle(color: theme.hintColor)),
              Text(state.level.toString(), style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: kGold)),
              Text('Total XP: ${state.xp}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
