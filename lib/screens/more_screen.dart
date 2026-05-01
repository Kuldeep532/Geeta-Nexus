import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_state.dart';
import '../theme.dart';
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
      setState(() => _appVersionLabel = 'Version ${info.version} (${info.buildNumber})');
    } catch (_) {
      if (mounted) setState(() => _appVersionLabel = 'Version info unavailable');
    }
  }

  void _pickTheme(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.brightness_auto, color: kGold), title: const Text('System Default'), onTap: () {state.updateTheme(ThemeMode.system); Navigator.pop(context);}),
          ListTile(leading: const Icon(Icons.light_mode, color: kGold), title: const Text('Light Mode'), onTap: () {state.updateTheme(ThemeMode.light); Navigator.pop(context);}),
          ListTile(leading: const Icon(Icons.dark_mode, color: kGold), title: const Text('Dark Mode'), onTap: () {state.updateTheme(ThemeMode.dark); Navigator.pop(context);}),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('EXPLORE', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold)),
        centerTitle: true,
        actions: [IconButton(tooltip: 'Theme options', icon: const Icon(Icons.palette_outlined, color: kGold), onPressed: () => _pickTheme(context, appState))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildAccountCard(context, appState),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Study & Learn'),
            _buildAccessibleGrid(context, [
              _Item('📚', 'Flashcards', const FlashcardsScreen()),
              _Item('🎯', 'Quiz', const QuizScreen()),
              _Item('📖', 'Glossary', const GlossaryScreen()),
              _Item('🗺️', 'Reading Plan', const ReadingPlanScreen()),
              _Item('🔭', 'Astrology', const AstrologyScreen()),
            ]),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Spiritual Practice'),
            _buildAccessibleGrid(context, [
              _Item('🧘', 'Meditation', const MeditationScreen()),
              _Item('🌬️', 'Breathing', const BreathingScreen()),
              _Item('📿', 'Japa', const ChantsScreen()),
              _Item('✍️', 'Journal', const JournalScreen()),
              _Item('🎙️', 'Recitation', const GeetaVoicePracticeScreen()),
            ]),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Support & Legal'),
            _buildAccessibleGrid(context, [
              _Item('👤', 'Profile', const ProfileScreen()),
              _Item('ℹ️', 'About', const AboutScreen()),
              _Item('🔐', 'Privacy', const PrivacyPolicyScreen()),
              _Item('📜', 'Terms', const TermsScreen()),
              _Item('✉️', 'Contact', const ContactScreen()),
            ]),
            const SizedBox(height: 40),
            Center(child: Text(_appVersionLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))),
          ]),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: kGold.withOpacity(0.3))),
      child: Semantics(
        button: true,
        label: 'Open profile and account settings',
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: kGold, child: Icon(Icons.person, color: Colors.black)),
          title: Text(appState.userName.isEmpty ? 'Guest User' : appState.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(appState.userEmail.isEmpty ? 'Spiritual Journey Settings' : appState.userEmail),
          trailing: const Icon(Icons.chevron_right, color: kGold),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
      ),
    );
  }

  Widget _buildAccessibleGrid(BuildContext context, List<_Item> items) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Semantics(
          button: true,
          label: '${item.title} section',
          child: Card(
            margin: EdgeInsets.zero,
            color: theme.cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                ExcludeSemantics(child: Text(item.emoji, style: const TextStyle(fontSize: 28))),
                const SizedBox(height: 8),
                Text(item.title, textAlign: TextAlign.center, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
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
      child: Text(title.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: kGold, letterSpacing: 1.2)),
    );
  }
}

class _Item {
  final String emoji, title;
  final Widget screen;
  const _Item(this.emoji, this.title, this.screen);
}
