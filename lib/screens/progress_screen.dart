import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/gita_data.dart';
import '../state/app_state.dart';
import '../theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const int _totalVersesTarget = 700;
  static const int _xpPerChapterBonus = 1000;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final ThemeData theme = Theme.of(context);

    final int completedVerses = state.readVerses.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Semantics(
          header: true,
          child: Text(
            'Spiritual Progress',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            children: [
              // 1. Level & XP Overview
              _buildLevelCard(context, state, theme),

              const SizedBox(height: 30),

              // 2. Total Verses Tracker
              _buildSectionHeader(
                context,
                title: 'Overall Progress',
              ),

              const SizedBox(height: 12),

              _buildVersesProgress(
                context,
                completed: completedVerses,
                total: _totalVersesTarget,
                theme: theme,
              ),

              const SizedBox(height: 30),

              // 3. Chapter Progress
              _buildSectionHeader(
                context,
                title: 'Chapter Mastery',
              ),

              const SizedBox(height: 12),

              _buildChapterList(
                context,
                state,
                theme,
                _xpPerChapterBonus,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
  }) {
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

  Widget _buildVersesProgress(
    BuildContext context, {
    required int completed,
    required int total,
    required ThemeData theme,
  }) {
    final double progress = total == 0
        ? 0
        : (completed / total).clamp(0.0, 1.0);

    final int progressPercent = (progress * 100).round();

    return Semantics(
      container: true,
      label:
          'Overall verses progress. $completed out of $total verses completed. '
          '$progressPercent percent complete.',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              children: [
                Text(
                  'Verses Completed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$completed / $total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: kGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                color: kGold,
                backgroundColor: kGold.withOpacity(0.15),
                semanticsLabel: 'Verse completion progress bar',
                semanticsValue: '$progressPercent percent completed',
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '$progressPercent% completed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterList(
    BuildContext context,
    AppState state,
    ThemeData theme,
    int bonus,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kChapters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final chapter = kChapters[index];

        final bool isDone = state.isChapterCompleted(
          chapter.number.toString(),
        );

        return Semantics(
          container: true,
          button: false,
          label: isDone
              ? 'Chapter ${chapter.number} completed. '
                  'Bonus $bonus experience points claimed.'
              : 'Chapter ${chapter.number} not completed. '
                  'Complete to earn $bonus experience points.',
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDone
                    ? kGold.withOpacity(0.45)
                    : theme.dividerColor,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: ExcludeSemantics(
                child: Icon(
                  isDone
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isDone ? kGold : theme.disabledColor,
                  size: 28,
                ),
              ),
              title: Text(
                'Chapter ${chapter.number}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isDone
                      ? 'Bonus $bonus XP claimed'
                      : 'Complete for $bonus XP bonus',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDone ? kGold : theme.hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing: Tooltip(
                message: isDone
                    ? 'Chapter completed'
                    : 'Chapter incomplete',
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right,
                    color: theme.hintColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    AppState state,
    ThemeData theme,
  ) {
    return Semantics(
      container: true,
      label:
          'Spiritual rank card. Current level ${state.level}. '
          'Total experience points ${state.xp}.',
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: kGold.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: kGold.withOpacity(0.12),
                child: Text(
                  '${state.level}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kGold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spiritual Rank',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Level ${state.level}',
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kGold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Total XP: ${state.xp}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
