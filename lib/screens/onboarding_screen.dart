import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  int _page = 0;

  static const List<_OnboardPageData> _pages = [
    _OnboardPageData(
      emoji: '🕉️',
      title: 'Bhagavad Gita AI',
      subtitle: 'The Song of God',
      body: 'Discover the timeless wisdom of the Bhagavad Gita — 700 verses of divine knowledge that have guided seekers.',
    ),
    _OnboardPageData(
      emoji: '📖',
      title: 'Read & Reflect',
      subtitle: '18 Chapters of Wisdom',
      body: 'Explore all 18 chapters with Sanskrit verses, transliterations, and deep meanings as you journey through the teachings.',
    ),
    _OnboardPageData(
      emoji: '🤖',
      title: 'Ask Krishna',
      subtitle: 'Your Divine Guide',
      body: 'Have conversations with Lord Krishna or your Gita Guide. Ask any question about dharma, karma, or devotion.',
    ),
    _OnboardPageData(
      emoji: '🧘',
      title: 'Practice Daily',
      subtitle: 'Meditation • Breathing • Japa',
      body: 'Build a daily spiritual practice with meditation timers, pranayama exercises, and a japa mala counter.',
    ),
    _OnboardPageData(
      emoji: '🌟',
      title: 'Grow Spiritually',
      subtitle: 'Track Your Journey',
      body: 'Earn XP, level up, unlock badges, and build your streak. Track your progress through all 18 chapters.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (!mounted) return;

    context.read<AppState>().completeOnboarding();

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
    
    _finishOnboarding();
  }

  void _nextPage() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400), 
        curve: Curves.easeInOut,
      );
    } else {
      _handlePermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (ctx, i) => _buildPageLayout(_pages[i]),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
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
                margin: const EdgeInsets.symmetric(horizontal: 4), // FIXED: Removed leading comma
                width: _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? kGold : kDivider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: kBg,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _page == _pages.length - 1 ? 'Begin Your Journey 🕉️' : 'Next',
                style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_page < _pages.length - 1)
            TextButton(
              onPressed: _finishOnboarding,
              child: const Text(
                'Skip Tour',
                style: TextStyle(color: kTextDim, fontSize: 14),
              ),
            )
          else
            const SizedBox(height: 48), 
        ],
      ),
    );
  }

  Widget _buildPageLayout(_OnboardPageData page) {
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
                border: Border.all(color: kGoldDim, width: 2),
              ),
              child: Center(
                child: Text(
                  page.emoji, 
                  style: const TextStyle(fontSize: 54),
                ),
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
              style: const TextStyle(color: kGoldDim, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 18,
                height: 1.6,
              ),
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
  }); // FIXED: Removed extra comma before closing brace
}
