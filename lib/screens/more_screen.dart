import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_state.dart';
import '../theme.dart';

// Shuddh aur relevant imports
import 'profile_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'contact_screen.dart';
import 'scripture_library_screen.dart';

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
          ListTile(
            leading: const Icon(Icons.brightness_auto, color: kGold), 
            title: const Text('System Default'), 
            onTap: () { state.updateTheme(ThemeMode.system); Navigator.pop(context); }
          ),
          ListTile(
            leading: const Icon(Icons.light_mode, color: kGold), 
            title: const Text('Light Mode'), 
            onTap: () { state.updateTheme(ThemeMode.light); Navigator.pop(context); }
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: kGold), 
            title: const Text('Dark Mode'), 
            onTap: () { state.updateTheme(ThemeMode.dark); Navigator.pop(context); }
          ),
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
        // FIXED: Title Bar ko proper Semantic Header banaya hai
        title: Semantics(
          header: true,
          label: 'Explore Screen Heading',
          child: Text(
            'EXPLORE', 
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold, letterSpacing: 1.5)
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Theme options', 
            icon: const Icon(Icons.palette_outlined, color: kGold), 
            onPressed: () => _pickTheme(context, appState)
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              _buildAccountCard(context, appState),
              const SizedBox(height: 24),
              
              const _SectionHeader(title: 'Core Scripture'),
              _buildAccessibleGrid(context, [
                _Item('🕉️', 'Scripture\nLibrary', const ScriptureLibraryScreen()),
              ]),
              const SizedBox(height: 24),
              
              const _SectionHeader(title: 'Support & Legal'),
              _buildAccessibleGrid(context, [
                _Item('👤', 'Profile', const ProfileScreen()),
                _Item('ℹ️', 'About Us', const AboutUsScreen()),
                _Item('🔐', 'Privacy Policy', const PrivacyPolicyScreen()),
                _Item('📜', 'Terms & Conditions', const TermsAndConditionsScreen()),
                _Item('✉️', 'Contact Us', const ContactUsScreen()),
              ]),
              const SizedBox(height: 40),
              
              Center(
                child: Text(
                  _appVersionLabel, 
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final displayName = appState.userName.isEmpty ? 'Guest User' : appState.userName;
    final displayEmail = appState.userEmail.isEmpty ? 'Spiritual Journey Settings' : appState.userEmail;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: kGold.withOpacity(0.3))),
      child: Semantics(
        button: true,
        label: 'Account Info Card. User: $displayName. Email: $displayEmail.',
        hint: 'Double tap to open account settings',
        excludeSemantics: true,
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: kGold, child: Icon(Icons.person, color: Colors.black)),
          title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(displayEmail),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        mainAxisSpacing: 12, 
        crossAxisSpacing: 12, 
        childAspectRatio: 1.4
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Semantics(
          button: true,
          label: '${item.title} Section Button',
          hint: 'Double tap to open',
          excludeSemantics: true,
          child: Card(
            margin: EdgeInsets.zero,
            color: theme.cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), 
              side: BorderSide(color: theme.dividerColor.withOpacity(0.1))
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  ExcludeSemantics(child: Text(item.emoji, style: const TextStyle(fontSize: 28))),
                  const SizedBox(height: 8),
                  Text(
                    item.title, 
                    textAlign: TextAlign.center, 
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                ],
              ),
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
      // FIXED: Headers ko proper semantic node bana diya taaki section jumps aasan hon
      child: Semantics(
        header: true,
        label: '$title section heading',
        excludeSemantics: true,
        child: Text(
          title.toUpperCase(), 
          style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: kGold, letterSpacing: 1.2)
        ),
      ),
    );
  }
}

class _Item {
  final String emoji, title;
  final Widget screen;
  const _Item(this.emoji, this.title, this.screen);
}
