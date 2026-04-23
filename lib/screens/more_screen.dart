import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

// IMPORTANT: Replace this with the actual path to your color constants
// if they are defined in a file like 'lib/constants/colors.dart'
import '../constants.dart'; 

import '../state/app_state.dart';
import 'about_screen.dart';
import 'affirmations_screen.dart';
import 'bookmarks_screen.dart';
import 'breathing_screen.dart';
import 'chants_screen.dart';
import 'contact_screen.dart';
import 'flashcards_screen.dart';
import 'astrology_screen.dart';
import 'reading_plan_screen.dart';
import 'wisdom_cards_screen.dart';
import 'geeta_voice_practice_screen.dart';
import 'glossary_screen.dart';
import 'journal_screen.dart';
import 'meditation_screen.dart';
import 'privacy_policy_screen.dart';
import 'quiz_screen.dart';
import 'terms_screen.dart';
import 'updates_screen.dart';
import 'notifications_screen.dart';
import 'social_links.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _appVersionLabel = 'Loading version...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersionLabel = 'v${info.version}+${info.buildNumber}';
    });
  }

  Future<void> _pickTheme(BuildContext context, AppState state) async {
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: [
          _themeOption(ctx, 'Automatic (system)', '🌓', ThemeMode.system, state.themeMode),
          _themeOption(ctx, 'Light', '☀️', ThemeMode.light, state.themeMode),
          _themeOption(ctx, 'Dark', '🌙', ThemeMode.dark, state.themeMode),
        ],
      ),
    );
    if (picked != null) state.setThemeMode(picked);
  }

  Widget _themeOption(BuildContext context, String label, String emoji, ThemeMode mode, ThemeMode current) {
    final cs = Theme.of(context).colorScheme;
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, mode),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (current == mode) Icon(Icons.check, color: cs.primary, size: 20),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, AppState state) async {
    final controller = TextEditingController(text: state.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null) state.setUserName(result);
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
            // REMOVED 'const' because kGold is dynamic
            child: Icon(Icons.account_circle, color: kGold, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: TextStyle(
                    color: kText, // REMOVED 'const' from parent TextStyle
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountEmail,
                  style: TextStyle(color: kTextDim, fontSize: 12),
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

  // Rest of the UI building methods (_sectionTitle, _buildGrid, _buildInfoTile, etc.)
  // should follow similar logic ensuring 'const' is not used with custom color variables.
  
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
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
                _Item('🔭', 'Astrology', 'Kundli & horoscope', const AstrologyScreen()),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Practice'),
              const SizedBox(height: 12),
              _buildGrid(context, [
                _Item('🧘', 'Meditation', 'Sit in stillness', const MeditationScreen()),
                _Item('🌬️', 'Breathing', 'Pranayama practice', const BreathingScreen()),
                _Item('📿', 'Japa Counter', 'Mantra repetition', const ChantsScreen()),
                _Item('✍️', 'Journal', 'Daily reflection', const JournalScreen()),
                _Item('🎙️', 'Voice Practice', 'Recite with feedback', const GeetaVoicePracticeScreen()),
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
              Semantics(
                label: 'Profile account details',
                child: _buildAccountCard(appState),
              ),
              const SizedBox(height: 24),
              // ... Add remaining settings tiles here
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper methods for Titles and Grid would be defined below...
  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  
  Widget _buildGrid(BuildContext context, List<_Item> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCard(context, items[index]),
    );
  }

  Widget _buildCard(BuildContext context, _Item item) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
      child: Card(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(item.emoji), Text(item.title)]))),
    );
  }
}

class _Item {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget screen;
  const _Item(this.emoji, this.title, this.subtitle, this.screen);
}
