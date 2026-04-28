import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Import
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
  List<String> _badges = [];
  
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  ThemeMode _themeMode = ThemeMode.system;

  String _userName = '';
  String _userEmail = '';
  String _userRole = 'seeker';

  // Firebase Instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  int get japaCount => _japaCount;
  List<JournalEntry> get journalEntries => _journalEntries;
  List<String> get badges => _badges; 
  double get xpinLevel => (_xp % 100) / 100.0; 
  List<Verse> get allVerses => kAllVerses; 
  int get userCurrentDay => _streak + 1; 
  int get level => (_xp / 100).floor() + 1;

  // --- Silent Firebase Sync Logic ---
  Future<void> syncUserRoleWithFirebase() async {
    if (_userEmail.isEmpty) return;

    try {
      // Silent attempt to fetch role from Firestore
      final doc = await _firestore.collection('users').doc(_userEmail).get().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Silent Timeout'),
      );

      if (doc.exists) {
        _userRole = doc.data()?['role'] ?? 'seeker';
      } else {
        // Create user document if it doesn't exist
        await _firestore.collection('users').doc(_userEmail).set({
          'name': _userName,
          'email': _userEmail,
          'role': _userEmail.toLowerCase() == kAdminEmail.toLowerCase() ? 'super_admin' : 'seeker',
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Chupchap band ho jayega, koi error UI par nahi dikhega
      debugPrint("Silent Firebase Sync: Data not available/Offline");
    }
    notifyListeners();
  }

  // --- Methods ---

  Future<void> sendGlobalNotification({required String title, required String body}) async {
    if (!isAdmin) return;
    try {
      // Writing to a global notifications collection for a cloud function to trigger
      await _firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': _userEmail,
      });
    } catch (e) {
      debugPrint("Silent Notification Failure");
    }
  }

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email;
    syncUserRoleWithFirebase(); // Role sync trigger
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

  void addJournalEntry(JournalEntry entry) {
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

  void recordQuizAnswer(bool isCorrect) {
    if (isCorrect) addXp(10);
    _save();
    notifyListeners();
  }

  void addXp(int amount) {
    _xp += amount;
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
      _userRole = prefs.getString('userRole') ?? 'seeker';
      _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
      _completedChapters = prefs.getStringList('completedChapters') ?? [];
      _badges = prefs.getStringList('badges') ?? [];
      
      final journalData = prefs.getString('journalEntries');
      if (journalData != null) {
        final List decoded = jsonDecode(journalData);
        _journalEntries = decoded.map((e) => JournalEntry.fromJson(e)).toList();
      }
      
      // Load hone ke baad Firebase se sync
      if (_userEmail.isNotEmpty) syncUserRoleWithFirebase();
    } catch (e) {
      debugPrint("Silent Load Failure");
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('xp', _xp);
      await prefs.setString('userName', _userName);
      await prefs.setString('userEmail', _userEmail);
      await prefs.setString('userRole', _userRole);
      await prefs.setBool('onboardingComplete', _onboardingComplete);
      await prefs.setStringList('completedChapters', _completedChapters);
      
      final journalJson = jsonEncode(_journalEntries.map((e) => e.toJson()).toList());
      await prefs.setString('journalEntries', journalJson);
    } catch (e) {
       debugPrint("Silent Save Failure");
    }
  }
}
