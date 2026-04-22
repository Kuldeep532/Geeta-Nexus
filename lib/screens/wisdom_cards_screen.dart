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
    // Agar kWisdomCards khali hai toh error se bachne ke liye check
    final int itemCount = kWisdomCards.isNotEmpty ? kWisdomCards.length : 0;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Wisdom Cards'),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Swipe to explore divine teachings',
            style: TextStyle(color: kTextDim, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: itemCount > 0 
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: itemCount,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (ctx, i) {
                    final card = kWisdomCards[i];
                    final colors = _cardColors[i % _cardColors.length];
                    
                    // Accessibility: Card number batane ke liye
                    return Semantics(
                      label: "Card ${i + 1} of $itemCount",
                      child: AnimatedScale(
                        scale: _currentPage == i ? 1.0 : 0.93,
                        duration: const Duration(milliseconds: 300),
                        child: _buildCard(card, colors),
                      ),
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator(color: kGold)),
          ),
          const SizedBox(height: 20),
          // Page Indicator Section
          Semantics(
            label: "Page indicator. Current page is ${_currentPage + 1}",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(itemCount, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
      child: SingleChildScrollView(
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
                'Gita ${card["verse"] ?? ""}',
                style: GoogleFonts.cinzel(
                   color: kGold, 
                   fontSize: 12, 
                   letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              card['title'] ?? "",
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Accessibility: Is symbol ko hide kiya gaya hai
            const ExcludeSemantics(
              child: Text(
                '❝',
                style: TextStyle(color: kGoldDim, fontSize: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card['wisdom'] ?? "",
              style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 17,
                height: 1.8,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const ExcludeSemantics(child: Divider(color: kDivider)),
            const SizedBox(height: 12),
            const ExcludeSemantics(
              child: Icon(Icons.auto_awesome, color: kGoldDim, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
