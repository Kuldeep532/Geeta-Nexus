import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/gita_data.dart';
import '../models/models.dart';

class WisdomCardsScreen extends StatefulWidget {
  const WisdomCardsScreen({super.key});

  @override
  State<WisdomCardsScreen> createState() => _WisdomCardsScreenState();
}

class _WisdomCardsScreenState extends State<WisdomCardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  List<Verse> _wisdomList = [];

  @override
  void initState() {
    super.initState();
    _loadRandomWisdom();
  }

  void _loadRandomWisdom() {
    // FIXED: Ensure getAllVerses() is called to fetch the list
    final all = getAllVerses(); 
    if (all.isNotEmpty) {
      final random = Random();
      var shuffled = List<Verse>.from(all)..shuffle(random);
      setState(() {
        _wisdomList = shuffled.take(15).toList();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = _wisdomList.length;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('WISDOM CARDS', style: GoogleFonts.cinzel(color: kGold, fontSize: 16)),
        centerTitle: true,
        leading: const BackButton(color: kGold),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Swipe to explore divine teachings',
            style: TextStyle(color: kTextDim, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: itemCount > 0 
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: itemCount,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (ctx, i) {
                    final verse = _wisdomList[i];
                    final colors = _cardColors[i % _cardColors.length];
                    
                    return AnimatedScale(
                      scale: _currentPage == i ? 1.0 : 0.93,
                      duration: const Duration(milliseconds: 300),
                      child: _buildCard(verse, colors),
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator(color: kGold)),
          ),
          const SizedBox(height: 20),
          _buildIndicator(itemCount),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard(Verse verse, List<Color> colors) {
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
        border: Border.all(color: kGoldDim.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGoldDim.withOpacity(0.5)),
            ),
            child: Text(
              'Gita ${verse.id}', // Using verse.id for clean reference
              style: GoogleFonts.cinzel(color: kGold, fontSize: 11),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Divine Guidance", // FIXED: Removed extra comma inside string
            style: GoogleFonts.cinzel(
              color: kGold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          const Icon(Icons.format_quote, color: kGoldDim, size: 30),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                verse.translation,
                style: GoogleFonts.crimsonText(
                  color: kText,
                  fontSize: 18,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          const Icon(Icons.auto_awesome, color: kGoldDim, size: 18),
        ],
      ),
    );
  }

  Widget _buildIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
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
    );
  }

  static const _cardColors = [
    [Color(0xFF2A1F00), Color(0xFF1A1500)],
    [Color(0xFF001A30), Color(0xFF001020)],
    [Color(0xFF1A0030), Color(0xFF100020)],
    [Color(0xFF2A0A00), Color(0xFF1A0800)],
  ]; // FIXED: Removed leading comma and closed properly
}
