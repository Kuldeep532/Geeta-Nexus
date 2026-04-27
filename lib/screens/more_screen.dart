import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
// Note: Saari screen imports wahi rahengi jo aapne pehle di thi.

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

  @override
  Widget build(BuildContext context) {
    // Production Practice: Watch only what's needed
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
            tooltip: 'Change application theme', // Accessibility tooltip
          )
        ],
      ),
      body: SafeArea(
        child: Scrollbar( // Improved UX for long lists
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountCard(context, appState),
                const SizedBox(height: 24),
                
                _SectionHeader(title: 'Study & Learn'),
                _buildAccessibleGrid(context, [
                  _Item('📚', 'Flashcards', 'Master key verses', const FlashcardsScreen()),
                  _Item('🎯', 'Quiz', 'Test your knowledge', const QuizScreen()),
                  _Item('📖', 'Glossary', 'Sanskrit terms', const GlossaryScreen()),
                  _Item('🗺️', 'Reading Plan', '30-day journey', const ReadingPlanScreen()),
                  _Item('🔭', 'Astrology', 'Kundli & horoscope', const AstrologyScreen()),
                ]),

                const SizedBox(height: 24),
                _SectionHeader(title: 'Spiritual Practice'),
                _buildAccessibleGrid(context, [
                  _Item('🧘', 'Meditation', 'Guided stillness', const MeditationScreen()),
                  _Item('🌬️', 'Breathing', 'Pranayama sessions', const BreathingScreen()),
                  _Item('📿', 'Japa Counter', 'Mantra chanting', const ChantsScreen()),
                  _Item('✍️', 'Journal', 'Reflect on your day', const JournalScreen()),
                  _Item('🎙️', 'Voice Practice', 'Recitation feedback', const GeetaVoicePracticeScreen()),
                ]),

                const SizedBox(height: 24),
                _SectionHeader(title: 'Support & Legal'),
                _buildAccessibleGrid(context, [
                  _Item('👤', 'Profile', 'Account settings', const ProfileScreen()),
                  _Item('ℹ️', 'About', 'App information', const AboutScreen()),
                  _Item('🔐', 'Privacy', 'Data protection', const PrivacyPolicyScreen()),
                  _Item('📜', 'Terms', 'User agreement', const TermsScreen()),
                  _Item('✉️', 'Contact', 'Get help', const ContactScreen()),
                ]),

                const SizedBox(height: 40),
                Center(
                  child: ExcludeSemantics( // Decorative or redundant info for screen readers
                    child: Text(
                      _appVersionLabel,
                      style: theme.textTheme.bodySmall,
                    ),
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
    
    // Accessibility: Merging all info into one semantic block
    return Semantics(
      label: 'Account Status: ${appState.userName.isEmpty ? 'Not connected' : appState.userName}. '
             'Linked via ${appState.isGoogleAccountLinked ? 'Google' : 'Local Profile'}.',
      container: true,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.person, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.userName.isEmpty ? 'Guest User' : appState.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      appState.userEmail.isEmpty ? 'Sign in to sync data' : appState.userEmail,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        return Semantics(
          button: true,
          label: 'Go to ${item.title}. ${item.subtitle}',
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Separate stateless widget for headers to keep build method clean
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
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _Item {
  final String emoji, title, subtitle;
  final Widget screen;
  const _Item(this.emoji, this.title, this.subtitle, this.screen);
}
