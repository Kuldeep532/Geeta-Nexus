import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/app_state.dart';
import '../main.dart';

// Page Data Model
class _OnboardPageData {
  final String emoji;
  final String emojiLabel; // Added for Screen Readers
  final String title;
  final String subtitle;
  final String body;

  const _OnboardPageData({
    required this.emoji,
    required this.emojiLabel,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  
  int _page = 0;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  String? _nameError;
  bool _isLoading = false;

  static const List<_OnboardPageData> _pages = [
    _OnboardPageData(
      emoji: '🕉️',
      emojiLabel: 'Aum Symbol',
      title: 'Bhagavad Gita AI',
      subtitle: 'The Song of God',
      body: 'Discover the timeless wisdom of 700 divine verses that have guided seekers for ages.',
    ),
    _OnboardPageData(
      emoji: '📖',
      emojiLabel: 'Open Book',
      title: 'Read & Reflect',
      subtitle: '18 Chapters of Wisdom',
      body: 'Explore Sanskrit verses with clear meanings and transliterations for deeper understanding.',
    ),
    _OnboardPageData(
      emoji: '🤖',
      emojiLabel: 'Robot Icon',
      title: 'Ask Krishna',
      subtitle: 'Your Divine AI Guide',
      body: 'Have spiritual conversations. Ask any question about dharma, karma, or life’s purpose.',
    ),
    _OnboardPageData(
      emoji: '🧘',
      emojiLabel: 'Meditation Position',
      title: 'Practice Daily',
      subtitle: 'Meditation & Japa',
      body: 'Build your spiritual routine with meditation timers and an interactive Japa counter.',
    ),
    _OnboardPageData(
      emoji: '🙏',
      emojiLabel: 'Greeting Hands',
      title: 'Welcome Seeker',
      subtitle: 'Personalize your journey',
      body: 'Enter your name so we can greet you properly on this path of wisdom.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // --- Logic Functions ---

  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account != null && mounted) {
        final name = account.displayName ?? "";
        _nameController.text = name;
        context.read<AppState>().updateGoogleAccount(
          name: name,
          email: account.email,
        );
        _handlePermissions();
      }
    } catch (e) {
      _showErrorSnackBar("Google Sign-in failed. Please try manually.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePermissions() async {
    await [Permission.microphone, Permission.notification].request();
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty && _page == _pages.length - 1) {
      setState(() => _nameError = "Kripya apna naam bhariye");
      _nameFocus.requestFocus();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;
    final state = context.read<AppState>();
    state.setUserName(name);
    state.completeOnboarding();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _handlePermissions();
    }
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goldColor = theme.brightness == Brightness.dark ? const Color(0xFFFFD700) : const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (ctx, i) => _buildPage(i, goldColor, theme),
              ),
            ),
            _buildBottomControls(goldColor, theme),
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
      child: Column(
        children: [
          const SizedBox(height: 20),
          Semantics(
            label: page.emojiLabel,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: gold.withOpacity(0.1), border: Border.all(color: gold, width: 2)),
              child: Center(child: Text(page.emoji, style: const TextStyle(fontSize: 48))),
            ),
          ),
          const SizedBox(height: 40),
          Text(page.title, textAlign: TextAlign.center, style: GoogleFonts.cinzel(color: gold, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(page.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          Text(page.body, textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor, height: 1.5)),
          if (isLastPage) ...[
            const SizedBox(height: 40),
            _buildNameInput(gold, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildNameInput(Color gold, ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          focusNode: _nameFocus,
          decoration: InputDecoration(
            hintText: "Apna naam likhiye",
            errorText: _nameError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.person, color: gold),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _continueWithGoogle,
          icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.g_mobiledata, size: 32),
          label: const Text("Continue with Google"),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
      ],
    );
  }

  Widget _buildBottomControls(Color gold, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _page == i ? 24 : 8, height: 8,
              decoration: BoxDecoration(color: _page == i ? gold : gold.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            )),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(_page == _pages.length - 1 ? "SHURU KAREIN 🕉️" : "AAGE BADHEIN", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          if (_page < _pages.length - 1)
            TextButton(onPressed: _handlePermissions, child: Text("Skip Tour", style: TextStyle(color: theme.hintColor))),
        ],
      ),
    );
  }
}
