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
  int _totalMeditationMinutes = 0; // Added for MeditationScreen
  bool _onboardingComplete = false;
  List<String> _completedChapters = [];
  
  // Accessibility & Settings
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _hapticsEnabled = true;

  // Account
  String _userName = '';
  String _userEmail = '';
  bool _isGoogleAccountLinked = false;
  List<AppNotification> _notifications = [];

  // --- Getters ---
  bool get isAdmin => _userEmail.toLowerCase() == kAdminEmail.toLowerCase();
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get xp => _xp;
  int get streak => _streak;
  int get level => (_xp / 100).floor() + 1;
  double get xpinLevel => (_xp % 100) / 100.0; 
  
  bool get onboardingComplete => _onboardingComplete;
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get reduceMotion => _reduceMotion;
  ThemeMode get themeMode => _themeMode;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isGoogleAccountLinked => _isGoogleAccountLinked;
  
  Set<String> get bookmarks => _bookmarks;
  int get quizScore => _quizScore;
  int get japaCount => _japaCount;
  int get totalMeditationMinutes => _totalMeditationMinutes; // Required for Meditation stats
  List<String> get badges => _xp > 500 ? ['Seeker', 'Devotee'] : ['Beginner'];

  // --- Functional Methods ---

  // Added specifically for your MeditationScreen _onFinish call
  void addMeditationMinutes(int minutes) {
    if (minutes <= 0) return;
    _totalMeditationMinutes += minutes;
    addXp(minutes * 2); // Awarding 2 XP per minute of meditation
    _save();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _save();
    notifyListeners();
  }

  bool isChapterCompleted(int chapterNumber) => _completedChapters.contains(chapterNumber.toString());

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

  void markVerseRead(String verseId) {
    if (!_readVerses.contains(verseId)) {
      _readVerses.add(verseId);
      addXp(5);
      _save();
      notifyListeners();
    }
  }

  void markChapterComplete(int chapterNumber) {
    if (!_completedChapters.contains(chapterNumber.toString())) {
      _completedChapters.add(chapterNumber.toString());
      addXp(100);
      _save();
      notifyListeners();
    }
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    _save();
    notifyListeners();
  }

  // --- Persistence Logic ---

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
    _largeText = prefs.getBool('largeText') ?? false;
    _completedChapters = prefs.getStringList('completedChapters') ?? [];
    _bookmarks = Set<String>.from(prefs.getStringList('bookmarks') ?? []);
    
    final tm = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == tm, 
      orElse: () => ThemeMode.system
    );

    _updateStreak();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('streak', _streak);
    await prefs.setInt('totalMeditationMinutes', _totalMeditationMinutes);
    await prefs.setBool('onboardingComplete', _onboardingComplete);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setBool('isGoogleAccountLinked', _isGoogleAccountLinked);
    await prefs.setBool('highContrast', _highContrast);
    await prefs.setBool('largeText', _largeText);
    await prefs.setStringList('completedChapters', _completedChapters);
    await prefs.setStringList('bookmarks', _bookmarks.toList());
    await prefs.setString('themeMode', _themeMode.name);
  }

  void addXp(int amount) {
    if (amount <= 0) return;
    _xp += amount;
    _save();
    notifyListeners();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastVisit != null) {
      final diff = today.difference(_lastVisit!).inDays;
      if (diff == 1) {
        _streak++;
      } else if (diff > 1) {
        _streak = 1;
      }
    } else {
      _streak = 1;
    }
    _lastVisit = today;
  }

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email.trim();
    _isGoogleAccountLinked = true;
    _save();
    notifyListeners();
  }
}
