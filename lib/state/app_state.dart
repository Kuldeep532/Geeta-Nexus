import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Remove unused imports if not needed
// import 'dart:convert';
// import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../models/scripture_model.dart';

class AppState extends ChangeNotifier {
  // ---------------- STATE VARIABLES ----------------

  List<ScriptureVerse> _allVerses = [];

  int _xp = 0;
  int _streak = 0;

  final Set<String> _bookmarks = {};
  final Set<String> _readVerses = {};

  List<JournalEntry> _journalEntries = [];

  int _japaCount = 0;

  bool _onboardingComplete = false;

  List<String> _completedChapters = [];

  final List<String> _badges = [];

  List<AppNotification> _notifications = [];

  int _currentFlashcardIndex = 0;

  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;

  ThemeMode _themeMode = ThemeMode.system;

  String _userName = '';
  String _userEmail = '';
  String _userRole = 'seeker';

  // ---------------- GETTERS ----------------

  List<ScriptureVerse> get allVerses => _allVerses;

  int get xp => _xp;

  int get streak => _streak;

  Set<String> get bookmarks => _bookmarks;

  Set<String> get readVerses => _readVerses;

  List<JournalEntry> get journalEntries => _journalEntries;

  int get japaCount => _japaCount;

  bool get onboardingComplete => _onboardingComplete;

  List<String> get completedChapters => _completedChapters;

  List<String> get badges => _badges;

  List<AppNotification> get notifications => _notifications;

  int get currentFlashcardIndex => _currentFlashcardIndex;

  bool get highContrast => _highContrast;

  bool get largeText => _largeText;

  bool get reduceMotion => _reduceMotion;

  ThemeMode get themeMode => _themeMode;

  String get userName => _userName;

  String get userEmail => _userEmail;

  String get userRole => _userRole;

  // ---------------- METHODS ----------------

  void setAllVerses(List<ScriptureVerse> verses) {
    _allVerses = verses;
    notifyListeners();
  }

  void updateTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setOnboardingComplete(bool value) {
    _onboardingComplete = value;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  void addJapaCount() {
    _japaCount++;
    notifyListeners();
  }

  bool isChapterCompleted(String chapterId) {
    return _completedChapters.contains(chapterId);
  }

  void completeChapter(String chapterId) {
    if (!_completedChapters.contains(chapterId)) {
      _completedChapters.add(chapterId);
      notifyListeners();
    }
  }

  // ---------------- FIREBASE ----------------

  FirebaseFirestore? get firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore initialization error: $e');
      return null;
    }
  }

  Future<void> syncUserRoleWithFirebase() async {
    if (_userEmail.isEmpty) return;

    final db = firestore;

    if (db == null) return;

    try {
      final doc =
          await db.collection('users').doc(_userEmail).get();

      if (doc.exists) {
        final data = doc.data();

        _userRole = data?['role']?.toString() ?? 'seeker';
      }
    } catch (e) {
      debugPrint('Firebase role sync error: $e');
    }

    notifyListeners();
  }

  // ---------------- LOAD ----------------

  Future<void> load() async {
    try {
      // SharedPreferences prefs =
      //     await SharedPreferences.getInstance();

      // Example:
      // _xp = prefs.getInt('xp') ?? 0;

      notifyListeners();
    } catch (e) {
      debugPrint('Load error: $e');
    }
  }
}
