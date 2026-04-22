import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- INHE CLASS KE BAHAR RAKHEIN (Global Variables) ---
// Taki poori app inhe bina "AppColors." ke pehchan sake
const Color kBg = Color(0xFF0D0A04);
const Color kGold = Color(0xFFFFD700);
const Color kGoldLight = Color(0xFFFFEC6E); // Error fix: kGoldLight missing tha
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

// --- AUTOMATIC SAFETY ENGINE ---
class AppColors {
  static Color autoDefine(Color? input, {Color fallback = kGold}) => input ?? fallback;
}

// --- MAIN THEME DATA ---
ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    primaryColor: kGold,
    colorScheme: const ColorScheme.dark(
      primary: kGold,
      secondary: kSaffron,
      surface: kSurface,
      error: kError,
      onPrimary: kBg,
      onSurface: kText,
      outline: kDivider,
    ),
    // ... baki settings pehle jaisi
  );
}
