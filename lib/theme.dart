import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- CORE COLORS (Global Variables for All Screens) ---
const Color kBg = Color(0xFF0D0A04);
const Color kGold = Color(0xFFFFD700);
const Color kGoldLight = Color(0xFFFFEC6E);
const Color kGoldDim = Color(0xFFB8960C);
const Color kSaffron = Color(0xFFFF9933);
const Color kVermillion = Color(0xFFE34234);
const Color kTurmeric = Color(0xFFFAC205);
const Color kLotusPink = Color(0xFFFFB7C5);
const Color kCopper = Color(0xFFB87333);
const Color kSurface = Color(0xFF1A1500);
const Color kCard = Color(0xFF231C00);
const Color kText = Color(0xFFF5E6C8);
const Color kTextDim = Color(0xFFAA9977);
const Color kDivider = Color(0xFF3A2E00);
const Color kError = Color(0xFFCF6679);
const Color kSuccess = Color(0xFF4CAF50);

// --- SEARCH TOPICS (Fixes Search Screen Error) ---
const List<String> kSpiritualTopics = [
  'Karma', 'Bhakti', 'Yoga', 'Gyan', 'Dharma', 
  'Meditation', 'Peace', 'Soul', 'Duty', 'Mind'
];

// --- FALLBACK CLASS ---
class AppColors {
  static Color autoDefine(Color? input, {Color fallback = kGold}) => input ?? fallback;
}

// --- THEME BUILDER ---
ThemeData buildTheme() {
  final Color primaryColor = kGold;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    primaryColor: primaryColor,
    
    colorScheme: const ColorScheme.dark(
      primary: kGold,
      secondary: kSaffron,
      surface: kSurface,
      error: kError,
      onPrimary: kBg,
      onSurface: kText,
      outline: kDivider,
    ),

    textTheme: GoogleFonts.crimsonTextTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: kGold, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: kText),
        bodySmall: TextStyle(color: kTextDim),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: kBg,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cinzel(
        color: kGold,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: kGold),
    ),

    cardTheme: CardTheme(
      color: kCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kDivider),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: kGold, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: kDivider),
      ),
    ),
  );
}
