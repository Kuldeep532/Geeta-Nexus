import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../models/scripture_model.dart'; // Ensure this is imported

class AppState extends ChangeNotifier {
  // --- State Variables ---
  List<ScriptureVerse> _allVerses = []; // Added back
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

  // --- Getters ---
  List<ScriptureVerse> get allVerses => _allVerses;
  String get userName => _userName;
  int get streak => _streak;
  Set<String> get readVerses => _readVerses;
  ThemeMode get themeMode => _themeMode;
  // ... (Baaki getters pehle jaise hi rakhein)

  // --- Methods ---
  void setAllVerses(List<ScriptureVerse> verses) {
    _allVerses = verses;
    notifyListeners();
  }

  void updateTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // --- Firebase Logic ---
  FirebaseFirestore? get _firestore {
    try { return FirebaseFirestore.instance; } catch (_) { return null; }
  }

  Future<void> syncUserRoleWithFirebase() async {
    if (_userEmail.isEmpty) return;
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final doc = await firestore.collection('users').doc(_userEmail).get();
      if (doc.exists) {
        _userRole = doc.data()?['role'] ?? 'seeker';
      }
    } catch (e) { debugPrint("Error: $e"); }
    notifyListeners();
  }
}
