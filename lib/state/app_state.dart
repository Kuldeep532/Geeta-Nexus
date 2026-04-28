import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  static const String kAdminEmail = 'kuldeepky538@gmail.com';

  // --- State Variables ---
  int _xp = 0;
  int _streak = 0;
  DateTime? _lastVisit;
  Set<String> _bookmarks = {};
  Set<String> _readVerses = {};
  List<JournalEntry> _journalEntries = [];
  int _quizScore = 0;
  int _japaCount = 0;
  int _totalMeditationMinutes = 0;
  bool _onboardingComplete = false;
  List<String> _completedChapters = [];
  
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _hapticsEnabled = true;

  String _userName = '';
  String _userEmail = '';
  bool _isGoogleAccountLinked = false;

  // --- Getters ---
  bool get isAdmin => _userEmail.toLowerCase() == kAdminEmail.toLowerCase();
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get xp => _xp;
  int get streak => _streak;
  bool get onboardingComplete => _onboardingComplete;
  ThemeMode get themeMode => _themeMode;
  Set<String> get bookmarks => _bookmarks;

  // --- Onboarding Helpers (MATCHING WITH ONBOARDING SCREEN) ---

  // Onboarding screen calls this to set name manually
  void setUserName(String name) {
    _userName = name;
    _save();
    notifyListeners();
  }

  // Onboarding screen calls this at the end
  void completeOnboarding() {
    _onboardingComplete = true;
    _save();
    notifyListeners();
  }

  // Onboarding screen calls this for Google Login
  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email.trim();
    _isGoogleAccountLinked = true;
    _save();
    notifyListeners();
  }

  // --- Other Methods ---

  void addMeditationMinutes(int minutes) {
    if (minutes <= 0) return;
    _totalMeditationMinutes += minutes;
    addXp(minutes * 2);
    _save();
    notifyListeners();
  }

  void addXp(int amount) {
    if (amount <= 0) return;
    _xp += amount;
    _save();
    notifyListeners();
  }

  // --- Persistence ---

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('xp') ?? 0;
    _streak = prefs.getInt('streak') ?? 0;
    _totalMeditationMinutes = prefs.getInt('totalMeditationMinutes') ?? 0;
    _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _isGoogleAccountLinked = prefs.getBool('isGoogleAccountLinked') ?? false;
    _highContrast = prefs.getBool('highContrast') ?? false;
    _completedChapters = prefs.getStringList('completedChapters') ?? [];
    
    // ✅ FIXED: Corrected assignment
    _bookmarks = Set<String>.from(prefs.getStringList('bookmarks') ?? []);
    
    final tm = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == tm, 
      orElse: () => ThemeMode.system
    );

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('totalMeditationMinutes', _totalMeditationMinutes);
    await prefs.setBool('onboardingComplete', _onboardingComplete);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setBool('isGoogleAccountLinked', _isGoogleAccountLinked);
    await prefs.setStringList('bookmarks', _bookmarks.toList());
    await prefs.setString('themeMode', _themeMode.name);
  }
}
