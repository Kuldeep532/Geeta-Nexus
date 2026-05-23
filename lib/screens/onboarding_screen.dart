import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/app_state.dart';
import '../main.dart';
import '../theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

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
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final bool isCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!mounted) return;

    if (isCompleted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStatus) {
      return Scaffold(
        backgroundColor: AppBranding.shyamBlue,
        body: Center(
          child: Semantics(
            label: 'Gita Nexus App Logo. Initializing application, please wait.',
            image: true,
            child: Image(
              image: const AssetImage(AppBranding.logoPath),
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

  int _page = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  String? _nameError;
  bool _isLoading = false;
  bool _googleReady = false;
  bool _showNameField = false;
  bool _showEmailField = false;
  bool _googleAttempted = false; 
  bool _acceptedPolicies = false;

  static const List<_OnboardPageData> _pages = [
    _OnboardPageData(
      title: 'Gita Nexus',
      subtitle: 'The Divine Eternal Song',
      body: 'Welcome to an ever expanding ecosystem equipped with continuously evolving spiritual tools. Seamlessly access seven hundred absolute verses with comprehensive data analytical frameworks.',
      semanticLabel: 'Page one. Welcome to Gita Nexus.',
    ),
    _OnboardPageData(
      title: 'Advanced Scriptural Analytics',
      subtitle: 'Eighteen Chapters of Absolute Wisdom',
      body: 'Perform systematic reading and textual reflection. Explore exact Sanskrit verses structured alongside profound academic commentaries, transliterations, and grammatical breakdowns.',
      semanticLabel: 'Page two. Advanced Scriptural Analytics.',
    ),
    _OnboardPageData(
      title: 'AI Spiritual Conversationalist',
      subtitle: 'Context Aware Guidance Engine',
      body: 'Engage with an intelligent platform trained to address spiritual inquiries. Seek structured perspectives on human duty, cosmic law, and existential core principles.',
      semanticLabel: 'Page three. AI Spiritual Conversationalist.',
    ),
    _OnboardPageData(
      title: 'Systematic Spiritual Routine',
      subtitle: 'Integrated Meditation and Metrics',
      body: 'Establish your standard daily practices. Utilize custom audio assistive meditation modules alongside an accurate, fully accessible interface metrics recorder.',
      semanticLabel: 'Page four. Systematic Spiritual Routine.',
    ),
    _OnboardPageData(
      title: 'Personalized Exploration Profile',
      subtitle: 'Synchronized Progress Framework',
      body: 'Initialize your customized journey. Authenticate securely to automatically preserve your configuration data, configurations, and progress logs across platforms.',
      semanticLabel: 'Page five. Personalized Exploration Profile.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    setState(() => _googleReady = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _continueWithGoogle() async {
    if (!_acceptedPolicies) {
      _showErrorSnackBar('Please accept Privacy Policy and Terms & Conditions first.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (!_googleReady) {
        await _initializeGoogleSignIn();
      }
      if (!_googleReady) {
        throw Exception('Google Sign-In initialization failed');
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      _googleAttempted = true;
      if (!mounted) return;
      if (account == null) throw Exception('Sign in cancelled');
      
      _nameController.text = account.displayName ?? "Seeker";

      Provider.of<AppState>(context, listen: false).updateGoogleAccount(
        name: account.displayName ?? "Seeker",
        email: account.email,
      );

      await _handlePermissions();
    } catch (e) {
      _showErrorSnackBar("Google Sign-in failed. Please enter your name to continue.");
      setState(() {
        _googleAttempted = true;
        _showNameField = true;
      }); 
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePermissions() async {
    await [Permission.microphone, Permission.notification].request();
    if (!mounted) return;
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    if (!_acceptedPolicies) {
      _showErrorSnackBar('Please accept Privacy Policy and Terms & Conditions first.');
      return;
    }
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = "Please enter your name");
      _nameFocus.requestFocus();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      if (!mounted) return;
      final state = Provider.of<AppState>(context, listen: false);
      
      state.setUserName(name);
      state.completeOnboarding();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (e) {
      _showErrorSnackBar("An error occurred. Please try again.");
    }
  }

  Future<void> _continueWithEmail() async {
    if (!_acceptedPolicies) {
      _showErrorSnackBar('Please accept Privacy Policy and Terms & Conditions first.');
      return;
    }
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _showErrorSnackBar('Please enter a valid email address.');
      return;
    }
    final state = Provider.of<AppState>(context, listen: false);
    final name = _nameController.text.trim().isEmpty ? email.split('@').first : _nameController.text.trim();
    state.updateGoogleAccount(name: name, email: email);
    state.completeOnboarding();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          child: Text(msg),
        ),
      ),
    );
  }

  void _next() {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() {
                  _page = i;
                  _nameError = null;
                  _showNameField = false; 
                  _showEmailField = false;
                }),
                itemBuilder: (ctx, i) => _buildPage(i, kGold, theme),
              ),
            ),
            _buildBottomControls(kGold, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index, Color gold, ThemeData theme) {
    final page = _pages[index];
    final isLastPage = index == _pages.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Semantics(
        label: page.semanticLabel,
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Semantics(
              header: true,
              headingLevel: 1,
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              headingLevel: 2,
              child: Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.25,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            if (isLastPage) ...[
              const SizedBox(height: 48),
              _buildPolicyConsent(theme),
              const SizedBox(height: 24),
              if (!_showNameField && !_showEmailField) 
                _buildLoginButtons(gold) 
              else if (_showNameField) 
                _buildNameInput(gold)
              else 
                _buildEmailInput(gold),
              if (_googleAttempted)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'You can continue by entering your profile credentials if server sign in is currently unresponsive.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.hintColor, fontSize: 13),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButtons(Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: 'Continue with Google Account Authentication',
          child: OutlinedButton(
            onPressed: (_isLoading || !_acceptedPolicies) ? null : _continueWithGoogle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: gold, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text("Continue with Google", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 14),
        Semantics(
          button: true,
          label: 'Continue setup as Profile Guest',
          child: TextButton(
            onPressed: !_acceptedPolicies ? null : () => setState(() => _showNameField = true),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text("Continue as Guest", style: TextStyle(color: gold, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        Semantics(
          button: true,
          label: 'Continue setup with Email Address Configuration',
          child: TextButton(
            onPressed: !_acceptedPolicies ? null : () => setState(() => _showEmailField = true),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text("Continue with Email", style: TextStyle(color: gold, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildNameInput(Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Enter your name text field input',
          child: TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _finishOnboarding(),
            decoration: InputDecoration(
              labelText: "Enter your name",
              errorText: _nameError,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          button: true,
          label: 'Confirm name and initialize core application setup',
          child: ElevatedButton(
            onPressed: _finishOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Get Started", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput(Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Enter email address text field input',
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _continueWithEmail(),
            decoration: const InputDecoration(
              labelText: "Enter your email address",
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          button: true,
          label: 'Confirm email address and proceed with application configuration',
          child: ElevatedButton(
            onPressed: _continueWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyConsent(ThemeData theme) {
    return Semantics(
      label: 'Terms consent verification checkbox status indicator',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _acceptedPolicies,
            onChanged: (val) => setState(() => _acceptedPolicies = val ?? false),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text("I accept the ", style: TextStyle(fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  child: Semantics(
                    link: true,
                    label: 'Open and read privacy policy statement document',
                    child: Text("Privacy Policy", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const Text(" and ", style: TextStyle(fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen())),
                  child: Semantics(
                    link: true,
                    label: 'Open and read terms and conditions regulatory document',
                    child: Text("Terms & Conditions", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(Color gold, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: 'Onboarding step slider progress locator indicator. Current page index is ${_page + 1} of total five pages.',
            child: Row(
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _page == index ? gold : gold.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          if (_page < _pages.length - 1)
            Semantics(
              button: true,
              label: 'Navigate to next presentation slider view page info block',
              child: IconButton(
                onPressed: _next,
                icon: Icon(Icons.arrow_forward_ios, color: gold),
              ),
            ),
        ],
      ),
    );
  }
}
