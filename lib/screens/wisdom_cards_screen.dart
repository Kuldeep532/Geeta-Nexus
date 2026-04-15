import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/gita_data.dart';

class WisdomCardsScreen extends StatefulWidget {
  const WisdomCardsScreen({super.key});

  @override
  State<WisdomCardsScreen> createState() => _WisdomCardsScreenState();
}

class _WisdomCardsScreenState extends State<WisdomCardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Wisdom Cards'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Swipe to explore divine teachings',
            style: const TextStyle(color: kTextDim, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: kWisdomCards.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, i) {
                final card = kWisdomCards[i];
                final colors = _cardColors[i % _cardColors.length];
                return AnimatedScale(
                  scale: _currentPage == i ? 1.0 : 0.93,
                  duration: const Duration(milliseconds: 300),
                  child: _buildCard(card, colors),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(kWisdomCards.length, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == i ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i ? kGold : kDivider,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static const _cardColors = [
    [Color(0xFF2A1F00), Color(0xFF1A1500)],
    [Color(0xFF001A30), Color(0xFF001020)],
    [Color(0xFF1A0030), Color(0xFF100020)],
    [Color(0xFF001A10), Color(0xFF001008)],
    [Color(0xFF2A0A00), Color(0xFF1A0800)],
  ];

  Widget _buildCard(Map<String, String> card, List<Color> colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGoldDim.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGoldDim),
            ),
            child: Text(
              'Gita ${card["verse"]!}',
              style: GoogleFonts.cinzel(color: kGold, fontSize: 12, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            card['title']!,
            style: GoogleFonts.cinzel(
              color: kGold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            '❝',
            style: TextStyle(color: kGoldDim.withOpacity(0.5), fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            card['wisdom']!,
            style: GoogleFonts.crimsonText(
              color: kText,
              fontSize: 17,
              height: 1.8,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(color: kDivider),
          const SizedBox(height: 12),
          const Icon(Icons.auto_awesome, color: kGoldDim, size: 20),
        ],
      ),
    );
  }
}
