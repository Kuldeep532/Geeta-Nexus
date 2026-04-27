import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// [AppState] - App ka Central Command Center
/// Ismein Admin detection, XP tracking, aur Data Persistence sab kuch hai.
class AppState extends ChangeNotifier {
  // --- Static Admin Configuration ---
  static const String kAdminEmail = 'kuldeepky538@gmail.com';

  // --- Private State Variables ---
  int _xp = 0;
  int _streak = 0;
  DateTime? _lastVisit;
  Set<String> _bookmarks = {};
  Set<String> _readVerses = {};
  List<JournalEntry> _journalEntries = [];
  int _quizScore = 0;
  int _totalQuizAnswered = 0;
  int _japaCount = 0;
  int _totalMeditationMinutes = 0;
  bool _onboardingComplete = false;
  int _currentReadingChapter = 1;
  List<String> _completedChapters = [];
  
  // User Profile & Account
  String _userName = '';
  String _userEmail = '';
  bool _isGoogleAccountLinked = false;
  bool _isEmailAccountLinked = false;
  
  // App System
  List<AppNotification> _notifications = [];
  ThemeMode _themeMode = ThemeMode.system;
  bool _hapticsEnabled = true;

  // --- Getters (Safe & Accessible) ---
  
  // Admin Detection Logic
  bool get isAdmin => _userEmail.toLowerCase() == kAdminEmail.toLowerCase();
  
  // Profile Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get xp => _xp;
  int get streak => _streak;
  int get level => (_xp / 100).floor() + 1;
  bool get onboardingComplete => _onboardingComplete;
  
  // Settings Getters
  ThemeMode get themeMode => _themeMode;
  bool get hapticsEnabled => _hapticsEnabled;

  // Unmodifiable Lists (Safety: UI cannot accidentally corrupt data)
  List<JournalEntry> get journalEntries => List.unmodifiable(_journalEntries);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  Set<String> get readVerses => Set.unmodifiable(_readVerses);
  Set<String> get bookmarks => Set.unmodifiable(_bookmarks);

  // --- Initialization & Persistence ---

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Basic Data
    _xp = prefs.getInt('xp') ?? 0;
    _streak = prefs.getInt('streak') ?? 0;
    _quizScore = prefs.getInt('quizScore') ?? 0;
    _totalQuizAnswered = prefs.getInt('totalQuizAnswered') ?? 0;
    _japaCount = prefs.getInt('japaCount') ?? 0;
    _totalMeditationMinutes = prefs.getInt('totalMeditationMinutes') ?? 0;
    _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    
    // User Info
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _isGoogleAccountLinked = prefs.getBool('isGoogleAccountLinked') ?? false;

    // Collections
    _bookmarks = Set<String>.from(prefs.getStringList('bookmarks') ?? []);
    _readVerses = Set<String>.from(prefs.getStringList('readVerses') ?? []);
    _completedChapters = prefs.getStringList('completedChapters') ?? [];

    // Date Logic
    final lastVisitStr = prefs.getString('lastVisit');
    if (lastVisitStr != null) _lastVisit = DateTime.tryParse(lastVisitStr);

    // Complex Objects (JSON)
    _notifications = (prefs.getStringList('notifications') ?? [])
        .map((e) => AppNotification.fromMap(jsonDecode(e)))
        .toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _journalEntries = (prefs.getStringList('journalEntries') ?? [])
        .map((e) => JournalEntry.fromMap(jsonDecode(e)))
        .toList()..sort((a, b) => b.date.compareTo(a.date));

    // Theme Settings
    final tm = prefs.getString('themeMode') ?? 'system';
    _themeMode = tm == 'light' ? ThemeMode.light : tm == 'dark' ? ThemeMode.dark : ThemeMode.system;
    _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;

    _updateStreak();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('streak', _streak);
    if (_lastVisit != null) await prefs.setString('lastVisit', _lastVisit!.toIso8601String());
    
    await prefs.setStringList('bookmarks', _bookmarks.toList());
    await prefs.setStringList('readVerses', _readVerses.toList());
    await prefs.setBool('onboardingComplete', _onboardingComplete);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setBool('isGoogleAccountLinked', _isGoogleAccountLinked);

    // Save JSON Lists
    await prefs.setStringList('notifications', _notifications.map((n) => jsonEncode(n.toMap())).toList());
    await prefs.setStringList('journalEntries', _journalEntries.map((e) => jsonEncode(e.toMap())).toList());
    
    await prefs.setString('themeMode', _themeMode.name);
    await prefs.setBool('hapticsEnabled', _hapticsEnabled);
  }

  // --- Feature Logic ---

  void addXp(int amount) {
    if (amount <= 0) return;
    _xp += amount;
    _save();
    notifyListeners();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastVisit == null) {
      _streak = 1;
    } else {
      final lastDay = DateTime(_lastVisit!.year, _lastVisit!.month, _lastVisit!.day);
      final diff = today.difference(lastDay).inDays;
      
      if (diff == 0) return; // Already visited today
      if (diff == 1) _streak++; else _streak = 1;
    }
    _lastVisit = today;
    _save();
  }

  // --- Admin Specific Methods ---

  /// Sirf Admin hi poore app ke users ke liye notification bhej sakta hai
  void sendGlobalNotification({required String title, required String body}) {
    if (!isAdmin) return; // Critical Security Check

    final newNotif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, newNotif);
    addXp(50); // Malik ko bhi reward!
    notifyListeners();
    _save();
  }

  // --- User Account Methods ---

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email.trim();
    _isGoogleAccountLinked = true;
    
    if (isAdmin) {
      debugPrint("ADMIN DETECTED: Welcome Kuldeep.");
    }
    
    notifyListeners();
    _save();
  }

  void setUserName(String name) {
    _userName = name.trim();
    notifyListeners();
    _save();
  }

  void completeOnboarding() {
    _onboardingComplete = true;
    addXp(100);
    _save();
    notifyListeners();
  }

  // --- Spiritual Progress Methods ---

  void incrementJapa() {
    _japaCount++;
    if (_japaCount % 108 == 0) addXp(50);
    notifyListeners();
    _save();
  }

  void addMeditationMinutes(int minutes) {
    _totalMeditationMinutes += minutes;
    addXp(minutes * 2);
    notifyListeners();
    _save();
  }

  void toggleBookmark(String verseId) {
    _bookmarks.contains(verseId) ? _bookmarks.remove(verseId) : _bookmarks.add(verseId);
    notifyListeners();
    _save();
  }

  void addJournalEntry({required String content, required String mood}) {
    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      mood: mood,
      date: DateTime.now(),
    );
    _journalEntries.insert(0, entry);
    addXp(20);
    notifyListeners();
    _save();
  }
}
