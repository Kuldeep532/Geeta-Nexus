import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;
  bool _acceptedPolicies = false;
  bool _isAdminMode = false;
  bool _isGuestMode = false;
  bool _obscurePassword = true;

  final _adminFormKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  final _guestFocus = FocusNode();
  final _adminEmailFocus = FocusNode();
  final _adminPasswordFocus = FocusNode();

  @override
  void dispose() {
    _guestNameController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _guestFocus.dispose();
    _adminEmailFocus.dispose();
    _adminPasswordFocus.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (!_acceptedPolicies) {
      _showSnack('Please accept the Terms and Privacy Policy first.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }
      final name = account.displayName ?? 'Seeker';
      final email = account.email;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);

      if (!mounted) return;
      final appState = context.read<AppState>();
      appState.setUserName(name);
      appState.setUserEmail(email);
      appState.completeOnboarding();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Google sign-in failed. Please try again.');
    }
  }

  Future<void> _adminLogin() async {
    if (!(_adminFormKey.currentState?.validate() ?? false)) return;
    if (!_acceptedPolicies) {
      _showSnack('Please accept the Terms and Privacy Policy.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    final name = _adminEmailController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('user_name', name);
    await prefs.setBool('is_admin', true);

    if (!mounted) return;
    final appState = context.read<AppState>();
    appState.setUserName(name);
    appState.setUserEmail(name);
    appState.completeOnboarding();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  Future<void> _continueAsGuest() async {
    final name = _guestNameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter your name to continue.');
      FocusScope.of(context).requestFocus(_guestFocus);
      return;
    }
    if (!_acceptedPolicies) {
      _showSnack('Please accept the Terms and Privacy Policy.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('user_name', name);

    if (!mounted) return;
    final appState = context.read<AppState>();
    appState.setUserName(name);
    appState.completeOnboarding();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  void _openPolicy(Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A1628) : const Color(0xFFF8F5F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Image.asset(
                      AppBranding.logoPath,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gita Nexus',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your AI Spiritual Companion',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Repository link
                  Semantics(
                    button: true,
                    label: 'View Gita Nexus source code on GitHub. Opens in browser.',
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final uri = Uri.parse('https://github.com/Geeta-ai/Geeta-Nexus');
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (_) {
                          _showSnack('Unable to open browser link.');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.code_rounded, size: 14, color: kGold.withOpacity(0.6)),
                          const SizedBox(width: 6),
                          Text(
                            'github.com/Geeta-ai/Geeta-Nexus',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kGold.withOpacity(0.6),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: _isGuestMode
                        ? _buildGuestForm()
                        : _isAdminMode
                            ? _buildAdminForm()
                            : _buildMainForm(),
                  ),
                  const SizedBox(height: 16),
                  // Policy acceptance checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedPolicies,
                        activeColor: kGold,
                        onChanged: (v) => setState(() => _acceptedPolicies = v ?? false),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I accept the Terms and Conditions and Privacy Policy',
                            style: GoogleFonts.inter(fontSize: 13, height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Policy buttons directly above main action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openPolicy(const TermsAndConditionsScreen()),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kGold.withOpacity(0.4)),
                            foregroundColor: kGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            'Terms & Conditions',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openPolicy(const PrivacyPolicyScreen()),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kGold.withOpacity(0.4)),
                            foregroundColor: kGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mode toggles
                  if (!_isGuestMode && !_isAdminMode)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _isGuestMode = true);
                          HapticFeedback.lightImpact();
                        },
                        child: Text(
                          'Continue as Guest',
                          style: GoogleFonts.poppins(
                            color: kGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_isGuestMode)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _isGuestMode = false);
                          HapticFeedback.lightImpact();
                        },
                        child: Text(
                          'Back to Sign In',
                          style: GoogleFonts.poppins(
                            color: kGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ),
                  if (!_isAdminMode)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _isAdminMode = true);
                          HapticFeedback.lightImpact();
                        },
                        child: Text(
                          'Admin Login',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (_isAdminMode)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _isAdminMode = false);
                          HapticFeedback.lightImpact();
                        },
                        child: Text(
                          'Back to User Sign In',
                          style: GoogleFonts.poppins(
                            color: kGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: const Icon(Icons.login, size: 18),
            label: Text(
              'Sign in with Google',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: kGold.withOpacity(0.5)),
              foregroundColor: kGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Secure one-tap authentication',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGuestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Start',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: kGold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your name to explore the app without creating an account.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _guestNameController,
          focusNode: _guestFocus,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _continueAsGuest(),
          decoration: _inputDecoration('Your Name', Icons.person_outline),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _continueAsGuest,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    'Start Exploring',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminForm() {
    return Form(
      key: _adminFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Admin Portal',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Restricted to authorized administrators only.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _adminEmailController,
            focusNode: _adminEmailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_adminPasswordFocus),
            decoration: _inputDecoration('Admin Email', Icons.email_outlined),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _adminPasswordController,
            focusNode: _adminPasswordFocus,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _adminLogin(),
            decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _adminLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(
                      'Admin Login',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
          .withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kGold, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
