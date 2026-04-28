import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/gita_data.dart'; 

class AppState extends ChangeNotifier {
  static const String kAdminEmail = 'kuldeepky538@gmail.com';

  // --- State Variables ---
  int _xp = 0;
  int _streak = 0;
  Set<String> _bookmarks = {};
  Set<String> _readVerses = {};
  List<JournalEntry> _journalEntries = [];
  int _japaCount = 0;
  bool _onboardingComplete = false;
  List<String> _completedChapters = [];
  
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  ThemeMode _themeMode = ThemeMode.system;

  String _userName = '';
  String _userEmail = '';

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
  int get japaCount => _japaCount;
  List<String> get completedChapters => _completedChapters;
  List<JournalEntry> get journalEntries => _journalEntries;

  // IMPORTANT: Corrected Getters
  List<Verse> get allVerses => kAllVerses; 
  int get userCurrentDay => _streak + 1; 

  int get level => (_xp / 100).floor() + 1;
  double get xpinlevel => (_xp % 100) / 100.0;

  // --- Methods ---

  void markChapterComplete(String chapterNumber) {
    if (!_completedChapters.contains(chapterNumber)) {
      _completedChapters.add(chapterNumber);
      addXp(50);
      _save();
      notifyListeners();
    }
  }

  void deleteJournalEntry(String id) {
    _journalEntries.removeWhere((entry) => entry.id == id);
    _save();
    notifyListeners();
  }

  Future<void> sendGlobalNotification({required String title, required String body}) async {
    debugPrint("Admin Notification: $title - $body");
    // Actual Firebase logic can be integrated here
  }

  void recordQuizAnswer(bool isCorrect) {
    if (isCorrect) addXp(10);
    _save();
    notifyListeners();
  }

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

  void markVerseRead(String verseId) {
    if (!_readVerses.contains(verseId)) {
      _readVerses.add(verseId);
      addXp(5);
      _save();
      notifyListeners();
    }
  }

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

  void addJournalEntry(JournalEntry entry) {
    _journalEntries.insert(0, entry);
    addXp(20);
    _save();
    notifyListeners();
  }

  void addXp(int amount) {
    _xp += amount; // ERROR FIX: Extra comma removed
    _save();
    notifyListeners();
  }

  void completeOnboarding(String name, String email) {
    _userName = name;
    _userEmail = email;
    _onboardingComplete = true;
    _save();
    notifyListeners();
  }

  // --- Persistence ---
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _xp = prefs.getInt('xp') ?? 0;
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
      _highContrast = prefs.getBool('highContrast') ?? false;
      _largeText = prefs.getBool('largeText') ?? false;
      _reduceMotion = prefs.getBool('reduceMotion') ?? false;
      _completedChapters = prefs.getStringList('completedChapters') ?? [];
      _bookmarks = Set<String>.from(prefs.getStringList('bookmarks') ?? []);
      _readVerses = Set<String>.from(prefs.getStringList('readVerses') ?? []);
      
      final journalData = prefs.getString('journalEntries');
      if (journalData != null) {
        final List decoded = jsonDecode(journalData);
        _journalEntries = decoded.map((e) => JournalEntry.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error loading state: $e");
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setBool('onboardingComplete', _onboardingComplete);
    await prefs.setStringList('bookmarks', _bookmarks.toList());
    await prefs.setStringList('readVerses', _readVerses.toList());
    await prefs.setStringList('completedChapters', _completedChapters);
    await prefs.setBool('highContrast', _highContrast);
    await prefs.setBool('largeText', _largeText);
    await prefs.setBool('reduceMotion', _reduceMotion);
    
    final journalJson = jsonEncode(_journalEntries.map((e) => e.toJson()).toList());
    await prefs.setString('journalEntries', journalJson);
  }
}
