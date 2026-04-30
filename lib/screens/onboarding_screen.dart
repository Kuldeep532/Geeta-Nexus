import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  int _page = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  bool _googleLoading = false;
  String? _googleError;

  Future<void> _continueWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _googleError = null;
    });

    try {
      final account = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (account == null) {
        setState(() {
          _googleError = 'Google sign-in was cancelled. You can continue by entering your name.';
        });
        return;
      }
      final displayName = account.displayName?.trim() ?? '';
      final email = account.email.trim();
      if (displayName.isNotEmpty) {
        _nameController.text = displayName;
      }
      if (mounted) {
        final appState = context.read<AppState>();
        appState.updateGoogleAccount(
          name: displayName.isNotEmpty ? displayName : _nameController.text,
          email: email,
        );
      }
      await _handlePermissions();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _googleError = 'Google sign-in failed on this device. Please verify Google Play Services / OAuth setup and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  static const List<_OnboardPageData> _pages = [
    _OnboardPageData(
      emoji: '🕉️',
      title: 'Bhagavad Gita AI',
      subtitle: 'The Song of God',
      body:
          'Discover the timeless wisdom of the Bhagavad Gita — 700 verses of divine knowledge that have guided seekers.',
    ),
    _OnboardPageData(
      emoji: '📖',
      title: 'Read & Reflect',
      subtitle: '18 Chapters of Wisdom',
      body:
          'Explore all 18 chapters with Sanskrit verses, transliterations, and deep meanings as you journey through the teachings.',
    ),
    _OnboardPageData(
      emoji: '🤖',
      title: 'Ask Krishna',
      subtitle: 'Your Divine Guide',
      body:
          'Have conversations with Lord Krishna or your Gita Guide. Ask any question about dharma, karma, or devotion.',
    ),
    _OnboardPageData(
      emoji: '🧘',
      title: 'Practice Daily',
      subtitle: 'Meditation • Breathing • Japa',
      body:
          'Build a daily spiritual practice with meditation timers, pranayama exercises, and a japa mala counter.',
    ),
    _OnboardPageData(
      emoji: '🌟',
      title: 'Grow Spiritually',
      subtitle: 'Track Your Journey',
      body:
          'Earn XP, level up, unlock badges, and build your streak. Track your progress through all 18 chapters.',
    ),
    // Last page = name entry, handled separately by _buildNamePage
    _OnboardPageData(
      emoji: '🙏',
      title: 'What should we call you?',
      subtitle: 'Personalize your journey',
      body: 'Enter your name so we can greet you each day.',
    ),
  ];

  bool get _isNamePage => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    final name = _nameController.text.trim();
    final state = context.read<AppState>();
    if (name.isNotEmpty) {
      state.setUserName(name);
    }
    state.completeOnboarding();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  Future<void> _handlePermissions() async {
    await [
      Permission.microphone,
      Permission.notification,
    ].request();

    await _finishOnboarding();
  }

  Future<void> _continueWithEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Please enter your name' : null;
      _emailError =
          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ? null : 'Enter a valid email';
      _passwordError =
          password.length >= 6 ? null : 'Password must be at least 6 characters';
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      return;
    }
    context.read<AppState>().updateEmailAccount(name: name, email: email);
    await _handlePermissions();
  }

  void _next() {
    if (_isNamePage) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _nameError = 'Please enter your name to continue');
        _nameFocus.requestFocus();
        return;
      }
      setState(() => _nameError = null);
      _handlePermissions();
      return;
    }

    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  if (i == _pages.length - 1) {
                    Future.delayed(const Duration(milliseconds: 250),
                        () => _nameFocus.requestFocus());
                  }
                },
                itemBuilder: (ctx, i) => i == _pages.length - 1
                    ? _buildNamePage(_pages[i])
                    : _buildPageLayout(_pages[i]),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? cs.primary : cs.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isNamePage ? 'Begin Your Journey 🕉️' : 'Next',
                style: GoogleFonts.cinzel(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (!_isNamePage)
            TextButton(
              onPressed: _handlePermissions,
              child: Text(
                'Skip Tour',
                style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 14),
              ),
            )
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildPageLayout(_OnboardPageData page) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.1),
                border: Border.all(color: cs.primary, width: 2),
              ),
              child: Center(
                child:
                    Text(page.emoji, style: const TextStyle(fontSize: 54)),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cs.primary.withOpacity(0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                color: cs.onSurface,
                fontSize: 18,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage(_OnboardPageData page) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.1),
                border: Border.all(color: cs.primary, width: 2),
              ),
              child: Center(
                child:
                    Text(page.emoji, style: const TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: cs.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                color: cs.onSurface,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _next(),
              style: GoogleFonts.cinzel(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 18),
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Email address',
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Password (6+ chars)',
                errorText: _passwordError,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _continueWithEmail,
                icon: const Icon(Icons.mail_outline),
                label: const Text('Continue with Email'),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _googleLoading ? null : _continueWithGoogle,
                icon: _googleLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  _googleLoading ? 'Connecting to Google...' : 'Continue with Google',
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.primary.withOpacity(0.7)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (_googleError != null) ...[
              const SizedBox(height: 8),
              Text(
                _googleError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'You can change this anytime in Settings.',
              style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageData {
  final String emoji;
  final String title;
  final String subtitle;
  final String body;

  const _OnboardPageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}
