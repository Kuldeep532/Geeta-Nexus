import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
// Saari screens ke imports
import 'flashcards_screen.dart';
import 'quiz_screen.dart';
import 'glossary_screen.dart';
import 'reading_plan_screen.dart';
import 'astrology_screen.dart';
import 'meditation_screen.dart';
import 'breathing_screen.dart';
import 'chants_screen.dart';
import 'journal_screen.dart';
import 'geeta_voice_practice_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'contact_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _appVersionLabel = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersionLabel = 'Version ${info.version} (${info.buildNumber})';
      });
    } catch (e) {
      if (mounted) setState(() => _appVersionLabel = 'Version info unavailable');
    }
  }

  void _pickTheme(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('System Default'),
            onTap: () {
              state.updateTheme(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light Mode'),
            onTap: () {
              state.updateTheme(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            onTap: () {
              state.updateTheme(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore & Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _pickTheme(context, appState),
            tooltip: 'Change theme',
          )
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountCard(context, appState),
                const SizedBox(height: 24),
                
                const _SectionHeader(title: 'Study & Learn'),
                _buildAccessibleGrid(context, [
                  _Item('📚', 'Flashcards', 'Master key verses', const FlashcardsScreen()),
                  _Item('🎯', 'Quiz', 'Test your knowledge', const QuizScreen()),
                  _Item('📖', 'Glossary', 'Sanskrit terms', const GlossaryScreen()),
                  _Item('🗺️', 'Reading Plan', '30-day journey', const ReadingPlanScreen()),
                  _Item('🔭', 'Astrology', 'Kundli & horoscope', const AstrologyScreen()),
                ]),

                const SizedBox(height: 24),
                const _SectionHeader(title: 'Spiritual Practice'),
                _buildAccessibleGrid(context, [
                  _Item('🧘', 'Meditation', 'Guided stillness', const MeditationScreen()),
                  _Item('🌬️', 'Breathing', 'Pranayama sessions', const BreathingScreen()),
                  _Item('📿', 'Japa Counter', 'Mantra chanting', const ChantsScreen()),
                  _Item('✍️', 'Journal', 'Reflect on your day', const JournalScreen()),
                  _Item('🎙️', 'Voice Practice', 'Recitation feedback', const GeetaVoicePracticeScreen()),
                ]),

                const SizedBox(height: 24),
                const _SectionHeader(title: 'Support & Legal'),
                _buildAccessibleGrid(context, [
                  _Item('👤', 'Profile', 'Account settings', const ProfileScreen()),
                  _Item('ℹ️', 'About', 'App information', const AboutScreen()),
                  _Item('🔐', 'Privacy', 'Data protection', const PrivacyPolicyScreen()),
                  _Item('📜', 'Terms', 'User agreement', const TermsScreen()),
                  _Item('✉️', 'Contact', 'Get help', const ContactScreen()),
                ]),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    _appVersionLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, AppState appState) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.person, color: cs.onPrimaryContainer),
        ),
        title: Text(appState.userName.isEmpty ? 'Guest User' : appState.userName),
        subtitle: Text(appState.userEmail.isEmpty ? 'Settings & Preferences' : appState.userEmail),
      ),
    );
  }

  Widget _buildAccessibleGrid(BuildContext context, List<_Item> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title, 
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5
        )
      ),
    );
  }
}

class _Item {
  final String emoji, title, subtitle;
  final Widget screen;
  const _Item(this.emoji, this.title, this.subtitle, this.screen);
}
