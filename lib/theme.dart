import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBg = Color(0xFF0D0A04);
const Color kSurface = Color(0xFF1A1500);
const Color kCard = Color(0xFF231C00);
const Color kGold = Color(0xFFFFD700);
const Color kGoldLight = Color(0xFFFFEC6E);
const Color kGoldDim = Color(0xFFB8960C);
const Color kAmber = Color(0xFFFFA500);
const Color kText = Color(0xFFF5E6C8);
const Color kTextDim = Color(0xFFAA9977);
const Color kDivider = Color(0xFF3A2E00);

// ✅ Added missing semantic colors
const Color kError = Color(0xFFCF6679);
const Color kSuccess = Color(0xFF4CAF50);
const Color kWarning = Color(0xFFFFC107);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    primaryColor: kGold,

    // ✅ FIXED + COMPLETE COLOR SCHEME
    colorScheme: const ColorScheme.dark(
      primary: kGold,
      secondary: kAmber,
      surface: kSurface,
      background: kBg,
      error: kError,

      onPrimary: kBg,
      onSecondary: kBg,
      onSurface: kText,
      onBackground: kText,
      onError: kBg,

      outline: kDivider,
      surfaceVariant: kCard,
    ),

    textTheme: GoogleFonts.crimsonTextTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: kText, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: kText, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: kText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: kText, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: kText, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: kText, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: kText),
        titleSmall: TextStyle(color: kTextDim),
        bodyLarge: TextStyle(color: kText),
        bodyMedium: TextStyle(color: kText),
        bodySmall: TextStyle(color: kTextDim),
        labelLarge: TextStyle(color: kGold, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: kGold),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: kBg,
      foregroundColor: kGold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cinzel(
        color: kGold,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      iconTheme: const IconThemeData(color: kGold),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kSurface,
      selectedItemColor: kGold,
      unselectedItemColor: kTextDim,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    cardTheme: const CardThemeData(
      color: kCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: kDivider, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGold,
        foregroundColor: kBg,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGold, width: 1.5),
      ),
      hintStyle: const TextStyle(color: kTextDim),
      labelStyle: const TextStyle(color: kGold),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: kCard,
      labelStyle: const TextStyle(color: kGold, fontSize: 12),
      side: const BorderSide(color: kDivider),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    dividerColor: kDivider,

    iconTheme: const IconThemeData(color: kGold),

    // ✅ FIXED (removed comma issue)
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kGold,
      linearTrackColor: kDivider,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kGold,
      foregroundColor: kBg,
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kCard,
      contentTextStyle: TextStyle(color: kText),
      actionTextColor: kGold,
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: kCard,
      titleTextStyle: TextStyle(
        color: kGold,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: kText),
    ),
  );
}
