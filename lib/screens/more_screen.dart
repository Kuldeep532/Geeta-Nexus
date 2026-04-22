import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';

// Screens imports (Ensure these paths are correct in your project)
import 'quiz_screen.dart';
import 'meditation_screen.dart';
import 'breathing_screen.dart';
import 'chants_screen.dart';
import 'journal_screen.dart';
import 'glossary_screen.dart';
import 'bookmarks_screen.dart';
import 'flashcards_screen.dart';
import 'reading_plan_screen.dart';
import 'wisdom_cards_screen.dart';
import 'affirmations_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Optimization: Listen only to necessary changes
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Explore'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Study & Learn'),
              const SizedBox(height: 12),
              _buildGrid(context, [
                _Item('📚', 'Flashcards', 'Master key verses', const FlashcardsScreen()),
                _Item('🎯', 'Quiz', 'Test your knowledge', const QuizScreen()),
                _Item('📖', 'Glossary', 'Sanskrit terms', const GlossaryScreen()),
                _Item('🗺️', 'Reading Plan', '30-day journey', const ReadingPlanScreen()),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Practice'),
              const SizedBox(height: 12),
              _buildGrid(context, [
                _Item('🧘', 'Meditation', 'Sit in stillness', const MeditationScreen()),
                _Item('🌬️', 'Breathing', 'Pranayama practice', const BreathingScreen()),
                _Item('📿', 'Japa Counter', 'Mantra repetition', const ChantsScreen()),
                _Item('✍️', 'Journal', 'Daily reflection', const JournalScreen()),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Inspiration'),
              const SizedBox(height: 12),
              _buildGrid(context, [
                _Item('🃏', 'Wisdom Cards', 'Divine teachings', const WisdomCardsScreen()),
                _Item('✨', 'Affirmations', 'Daily affirmations', const AffirmationsScreen()),
                _Item('🔖', 'Bookmarks', 'Saved verses', const BookmarksScreen()),
              ]),
              const SizedBox(height: 30),
              _buildQuoteCard(),
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t.toUpperCase(),
        style: GoogleFonts.cinzel(
          color: kGold,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      );

  Widget _buildGrid(BuildContext context, List<_Item> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.screen),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12), // FIXED: Faltu comma hataya gaya
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kDivider.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: kText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.subtitle,
                        style: const TextStyle(color: kTextDim, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0020), Color(0xFF100030)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A1A5A)),
      ),
      child: Column(
        children: [
          const Text('🕉️', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            '"Wherever there is Krishna, the master of all mystics, and wherever there is Arjuna, the supreme archer, there will also certainly be opulence, victory, extraordinary power, and morality."',
            style: GoogleFonts.crimsonText(
              color: kText,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '— Bhagavad Gita 18.78',
            style: TextStyle(color: kTextDim, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget screen;

  // FIXED: Variable ke beech mein extra comma hataya gaya
  const _Item(this.emoji, this.title, this.subtitle, this.screen);
}
