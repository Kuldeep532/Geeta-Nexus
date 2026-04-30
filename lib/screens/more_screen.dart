import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'astrology_screen.dart';
import 'about_screen.dart';
import 'breathing_screen.dart';
import 'chants_screen.dart';
import 'contact_screen.dart';
import 'flashcards_screen.dart';
import 'geeta_voice_practice_screen.dart';
import 'glossary_screen.dart';
import 'journal_screen.dart';
import 'meditation_screen.dart';
import 'privacy_policy_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';
import 'reading_plan_screen.dart';
import 'terms_screen.dart';

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

  Widget _buildAccountCard(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final accountName = appState.userName.isNotEmpty ? appState.userName : 'Not connected';
    final accountEmail = appState.userEmail.isNotEmpty
        ? appState.userEmail
        : 'Connect Google or email sign-in';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
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
                  : appState.isEmailAccountLinked
                      ? cs.primary.withOpacity(0.15)
                  : cs.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appState.isGoogleAccountLinked
                  ? 'Google Linked'
                  : appState.isEmailAccountLinked
                      ? 'Email Linked'
                      : 'Local Profile',
              style: TextStyle(
                color: appState.isGoogleAccountLinked
                    ? cs.secondary
                    : appState.isEmailAccountLinked
                        ? cs.primary
                        : cs.onSurface.withOpacity(0.6),
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
              _sectionTitle('Legal & Support', context),
              const SizedBox(height: 12),
              _buildGrid(context, [
                _Item('👤', 'Profile', 'Manage linked account', const ProfileScreen()),
                _Item('ℹ️', 'About Us', 'App mission & version', const AboutScreen()),
                _Item('🔐', 'Privacy Policy', 'How your data is handled', const PrivacyPolicyScreen()),
                _Item('📜', 'Terms', 'Terms and conditions', const TermsScreen()),
                _Item('✉️', 'Contact Us', 'Reach support team', const ContactScreen()),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Profile Account', context),
              const SizedBox(height: 12),
              Semantics(
                label: 'Profile account details',
                child: _buildAccountCard(context, appState),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  _appVersionLabel,
                  style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12),
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
          color: Theme.of(context).colorScheme.primary,
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
    return Semantics(
      button: true,
      label: '${item.title}: ${item.subtitle}',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
        child: Card(
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
