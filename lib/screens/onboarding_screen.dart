import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GLOBAL REUSABLE ACCESSIBLE WIDGETS
// Import this file (or copy these classes to lib/widgets/accessible.dart)
// and use them on any screen to gain instant WCAG 2.1 AA/AAA compliance.
// ═══════════════════════════════════════════════════════════════════════════

/// A TextFormField wrapper that enforces:
/// • visible labelText  • minimum 44 × 44 tap target  • semantic hint
class AccessibleTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final String? semanticHint;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final List<String>? autofillHints;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final int? maxLines;

  const AccessibleTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.hint,
    this.semanticHint,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.autofillHints,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      hint: semanticHint ?? hint,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          autofillHints: autofillHints,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}

/// A button wrapper that injects Semantics automatically.
/// [type] controls the visual style: elevated | outlined | text
class AccessibleButton extends StatelessWidget {
  final String label;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final Widget child;
  final _BtnType type;
  final double height;

  const AccessibleButton.elevated({
    super.key,
    required this.label,
    required this.child,
    required this.onPressed,
    this.semanticHint,
    this.height = 54,
  }) : type = _BtnType.elevated;

  const AccessibleButton.outlined({
    super.key,
    required this.label,
    required this.child,
    required this.onPressed,
    this.semanticHint,
    this.height = 54,
  }) : type = _BtnType.outlined;

  const AccessibleButton.text({
    super.key,
    required this.label,
    required this.child,
    required this.onPressed,
    this.semanticHint,
    this.height = 44,
  }) : type = _BtnType.text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: semanticHint,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: switch (type) {
          _BtnType.elevated => ElevatedButton(
              onPressed: onPressed,
              child: child,
            ),
          _BtnType.outlined => OutlinedButton(
              onPressed: onPressed,
              child: child,
            ),
          _BtnType.text => TextButton(
              onPressed: onPressed,
              child: child,
            ),
        },
      ),
    );
  }
}

enum _BtnType { elevated, outlined, text }

