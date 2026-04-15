import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  static const _pages = [
    _OnboardPage(
      emoji: '🕉️',
      title: 'Bhagavad Gita AI',
      subtitle: 'The Song of God',
      body:
          'Discover the timeless wisdom of the Bhagavad Gita — 700 verses of divine knowledge that have guided seekers for thousands of years.',
    ),
    _OnboardPage(
      emoji: '📖',
      title: 'Read & Reflect',
      subtitle: '18 Chapters of Wisdom',
      body:
          'Explore all 18 chapters with Sanskrit verses, transliterations, translations, and deep meanings. Earn XP as you journey through the teachings.',
    ),
    _OnboardPage(
      emoji: '🤖',
      title: 'Ask Krishna',
      subtitle: 'Your Divine Guide',
      body:
          'Have conversations with Lord Krishna, Radha, or your Gita Guide. Ask any question about dharma, karma, devotion, or the nature of reality.',
    ),
    _OnboardPage(
      emoji: '🧘',
      title: 'Practice Daily',
      subtitle: 'Meditation • Breathing • Japa',
      body:
          'Build a daily spiritual practice with meditation timers, pranayama breathing exercises, japa mala counter, and a personal journal.',
    ),
    _OnboardPage(
      emoji: '🌟',
      title: 'Grow Spiritually',
      subtitle: 'Track Your Journey',
      body:
          'Earn XP, level up, unlock badges, and build your streak. Quiz yourself, explore flashcards, and track your progress through all 18 chapters.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<AppState>().completeOnboarding();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
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
                itemBuilder: (ctx, i) => _buildPage(_pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _page == i ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _page == i ? kGold : kDivider,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        )),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _page == _pages.length - 1
                            ? 'Begin Your Journey  🕉️'
                            : 'Next',
                        style: GoogleFonts.cinzel(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (_page < _pages.length - 1)
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip',
                          style: TextStyle(color: kTextDim, fontSize: 13)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGold.withOpacity(0.1),
              border: Border.all(color: kGoldDim, width: 2),
            ),
            child: Center(
              child: Text(page.emoji,
                  style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            page.subtitle,
            style: const TextStyle(
                color: kGoldDim, fontSize: 14, letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            page.body,
            style: GoogleFonts.crimsonText(
                color: kText, fontSize: 17, height: 1.7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String body;
  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}
