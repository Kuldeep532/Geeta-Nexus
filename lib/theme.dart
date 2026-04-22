import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- CORE SPIRITUAL PALETTE ---
  static const Color kBg = Color(0xFF0D0A04);
  static const Color kGold = Color(0xFFFFD700);
  static const Color kSaffron = Color(0xFFFF9933);
  static const Color kVermillion = Color(0xFFE34234);
  static const Color kTurmeric = Color(0xFFFAC205);
  static const Color kLotusPink = Color(0xFFFFB7C5);

  // --- MATERIAL & METAL FINISHES ---
  static const Color kCopper = Color(0xFFB87333);
  static const Color kBronze = Color(0xFFCD7F32);
  static const Color kSilkWhite = Color(0xFFF8F4E3);
  static const Color kSandalwood = Color(0xFFC19A6B);
  
  // --- ELEMENTAL SHADES ---
  static const Color kAgni = Color(0xFFFF4500);
  static const Color kAkasha = Color(0xFF003366);
  static const Color kPrithvi = Color(0xFF3B2F2F);

  // --- UI FUNCTIONAL COLORS ---
  static const Color kSurface = Color(0xFF1A1500);
  static const Color kCard = Color(0xFF231C00);
  static const Color kText = Color(0xFFF5E6C8);
  static const Color kTextDim = Color(0xFFAA9977);
  static const Color kDivider = Color(0xFF3A2E00);
  static const Color kSuccess = Color(0xFF4CAF50);
  static const Color kError = Color(0xFFCF6679);

  static Color autoDefine(Color? inputColor, {Color fallback = kGold}) {
    return inputColor ?? fallback;
  }
}

class Verse {
  final String id;
  final String text;
  final String translation;
  const Verse({required this.id, required this.text, required this.translation});
}

class IndependentWisdomScreen extends StatelessWidget {
  const IndependentWisdomScreen({super.key});

  static const List<Verse> _verses = [
    Verse(
      id: "2.47",
      text: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।",
      translation: "Focus on your duty, not the fruits of action.",
    ),
    Verse(
      id: "6.5",
      text: "उद्धरेदात्मनात्मानं नात्मानमवसादयेत्।",
      translation: "Elevate yourself through your own mind.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors;

    return Scaffold(
      backgroundColor: c.kBg,
      appBar: AppBar(
        backgroundColor: c.kBg,
        centerTitle: true,
        title: Text(
          'DIVINE WISDOM',
          style: GoogleFonts.cinzel(
            color: c.kGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        leading: const BackButton(color: AppColors.kGold),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _verses.length,
        itemBuilder: (context, index) => _buildCard(_verses[index]),
      ),
    );
  }

  Widget _buildCard(Verse verse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "VERSE ${verse.id}",
                style: GoogleFonts.cinzel(
                  color: AppColors.kSaffron,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.auto_awesome, color: AppColors.kGold, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            verse.text,
            style: GoogleFonts.notoSansDevanagari(
              color: AppColors.kGold,
              fontSize: 18,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            verse.translation,
            style: GoogleFonts.crimsonText(
              color: AppColors.kText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