/// A clickable rich-text link with proper Semantics and a minimum 44 × 44
/// touch target. Wrap inside a [RichText] or use standalone.
class AccessibleLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String displayText;
  final TextStyle? style;

  const AccessibleLink({
    super.key,
    required this.label,
    required this.displayText,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      link: true,
      label: label,
      hint: 'Double tap to open',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Text(
              displayText,
              style: style ??
                  TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ONBOARDING SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class _OnboardPageData {
  final String title;
  final String subtitle;
  final String body;
  final String semanticLabel;

  const _OnboardPageData({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.semanticLabel,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isCheckingStatus = true;

  @override
  void initState() {
    super.initState();
    _runAppRoutingLogic();
  }

  Future<void> _runAppRoutingLogic() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final bool isCompleted = prefs.getBool('onboarding_completed') ?? false;
    if (!mounted) return;
    if (isCompleted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      setState(() => _isCheckingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStatus) {
      return Scaffold(
        backgroundColor: AppBranding.shyamBlue,
        body: Center(
          child: Semantics(
            label: 'Gita Nexus logo. Application is loading. Please wait.',
            image: true,
            child: Image.asset(
              AppBranding.logoPath,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    return const _OnboardingSlidersView();
  }
}

class _OnboardingSlidersView extends StatefulWidget {
  const _OnboardingSlidersView();

  @override
  State<_OnboardingSlidersView> createState() => _OnboardingSlidersViewState();
}

class _OnboardingSlidersViewState extends State<_OnboardingSlidersView> {
  final PageController _controller = PageController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Email registration controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  // Guest flow
  final TextEditingController _guestNameController = TextEditingController();
  final FocusNode _guestNameFocus = FocusNode();
  bool _isGuestMode = false;

  int _page = 0;
  bool _isLoading = false;
  bool _acceptedPolicies = false;

  static const List<_OnboardPageData> _pages = [
    _OnboardPageData(
      title: 'Gita Nexus',
      subtitle: 'The Divine Eternal Song',
      body: 'Welcome to an ever expanding ecosystem equipped with continuously evolving spiritual tools.',
      semanticLabel: 'Welcome page',
    ),
    _OnboardPageData(
      title: 'Advanced Scriptural Analytics',
      subtitle: 'Eighteen Chapters of Wisdom',
      body: 'Explore Sanskrit verses with transliterations, analytics, and commentary.',
      semanticLabel: 'Analytics page',
    ),
    _OnboardPageData(
      title: 'AI Spiritual Conversationalist',
      subtitle: 'Context Aware Guidance',
      body: 'Receive intelligent responses for spiritual reflection and guidance.',
      semanticLabel: 'AI guidance page',
    ),
    _OnboardPageData(
      title: 'Systematic Spiritual Routine',
      subtitle: 'Meditation and Metrics',
      body: 'Track habits, routines, and meditation sessions in a fully accessible interface.',
      semanticLabel: 'Routine page',
    ),
    _OnboardPageData(
      title: 'Personalized Exploration Profile',
      subtitle: 'Secure Progress Sync',
      body: 'Create your profile to synchronize settings and progress securely.',
      semanticLabel: 'Profile setup page',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _guestNameController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _guestNameFocus.dispose();
    super.dispose();
  }

  // ── Guest mode toggle with auto-focus shift ────────────────────────────
  void _activateGuestMode() {
    setState(() => _isGuestMode = true);
    // Programmatic focus shift: move screen-reader to guest name field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_guestNameFocus);
      SemanticsService.announce(
        'Guest mode. Enter your name to proceed.',
        TextDirection.ltr,
      );
    });
  }

  void _deactivateGuestMode() {
    setState(() {
      _isGuestMode = false;
      _guestNameController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocus);
    });
  }

  // ── Finish with email ──────────────────────────────────────────────────
  Future<void> _finishWithEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await _saveAndNavigate(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );
  }

  // ── Finish as guest ────────────────────────────────────────────────────
  Future<void> _finishAsGuest() async {
    final name = _guestNameController.text.trim();
    if (name.isEmpty) {
      FocusScope.of(context).requestFocus(_guestNameFocus);
      _showSnack('Please enter your name to proceed as guest.');
      return;
    }
    FocusScope.of(context).unfocus();
    await _saveAndNavigate(name: name, email: '');
  }

  // ── Google sign-in ─────────────────────────────────────────────────────
  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Cancelled');
      if (!mounted) return;
      Provider.of<AppState>(context, listen: false).updateGoogleAccount(
        name: account.displayName ?? 'Seeker',
        email: account.email,
      );
      await [Permission.microphone, Permission.notification].request();
      if (!mounted) return;
      await _saveAndNavigate(
        name: account.displayName ?? 'Seeker',
        email: account.email,
      );
    } catch (_) {
      _showSnack('Google Sign-In failed. Please try another option.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Shared save + navigate ─────────────────────────────────────────────
  Future<void> _saveAndNavigate({
    required String name,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      if (!mounted) return;
      final state = Provider.of<AppState>(context, listen: false);
      state.setUserName(name);
      if (email.isNotEmpty) {
        state.updateGoogleAccount(name: name, email: email);
      }
      state.completeOnboarding();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (_) {
      _showSnack('Something went wrong. Please try again.');
    }
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Semantics(liveRegion: true, child: Text(msg)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (ctx, i) => _buildPage(ctx, i),
              ),
            ),
            // Dot indicators + Next button (no buttons duplicated here)
            _buildDotRow(),
          ],
        ),
      ),
    );
  }

  // ── Page content ───────────────────────────────────────────────────────
  Widget _buildPage(BuildContext context, int index) {
    final page = _pages[index];
    final isLastPage = index == _pages.length - 1;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Semantics(
                label: page.semanticLabel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Semantics(
                        image: true,
                        label: 'Gita Nexus logo',
                        child: Image.asset(
                          AppBranding.logoPath,
                          width: 110,
                          height: 110,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kGold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      page.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      page.body,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 15, height: 1.7),
                    ),
                    const Spacer(),
                    if (isLastPage) ...[
                      const SizedBox(height: 32),
                      _isGuestMode
                          ? _buildGuestPanel()
                          : _buildEmailPanel(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Email registration panel ───────────────────────────────────────────
  Widget _buildEmailPanel() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ONE Name field
          AccessibleTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            label: 'Full Name',
            hint: 'Enter your full name',
            semanticHint: 'Type your full name here',
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          // Email field
          AccessibleTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'Email Address',
            hint: 'example@email.com',
            semanticHint: 'Type your email address here',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) =>
                _acceptedPolicies ? _finishWithEmail() : null,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildPolicyRow(),
          const SizedBox(height: 20),
          // Button 1 — ElevatedButton (disabled until policy accepted)
          AccessibleButton.elevated(
            label: 'Continue with Email and Password',
            semanticHint: _acceptedPolicies
                ? 'Double tap to register with your email'
                : 'Accept Terms and Privacy Policy first',
            onPressed: _acceptedPolicies && !_isLoading
                ? _finishWithEmail
                : null,
            child: const Text('Continue with Email and Password'),
          ),
          const SizedBox(height: 12),
          // Button 2 — OutlinedButton (disabled until policy accepted)
          AccessibleButton.outlined(
            label: 'Continue with Google',
            semanticHint: _acceptedPolicies
                ? 'Double tap to sign in with Google'
                : 'Accept Terms and Privacy Policy first',
            onPressed: _acceptedPolicies && !_isLoading
                ? _continueWithGoogle
                : null,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 8),
                      Text('Continue with Google'),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          // Button 3 — TextButton (always enabled — no account needed)
          AccessibleButton.text(
            label: 'Continue as Guest',
            semanticHint: 'Double tap to use the app without an account',
            onPressed: _activateGuestMode,
            child: const Text('Continue as Guest'),
          ),
        ],
      ),
    );
  }

  // ── Guest panel ────────────────────────────────────────────────────────
  Widget _buildGuestPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessibleTextField(
          controller: _guestNameController,
          focusNode: _guestNameFocus,
          label: 'Your Name',
          hint: 'Enter your name',
          semanticHint: 'Type your name to continue as guest',
          autofillHints: const [AutofillHints.name],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) =>
              _acceptedPolicies ? _finishAsGuest() : null,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildPolicyRow(),
        const SizedBox(height: 20),
        AccessibleButton.elevated(
          label: 'Proceed as Guest',
          semanticHint: _acceptedPolicies
              ? 'Double tap to enter the app as guest'
              : 'Accept Terms and Privacy Policy first',
          onPressed: _acceptedPolicies ? _finishAsGuest : null,
          child: const Text('Proceed'),
        ),
        const SizedBox(height: 8),
        AccessibleButton.text(
          label: 'Back to sign in options',
          semanticHint: 'Double tap to go back to email and Google sign in',
          onPressed: _deactivateGuestMode,
          child: const Text('Back to Sign In'),
        ),
      ],
    );
  }

  // ── Legal compliance row (mandatory) ──────────────────────────────────
  Widget _buildPolicyRow() {
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Checkbox(
              value: _acceptedPolicies,
              activeColor: kGold,
              onChanged: (v) {
                setState(() => _acceptedPolicies = v ?? false);
                SemanticsService.announce(
                  _acceptedPolicies
                      ? 'Terms accepted'
                      : 'Terms not accepted',
                  TextDirection.ltr,
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.inter(fontSize: 13, height: 1.5),
                children: [
                  const TextSpan(text: 'I accept the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: const TextStyle(
                      color: kGold,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsAndConditionsScreen(),
                            ),
                          ),
                    semanticsLabel: 'Terms and Conditions link',
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: kGold,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          ),
                    semanticsLabel: 'Privacy Policy link',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dot indicator row (no action buttons here — eliminates the duplicate)
  Widget _buildDotRow() {
    final isLastPage = _page == _pages.length - 1;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 26 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: active ? kGold : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),
            if (!isLastPage)
              Semantics(
                button: true,
                label: 'Next onboarding page',
                child: ElevatedButton(
                  onPressed: _next,
                  child: const Text('Next'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
