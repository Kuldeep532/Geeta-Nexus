import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/gita_data.dart'; // Isse allVerses mil jayenge

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
  int _currentFlashcardIndex = 0;
  
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
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get reduceMotion => _reduceMotion;
  Set<String> get readVerses => _readVerses;
  int get totalMeditationMinutes => _totalMeditationMinutes;
  int get japaCount => _japaCount;
  List<String> get completedChapters => _completedChapters;
  int get currentFlashcardIndex => _currentFlashcardIndex;
  List<JournalEntry> get journalEntries => _journalEntries;

  // IMPORTANT: Gita Data Getters (Errors fix karne ke liye)
  List<Verse> get verses => allVerses; // GitaData se data lega
  List<Chapter> get chapters => kChapters;

  // Level Calculation
  int get level => (_xp / 100).floor() + 1;
  double get xpinlevel => (_xp % 100) / 100.0;

  // --- Methods ---

  void updateTheme(ThemeMode mode) {
    _themeMode = mode;
    _save();
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    _save();
    notifyListeners();
  }

  // Quiz Method (Screenshot mein iska error tha)
  void recordQuizAnswer(bool isCorrect) {
    if (isCorrect) {
      addXp(10);
      _quizScore += 1;
    }
    notifyListeners();
  }

  bool isChapterCompleted(String chapterNumber) => _completedChapters.contains(chapterNumber);

  void markVerseRead(String verseId) {
    _readVerses.add(verseId);
    addXp(5);
    _save();
    notifyListeners();
  }

  bool isBookmarked(String verseId) => _bookmarks.contains(verseId);

  void toggleBookmark(String verseId) {
    if (_bookmarks.contains(verseId)) {
      _bookmarks.remove(verseId);
    } else {
      _bookmarks.add(verseId);
    }
    _save();
    notifyListeners();
  }

  void incrementJapa() {
    _japaCount++;
    if (_japaCount % 108 == 0) addXp(10);
    _save();
    notifyListeners();
  }

  void resetJapa() {
    _japaCount = 0;
    _save();
    notifyListeners();
  }

  void updateFlashcardIndex(int index) {
    _currentFlashcardIndex = index;
    notifyListeners();
  }

  void addJournalEntry(JournalEntry entry) {
    _journalEntries.insert(0, entry);
    _save();
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    _save();
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingComplete = true;
    _save();
    notifyListeners();
  }

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email.trim();
    _isGoogleAccountLinked = true;
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
    _totalMeditationMinutes = prefs.getInt('totalMeditationMinutes') ?? 0;
    _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _highContrast = prefs.getBool('highContrast') ?? false;
    _japaCount = prefs.getInt('japaCount') ?? 0;
    _completedChapters = prefs.getStringList('completedChapters') ?? [];
    _bookmarks = Set<String>.from(prefs.getStringList('bookmarks') ?? []);
    _readVerses = Set<String>.from(prefs.getStringList('readVerses') ?? []);
    
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
    await prefs.setInt('japaCount', _japaCount);
    await prefs.setInt('totalMeditationMinutes', _totalMeditationMinutes);
    await prefs.setBool('onboardingComplete', _onboardingComplete);
    await prefs.setStringList('bookmarks', _bookmarks.toList());
    await prefs.setStringList('readVerses', _readVerses.toList());
    await prefs.setStringList('completedChapters', _completedChapters);
    await prefs.setString('themeMode', _themeMode.name);
    await prefs.setBool('highContrast', _highContrast);
  }
}
