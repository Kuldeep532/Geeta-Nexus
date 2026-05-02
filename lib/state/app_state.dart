import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../data/gita_data.dart';

class AppState extends ChangeNotifier {
  static const String kAdminEmail = 'kuldeepky538@gmail.com';

  static const String kAdminLoginPassword = String.fromEnvironment('ADMIN_LOGIN_PASSWORD', defaultValue: 'kuldeep548');

  // --- State Variables ---
  int _xp = 0;
  int _streak = 0;
  Set<String> _bookmarks = {};
  Set<String> _readVerses = {};
  List<JournalEntry> _journalEntries = [];
  int _japaCount = 0;
  bool _onboardingComplete = false;
  List<String> _completedChapters = [];
  List<String> _badges = [];
  List<AppNotification> _notifications = [];
  
  // Flashcards state
  int _currentFlashcardIndex = 0;

  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  ThemeMode _themeMode = ThemeMode.system;

  String _userName = '';
  String _userEmail = '';
  String _userRole = 'seeker';

  FirebaseFirestore? _firestoreCache;
  FirebaseFirestore? get _firestore {
    try {
      return _firestoreCache ??= FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // --- Getters ---
  bool get isAdmin => _userEmail.toLowerCase() == kAdminEmail.toLowerCase() || _userRole == 'admin' || _userRole == 'super_admin';
  bool get isSuperAdmin => _userEmail.toLowerCase() == kAdminEmail.toLowerCase() || _userRole == 'super_admin';
  
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  int get xp => _xp;
  int get streak => _streak;
  bool get onboardingComplete => _onboardingComplete;
  ThemeMode get themeMode => _themeMode;
  Set<String> get bookmarks => _bookmarks;
  Set<String> get readVerses => _readVerses;
  int get japaCount => _japaCount;
  List<JournalEntry> get journalEntries => _journalEntries;
  List<String> get badges => _badges; 
  List<AppNotification> get notifications => _notifications;
  int get currentFlashcardIndex => _currentFlashcardIndex;
  
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get reduceMotion => _reduceMotion;
  
  int get totalMeditationMinutes => 0; 

  double get xpinLevel => (_xp % 100) / 100.0; 
  
  // FIX: Build 'kAllVerses' dhund raha hai, hum ise yahan define kar rahe hain
  List<Verse> get kAllVerses => kChapters.expand((c) => c.verses).toList();
  List<Verse> get allVerses => kAllVerses; 

  int get userCurrentDay => _streak + 1; 
  int get level => (_xp / 100).floor() + 1;

  // --- Methods ---

  // FIX: Build 'updateTheme' dhund raha hai (Screenshot line 58-72)
  void updateTheme(ThemeMode mode) {
    _themeMode = mode;
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

  void updateFlashcardIndex(int index) {
    _currentFlashcardIndex = index;
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

  void markVerseRead(String verseId) {
    _readVerses.add(verseId);
    addXp(5);
    _save();
    notifyListeners();
  }

  void markVerseReadNoXp(String verseId) {
    _readVerses.add(verseId);
    _save();
    notifyListeners();
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

  bool isBookmarked(String verseId) => _bookmarks.contains(verseId);


  bool loginAdminWithCredentials({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != kAdminEmail.toLowerCase() || password != kAdminLoginPassword) {
      return false;
    }
    _userEmail = normalizedEmail;
    _userName = 'Admin';
    _userRole = 'super_admin';
    _onboardingComplete = true;
    _save();
    notifyListeners();
    return true;
  }

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email;
    syncUserRoleWithFirebase();
    _save();
    notifyListeners();
  }

  void markChapterComplete(String chapterNumber) {
    if (!_completedChapters.contains(chapterNumber)) {
      _completedChapters.add(chapterNumber);
      addXp(50);
      _save();
      notifyListeners();
    }
  }

  bool isChapterCompleted(String chapterNumber) => _completedChapters.contains(chapterNumber);

  // FIX: Build 'recordQuizAnswer' dhund raha hai (Screenshot line 93)
  void recordQuizAnswer(bool isCorrect) {
    if (isCorrect) addXp(15);
    notifyListeners();
  }

  // FIX: Build 'sendGlobalNotification' dhund raha hai (Screenshot line 104)
  Future<void> sendGlobalNotification({required String title, required String body}) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, notification);
    _save();
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || _notifications[idx].isRead) return;
    _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    _save();
    notifyListeners();
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
    _save();
    notifyListeners();
  }

  void deleteJournalEntry(String id) {
    _journalEntries.removeWhere((entry) => entry.id == id);
    _save();
    notifyListeners();
  }

  void addXp(int amount) {
    _xp += amount;
    _save();
    notifyListeners();
  }

  // --- Firebase Logic ---
  Future<void> syncUserRoleWithFirebase() async {
    if (_userEmail.isEmpty) return;
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint("Firebase Sync skipped (Firebase not initialized)");
      return;
    }
    try {
      final doc = await firestore.collection('users').doc(_userEmail).get().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Timeout'),
      );

      if (doc.exists) {
        _userRole = doc.data()?['role'] ?? 'seeker';
      } else {
        await firestore.collection('users').doc(_userEmail).set({
          'name': _userName,
          'email': _userEmail,
          'role': _userEmail.toLowerCase() == kAdminEmail.toLowerCase() ? 'super_admin' : 'seeker',
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Firebase Sync Offline");
    }
    notifyListeners();
  }

  // --- Persistence ---
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _xp = prefs.getInt('xp') ?? 0;
      _japaCount = prefs.getInt('japaCount') ?? 0;
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
      _completedChapters = prefs.getStringList('completedChapters') ?? [];
      
      final journalData = prefs.getString('journalEntries');
      final notificationsData = prefs.getString('notifications');
      if (journalData != null) {
        final List<dynamic> decoded = jsonDecode(journalData);
        _journalEntries = decoded.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (notificationsData != null) {
        final List<dynamic> decoded = jsonDecode(notificationsData);
        _notifications = decoded
            .map((e) => AppNotification.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      
      if (_userEmail.isNotEmpty) syncUserRoleWithFirebase();
    } catch (e) {
      debugPrint("Load Failure");
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('xp', _xp);
      await prefs.setInt('japaCount', _japaCount);
      await prefs.setString('userName', _userName);
      await prefs.setString('userEmail', _userEmail);
      await prefs.setBool('onboardingComplete', _onboardingComplete);
      await prefs.setStringList('completedChapters', _completedChapters);
      
      final journalJson = jsonEncode(_journalEntries.map((e) => e.toJson()).toList());
      await prefs.setString('journalEntries', journalJson);
      final notificationsJson = jsonEncode(_notifications.map((n) => n.toMap()).toList());
      await prefs.setString('notifications', notificationsJson);
    } catch (e) {
       debugPrint("Save Failure");
    }
  }
}
