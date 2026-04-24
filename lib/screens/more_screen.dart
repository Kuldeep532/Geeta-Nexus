import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'meditation_screen.dart';
import 'journal_screen.dart';
import 'astrology_screen.dart';
import 'reading_plan_screen.dart';
import 'about_screen.dart';
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
import 'profile_screen.dart';
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

  // --- Theme Selection ---
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

  // --- Account Card ---
  Widget _buildAccountCard(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final accountName = appState.userName.isNotEmpty ? appState.userName : 'Not connected';
    final accountEmail = appState.userEmail.isNotEmpty
        ? appState.userEmail
        : 'Connect Google sign-in';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color, // Uses kCard from theme.dart
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primary.withOpacity(0.14),
            child: Icon(Icons.account_circle, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountEmail,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: appState.isGoogleAccountLinked
                  ? Colors.green.withOpacity(0.18)
                  : cs.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appState.isGoogleAccountLinked ? 'Google Linked' : 'Local Profile',
              style: TextStyle(
                color: appState.isGoogleAccountLinked ? cs.secondary : cs.onSurface.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Text('Explore'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _pickTheme(context, appState),
            tooltip: 'Change Theme',
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
<<<<<<< codex/add-google-login-option-fx4gi5
              _sectionTitle('Profile Account'),
              const SizedBox(height: 12),
              Semantics(
                label: 'Profile account details',
                child: _buildAccountCard(appState),
              ),
              const SizedBox(height: 8),
              _buildInfoTile(
                emoji: 'P',
                title: 'Open Profile',
                subtitle: 'Manage account and logout',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Main Features'),
              const SizedBox(height: 12),
              _buildInfoTile(
                emoji: '📚',
                title: 'Reading Plan',
                subtitle: '30-day guided journey',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReadingPlanScreen()),
                ),
              ),
              _buildInfoTile(
                emoji: '🧘',
                title: 'Meditation',
                subtitle: 'Sit in stillness',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeditationScreen()),
                ),
              ),
              _buildInfoTile(
                emoji: '✍️',
                title: 'Journal',
                subtitle: 'Daily reflection',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JournalScreen()),
                ),
              ),
              _buildInfoTile(
                emoji: '🔭',
                title: 'Astrology',
                subtitle: 'Kundli and horoscope',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AstrologyScreen()),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Settings & Info'),
              const SizedBox(height: 12),
              _buildInfoTile(
                emoji: 'A',
                title: 'App Version',
                subtitle: _appVersionLabel,
                onTap: () {},
              ),
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
                emoji: 'N',
                title: 'Notifications',
                subtitle: appState.unreadNotificationCount == 0
                    ? 'No unread notifications'
                    : '${appState.unreadNotificationCount} unread notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
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
=======
              _sectionTitle('Study & Learn', context),
              const SizedBox(height: 12),
              _buildGrid(context, [
                _Item('📚', 'Flashcards', 'Master key verses', const FlashcardsScreen()),
                _Item('🎯', 'Quiz', 'Test your knowledge', const QuizScreen()),
                _Item('📖', 'Glossary', 'Sanskrit terms', const GlossaryScreen()),
                _Item('🗺️', 'Reading Plan', '30-day journey', const ReadingPlanScreen()),
                _Item('🔭', 'Astrology', 'Kundli & horoscope', const AstrologyScreen()),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Practice', context),
              const SizedBox(height: 12),
              _buildGrid(context, [
                _Item('🧘', 'Meditation', 'Sit in stillness', const MeditationScreen()),
                _Item('🌬️', 'Breathing', 'Pranayama practice', const BreathingScreen()),
                _Item('📿', 'Japa Counter', 'Mantra repetition', const ChantsScreen()),
                _Item('✍️', 'Journal', 'Daily reflection', const JournalScreen()),
                _Item('🎙️', 'Voice Practice', 'Recite with feedback', const GeetaVoicePracticeScreen()),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Profile Account', context),
              const SizedBox(height: 12),
              Semantics(
                label: 'Profile account details',
                child: _buildAccountCard(context, appState),
>>>>>>> main
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  _appVersionLabel, 
                  style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) => Text(
    title, 
    style: TextStyle(
      fontSize: 18, 
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary, // Dynamically uses kGold
    ),
  );

  Widget _buildGrid(BuildContext context, List<_Item> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          crossAxisSpacing: 10, 
          mainAxisSpacing: 10, 
          childAspectRatio: 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCard(context, items[index]),
    );
  }

  Widget _buildCard(BuildContext context, _Item item) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${item.title}: ${item.subtitle}',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
        child: Card(
          // Card color and shape are already defined in your buildTheme()
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  item.title, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
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
