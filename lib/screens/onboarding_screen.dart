import 'package:flutter/material.dart';
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
    final bool isCompleted =
        prefs.getBool('onboarding_completed') ?? false;

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
            label:
                'Gita Nexus logo. Application is loading. Please wait.',
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
  State<_OnboardingSlidersView> createState() =>
      _OnboardingSlidersViewState();
}

class _OnboardingSlidersViewState
    extends State<_OnboardingSlidersView> {
  final PageController _controller = PageController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  int _page = 0;

  bool _isLoading = false;
  bool _googleReady = false;
  bool _acceptedPolicies = false;

  String? _nameError;
  String? _emailError;

  static const List<_OnboardPageData> _pages = [
    _OnboardPageData(
      title: 'Gita Nexus',
      subtitle: 'The Divine Eternal Song',
      body:
          'Welcome to an ever expanding ecosystem equipped with continuously evolving spiritual tools.',
      semanticLabel: 'Welcome page',
    ),
    _OnboardPageData(
      title: 'Advanced Scriptural Analytics',
      subtitle: 'Eighteen Chapters of Wisdom',
      body:
          'Explore Sanskrit verses with transliterations, analytics, and commentary.',
      semanticLabel: 'Analytics page',
    ),
    _OnboardPageData(
      title: 'AI Spiritual Conversationalist',
      subtitle: 'Context Aware Guidance',
      body:
          'Receive intelligent responses for spiritual reflection and guidance.',
      semanticLabel: 'AI guidance page',
    ),
    _OnboardPageData(
      title: 'Systematic Spiritual Routine',
      subtitle: 'Meditation and Metrics',
      body:
          'Track habits, routines, and meditation sessions in a fully accessible interface.',
      semanticLabel: 'Routine page',
    ),
    _OnboardPageData(
      title: 'Personalized Exploration Profile',
      subtitle: 'Secure Progress Sync',
      body:
          'Create your profile to synchronize settings and progress securely.',
      semanticLabel: 'Profile setup page',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    setState(() {
      _googleReady = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _continueWithGoogle() async {
    if (!_acceptedPolicies) {
      _showSnackBar(
        'Please accept Privacy Policy and Terms first.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? account =
          await _googleSignIn.signIn();

      if (account == null) {
        throw Exception('Sign in cancelled');
      }

      _nameController.text = account.displayName ?? '';
      _emailController.text = account.email;

      if (!mounted) return;

      Provider.of<AppState>(
        context,
        listen: false,
      ).updateGoogleAccount(
        name: account.displayName ?? 'Seeker',
        email: account.email,
      );

      await _handlePermissions();
    } catch (e) {
      _showSnackBar(
        'Google Sign-In failed. Please continue manually.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePermissions() async {
    await [
      Permission.microphone,
      Permission.notification,
    ].request();

    if (!mounted) return;

    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _nameError = null;
      _emailError = null;
    });

    if (!_acceptedPolicies) {
      _showSnackBar(
        'Please accept Privacy Policy and Terms.',
      );
      return;
    }

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Name is required';
      });

      _nameFocus.requestFocus();
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailError = 'Valid email is required';
      });

      _emailFocus.requestFocus();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        'onboarding_completed',
        true,
      );

      if (!mounted) return;

      final state = Provider.of<AppState>(
        context,
        listen: false,
      );

      state.setUserName(name);

      state.updateGoogleAccount(
        name: name,
        email: email,
      );

      state.completeOnboarding();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainShell(),
        ),
        (route) => false,
      );
    } catch (e) {
      _showSnackBar(
        'Something went wrong. Please try again.',
      );
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

  void _showSnackBar(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Semantics(
          liveRegion: true,
          child: Text(msg),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _page = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(
                    context,
                    index,
                    theme,
                  );
                },
              ),
            ),
            _buildBottomControls(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    int index,
    ThemeData theme,
  ) {
    final page = _pages[index];
    final isLastPage = index == _pages.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Semantics(
                      image: true,
                      label: 'Gita Nexus logo',
                      child: Image.asset(
                        AppBranding.logoPath,
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: kGold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    page.body,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),

                  const Spacer(),

                  if (isLastPage) ...[
                    const SizedBox(height: 40),

                    _buildNameField(),

                    const SizedBox(height: 18),

                    _buildEmailField(),

                    const SizedBox(height: 18),

                    _buildPolicyCheckbox(),

                    const SizedBox(height: 24),

                    _buildGoogleButton(),

                    const SizedBox(height: 16),

                    _buildContinueButton(),

                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameField() {
    return Semantics(
      textField: true,
      label: 'Full name input field',
      child: TextField(
        controller: _nameController,
        focusNode: _nameFocus,
        textInputAction: TextInputAction.next,
        autofillHints: const [
          AutofillHints.name,
        ],
        onSubmitted: (_) {
          _emailFocus.requestFocus();
        },
        decoration: InputDecoration(
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          errorText: _nameError,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Semantics(
      textField: true,
      label: 'Email address input field',
      child: TextField(
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType:
            TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [
          AutofillHints.email,
        ],
        onSubmitted: (_) {
          _finishOnboarding();
        },
        decoration: InputDecoration(
          labelText: 'Email Address',
          hintText: 'example@email.com',
          errorText: _emailError,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCheckbox() {
    return MergeSemantics(
      child: CheckboxListTile(
        value: _acceptedPolicies,
        contentPadding: EdgeInsets.zero,
        controlAffinity:
            ListTileControlAffinity.leading,
        onChanged: (value) {
          setState(() {
            _acceptedPolicies = value ?? false;
          });
        },
        title: Wrap(
          crossAxisAlignment:
              WrapCrossAlignment.center,
          children: [
            const Text('I accept the '),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PrivacyPolicyScreen(),
                  ),
                );
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Text(' and '),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const TermsAndConditionsScreen(),
                  ),
                );
              },
              child: Text(
                'Terms & Conditions',
                style: TextStyle(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed:
            _isLoading ? null : _continueWithGoogle,
        icon: const Icon(Icons.login),
        label: Text(
          _isLoading
              ? 'Please wait...'
              : 'Continue with Google',
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: _finishOnboarding,
        child: const Text(
          'Continue',
        ),
      ),
    );
  }

  Widget _buildBottomControls(
    ThemeData theme,
  ) {
    final isLastPage =
        _page == _pages.length - 1;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) {
                    final isActive =
                        index == _page;

                    return AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      width: isActive ? 26 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? kGold
                            : Colors.grey.shade400,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
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
