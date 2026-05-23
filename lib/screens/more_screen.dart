import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

import 'about_screen.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';
import 'profile_screen.dart';
import 'terms_screen.dart';
import 'voice_support_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() =>
          _version = 'Version ${info.version} (${info.buildNumber})');
    } catch (_) {
      if (mounted) setState(() => _version = 'Version unavailable');
    }
  }

  void _open(Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _openThemeDialog(AppState appState) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Choose Theme',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            _themeButton(
              label: 'Use System Theme',
              icon: Icons.brightness_auto_rounded,
              onTap: () {
                appState.updateTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _themeButton(
              label: 'Light Theme',
              icon: Icons.light_mode_rounded,
              onTap: () {
                appState.updateTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _themeButton(
              label: 'Dark Theme',
              icon: Icons.dark_mode_rounded,
              onTap: () {
                appState.updateTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      hint: 'Double tap to apply',
      child: ExcludeSemantics(
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon),
          title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: kGold.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    final userName = appState.userName.trim().isEmpty
        ? 'Guest User'
        : appState.userName.trim();
    final userEmail = appState.userEmail.trim().isEmpty
        ? 'Tap to update profile'
        : appState.userEmail.trim();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Semantics(
          header: true,
          namesRoute: true,
          child: Text(
            'Explore',
            style: GoogleFonts.cinzel(
              color: kGold,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.3,
            ),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Change app theme',
            hint: 'Double tap to choose light, dark, or system theme',
            child: IconButton(
              tooltip: 'Theme Settings',
              icon: const Icon(Icons.palette_outlined, color: kGold),
              onPressed: () => _openThemeDialog(appState),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ── Profile tile ──────────────────────────────────────────────
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: 'Profile. $userName. $userEmail. Double tap to edit profile.',
            child: ExcludeSemantics(
              child: ListTile(
                onTap: () => _open(const ProfileScreen()),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: kGold,
                  child: const Icon(Icons.person_rounded,
                      color: Colors.black, size: 26),
                ),
                title: Text(
                  userName,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                subtitle: Text(
                  userEmail,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Customer Support tile ─────────────────────────────────────
          Semantics(
            button: true,
            label: 'Customer Support. Start a voice call with Aira, your AI companion.',
            hint: 'Double tap to open',
            child: ExcludeSemantics(
              child: ListTile(
                onTap: () => _open(const VoiceSupportScreen()),
                leading: const Icon(Icons.support_agent_rounded,
                    color: kGold, size: 26),
                title: Text(
                  'Customer Support',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Voice call with Aira, your AI companion',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          ),

          const SizedBox(height: 4),
          const Divider(indent: 16, endIndent: 16),

          // ── Section header ────────────────────────────────────────────
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'SUPPORT & INFORMATION',
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // ── Menu items ────────────────────────────────────────────────
          _MenuTile(
            label: 'Profile. Manage your profile and preferences.',
            title: 'Profile',
            subtitle: 'Manage your profile and preferences',
            icon: Icons.person_outline_rounded,
            onTap: () => _open(const ProfileScreen()),
          ),
          _MenuTile(
            label: 'About. Learn more about this application.',
            title: 'About',
            subtitle: 'Learn more about this application',
            icon: Icons.info_outline_rounded,
            onTap: () => _open(const AboutUsScreen()),
          ),
          _MenuTile(
            label: 'Privacy Policy. Read privacy and security information.',
            title: 'Privacy Policy',
            subtitle: 'Read privacy and security information',
            icon: Icons.privacy_tip_outlined,
            onTap: () => _open(const PrivacyPolicyScreen()),
          ),
          _MenuTile(
            label: 'Terms and Conditions. View terms of use.',
            title: 'Terms & Conditions',
            subtitle: 'View terms and conditions of use',
            icon: Icons.description_outlined,
            onTap: () => _open(const TermsAndConditionsScreen()),
          ),
          _MenuTile(
            label: 'Contact. Get support and contact details.',
            title: 'Contact',
            subtitle: 'Get support and contact details',
            icon: Icons.mail_outline_rounded,
            onTap: () => _open(const ContactUsScreen()),
          ),

          // ── Version ───────────────────────────────────────────────────
          if (_version.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Semantics(
                label: _version,
                readOnly: true,
                child: ExcludeSemantics(
                  child: Text(
                    _version,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Single menu list tile ───────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: 'Double tap to open',
      child: ExcludeSemantics(
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, size: 24),
          title: Text(
            title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          minVerticalPadding: 10,
        ),
      ),
    );
  }
}
