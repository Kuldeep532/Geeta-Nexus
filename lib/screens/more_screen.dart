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
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'contact_screen.dart';
import 'updates_screen.dart';
import 'social_links.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _pickTheme(BuildContext context, AppState state) async {
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: [
          _themeOption(ctx, 'Automatic (system)', '🌓', ThemeMode.system,
              state.themeMode),
          _themeOption(ctx, 'Light', '☀️', ThemeMode.light, state.themeMode),
          _themeOption(ctx, 'Dark', '🌙', ThemeMode.dark, state.themeMode),
        ],
      ),
    );
    if (picked != null) state.setThemeMode(picked);
  }

  Widget _themeOption(BuildContext context, String label, String emoji,
      ThemeMode mode, ThemeMode current) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, mode),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (current == mode)
            const Icon(Icons.check, color: kGold, size: 20),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, AppState state) async {
    final controller = TextEditingController(text: state.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Your Name', style: TextStyle(color: kGold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: kText),
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: kTextDim),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      state.setUserName(result);
    }
  }



  Widget _buildAccountCard(AppState appState) {
    final accountName = appState.userName.isNotEmpty ? appState.userName : 'Not connected';
    final accountEmail = appState.userEmail.isNotEmpty
        ? appState.userEmail
        : 'Connect Google sign-in from onboarding';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: kGold.withOpacity(0.14),
            child: const Icon(Icons.account_circle, color: kGold, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: const TextStyle(
                    color: kText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountEmail,
                  style: const TextStyle(color: kTextDim, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: appState.isGoogleAccountLinked
                  ? Colors.green.withOpacity(0.18)
                  : kDivider.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appState.isGoogleAccountLinked ? 'Google Linked' : 'Local Profile',
              style: TextStyle(
                color: appState.isGoogleAccountLinked ? Colors.greenAccent : kTextDim,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 24),
              _sectionTitle('Profile Account'),
              const SizedBox(height: 12),
              _buildAccountCard(appState),
              const SizedBox(height: 24),
              _sectionTitle('Settings & Info'),
              const SizedBox(height: 12),
              _buildInfoTile(
                emoji: '👤',
                title: appState.userName.isEmpty
                    ? 'Set your name'
                    : appState.userName,
                subtitle: 'Tap to edit',
                onTap: () => _editName(context, appState),
              ),
              _buildInfoTile(
                emoji: appState.themeMode == ThemeMode.dark
                    ? '🌙'
                    : appState.themeMode == ThemeMode.light
                        ? '☀️'
                        : '🌓',
                title: 'Theme',
                subtitle: appState.themeMode == ThemeMode.dark
                    ? 'Dark'
                    : appState.themeMode == ThemeMode.light
                        ? 'Light'
                        : 'Automatic (system)',
                onTap: () => _pickTheme(context, appState),
              ),
              _buildInfoTile(
                emoji: '⬆️',
                title: 'Check for Updates',
                subtitle: 'Auto-checks on app open',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UpdatesScreen())),
              ),
              _buildInfoTile(
                emoji: '✉️',
                title: 'Contact Us',
                subtitle: 'Send a message',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ContactScreen())),
              ),
              _buildInfoTile(
                emoji: '🛡️',
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen())),
              ),
              _buildInfoTile(
                emoji: '📜',
                title: 'Terms & Conditions',
                subtitle: 'Rules of use',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TermsScreen())),
              ),
              _buildInfoTile(
                emoji: 'ℹ️',
                title: 'About',
                subtitle: 'About this app',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Follow Us'),
              const SizedBox(height: 12),
              const SocialLinksRow(),
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
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration( // FIXED: Extra comma removed before BoxDecoration
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

  Widget _buildInfoTile({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kDivider.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: kText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style:
                            const TextStyle(color: kTextDim, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kTextDim),
            ],
          ),
        ),
      ),
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

  const _Item(this.emoji, this.title, this.subtitle, this.screen); // FIXED: Removed extra comma before this.screen
}
