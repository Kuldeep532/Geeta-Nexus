import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBranding {
  static const String logoPath = 'assets/images/Logo.png';
  static const Color shyamBlue = Color(0xFF001A4D);
}

const Color kBg = Color(0xFF0D0A04);
const Color kGold = Color(0xFFFFD700);
const Color kGoldLight = Color(0xFFFFEC6E);
const Color kGoldDim = Color(0xFFB8960C);
const Color kSaffron = Color(0xFFFF9933);
const Color kSurface = Color(0xFF1A1500);
const Color kCard = Color(0xFF231C00);
const Color kText = Color(0xFFF5E6C8);
const Color kTextDim = Color(0xFFAA9977);
const Color kDivider = Color(0xFF3A2E00);
const Color kError = Color(0xFFCF6679);
const Color kSuccess = Color(0xFF4CAF50);

const List<String> kSpiritualTopics = [
  'Karma', 'Bhakti', 'Yoga', 'Gyan', 'Dharma', 
  'Meditation', 'Peace', 'Soul', 'Duty', 'Mind'
];

ThemeData buildLightTheme() {
  const Color lBg = Color(0xFFFFF8E7);
  const Color lSurface = Color(0xFFFFF1CE);
  const Color lCard = Color(0xFFFFFAEA);
  const Color lText = Color(0xFF2A1F00);
  const Color lTextDim = Color(0xFF7A6A3A);
  const Color lDivider = Color(0xFFE5D499);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lBg,
    primaryColor: kGoldDim,
    dividerColor: lDivider, 
    hintColor: lTextDim,     
    colorScheme: ColorScheme.light(
      primary: kGoldDim,
      secondary: kSaffron,
      tertiary: const Color(0xFFD35400),
      surface: lSurface,
      error: kError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: lText,
      primaryContainer: const Color(0xFFFFF3CD),
      secondaryContainer: const Color(0xFFFFE0B2),
      tertiaryContainer: const Color(0xFFFFCCBC),
      surfaceContainer: lCard,
      outline: lDivider,
    ),
    textTheme: GoogleFonts.crimsonTextTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: kGoldDim, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: kGoldDim, fontWeight: FontWeight.bold), 
        bodyLarge: TextStyle(color: lText),
        bodySmall: TextStyle(color: lTextDim),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lBg,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.cinzel(
        color: kGoldDim,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: kGoldDim),
    ),
    cardTheme: CardThemeData(
      color: lCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: lDivider),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lSurface,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: kGoldDim, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: lDivider),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    primaryColor: kGold,
    dividerColor: kDivider, 
    hintColor: kTextDim,    
    colorScheme: const ColorScheme.dark(
      primary: kGold,
      secondary: kSaffron,
      tertiary: Color(0xFFE67E22),
      surface: kSurface,
      error: kError,
      onPrimary: kBg,
      onSecondary: kBg,
      onTertiary: Colors.black,
      onSurface: kText,
      primaryContainer: Color(0xFF4A3E00),
      secondaryContainer: Color(0xFF5D3A00),
      tertiaryContainer: Color(0xFF4D2600),
      surfaceContainer: kCard,
      outline: kDivider,
    ),
    textTheme: GoogleFonts.crimsonTextTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: kGold, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: kGold, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: kText),
        bodySmall: TextStyle(color: kTextDim),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBg,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(color: kGold, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: kGold),
    ),
    cardTheme: CardThemeData(
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
