import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/gita_data.dart';
import '../state/app_state.dart';
import 'chapter_detail_screen.dart';

class ReadingPlanScreen extends StatelessWidget {
  const ReadingPlanScreen({super.key});

  static const _plan = [
    {'day': 1, 'chapter': 1, 'focus': "Understand Arjuna's crisis and why dharma matters"},
    {'day': 2, 'chapter': 2, 'focus': 'Learn about the eternal soul and begin karma yoga'},
    {'day': 3, 'chapter': 2, 'focus': 'Memorize verse 2.47 — the essence of karma yoga'},
    {'day': 4, 'chapter': 3, 'focus': 'Practice selfless service in daily actions'},
    {'day': 5, 'chapter': 3, 'focus': 'Reflect on yagna (sacrifice) in your own life'},
    {'day': 6, 'chapter': 4, 'focus': 'Study the mystery of divine incarnation'},
    {'day': 7, 'chapter': 4, 'focus': 'Contemplate: how does knowledge purify?'},
    {'day': 8, 'chapter': 5, 'focus': 'Practice inner renunciation while acting outwardly'},
    {'day': 9, 'chapter': 6, 'focus': 'Begin a 5-minute daily meditation practice'},
    {'day': 10, 'chapter': 6, 'focus': 'Work with the mind — observe without reacting'},
    {'day': 11, 'chapter': 7, 'focus': 'See the divine in all of nature around you'},
    {'day': 12, 'chapter': 8, 'focus': 'Contemplate your own mortality with equanimity'},
    {'day': 13, 'chapter': 9, 'focus': 'Practice offering all your actions to the Divine'},
    {'day': 14, 'chapter': 9, 'focus': 'Memorize verse 9.27 — the yoga of offering'},
    {'day': 15, 'chapter': 10, 'focus': 'Find the divine in everyday beauty and excellence'},
    {'day': 16, 'chapter': 11, 'focus': 'Meditate on the vastness of the cosmic form'},
    {'day': 17, 'chapter': 12, 'focus': 'Cultivate the qualities of a true devotee'},
    {'day': 18, 'chapter': 12, 'focus': 'Practice unconditional kindness to all'},
    {'day': 19, 'chapter': 13, 'focus': 'Distinguish between the body and the observer within'},
    {'day': 20, 'chapter': 14, 'focus': 'Identify the three gunas in your daily reactions'},
    {'day': 21, 'chapter': 14, 'focus': 'Practice rising above your dominant guna today'},
    {'day': 22, 'chapter': 15, 'focus': 'Recognize God as the inner guide in your heart'},
    {'day': 23, 'chapter': 16, 'focus': 'Inventory: which divine qualities do you embody?'},
    {'day': 24, 'chapter': 16, 'focus': 'Actively cultivate one divine quality today'},
    {'day': 25, 'chapter': 17, 'focus': 'Examine the quality of your faith and worship'},
    {'day': 26, 'chapter': 18, 'focus': 'Review all 18 chapters — what stands out?'},
    {'day': 27, 'chapter': 18, 'focus': 'Practice complete surrender for one full day'},
    {'day': 28, 'chapter': 18, 'focus': 'Memorize 18.66 — the supreme secret'},
    {'day': 29, 'chapter': 18, 'focus': 'Share one Gita teaching with someone you love'},
    {'day': 30, 'chapter': 18, 'focus': 'Write your 3 most life-changing insights from the Gita'},
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentDay = state.userCurrentDay ?? 1;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('30-Day Reading Plan'),
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plan.length,
              itemBuilder: (ctx, i) {
                final item = _plan[i];
                final day = item['day'] as int;
                final chapterNum = item['chapter'] as int;

                final chapter = kChapters.firstWhere(
                  (c) => c.number == chapterNum, // FIXED: Removed leading comma
                  orElse: () => kChapters[0],
                );

                final isCompleted = state.isChapterCompleted(chapterNum.toString());
                final isToday = day == currentDay;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterDetailScreen(chapter: chapter),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isToday ? kGold.withOpacity(0.1) : kCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isToday ? kGold : (isCompleted ? kGoldDim : kDivider),
                          width: isToday ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildDayIndicator(day, isToday, isCompleted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDayTitle(day, chapterNum, isToday),
                                const SizedBox(height: 2),
                                Text(
                                  item['focus'] as String,
                                  style: TextStyle(
                                    color: isCompleted ? kTextDim : kText,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: kTextDim, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(int day, bool isToday, bool isCompleted) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? kGold.withOpacity(0.2)
            : isToday
                ? kGold.withOpacity(0.15)
                : kDivider,
        border: Border.all(
          color: isToday ? kGold : (isCompleted ? kGoldDim : kDivider),
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: kGold, size: 18)
            : Text(
                '$day',
                style: GoogleFonts.cinzel(
                  color: isToday ? kGold : kTextDim,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Widget _buildDayTitle(int day, int chapterNum, bool isToday) {
    return Row(
      children: [
        Text(
          'Day $day • Chapter $chapterNum',
          style: TextStyle(
            color: isToday ? kGold : kGoldDim,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'TODAY',
              style: TextStyle( // FIXED: Removed leading comma
                color: kBg,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text('📅', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '30-Day Gita Journey',
                  style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Deepen your practice daily.',
                  style: TextStyle(color: kTextDim, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } // FIXED: Closed the method and class properly
}
