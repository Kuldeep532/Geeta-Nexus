import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../data/gita_data.dart';

class AppState extends ChangeNotifier {
  // --- State Variables ---
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
  String _userRole = 'seeker'; // Default role

  FirebaseFirestore? _firestoreCache;
  FirebaseFirestore? get _firestore {
    try {
      return _firestoreCache ??= FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // --- Admin Validation (Directly from Firebase role) ---
  bool get isAdmin => _userRole == 'admin' || _userRole == 'super_admin';
  bool get isSuperAdmin => _userRole == 'super_admin';
  
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
  
  // --- Methods ---

  // ... (Baaki sab methods same rahenge: updateTheme, setUserName, etc.)

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email;
    // Firebase se role sync hoga
    syncUserRoleWithFirebase();
    _save();
    notifyListeners();
  }

  // --- Firebase Logic ---
  Future<void> syncUserRoleWithFirebase() async {
    if (_userEmail.isEmpty) return;
    final firestore = _firestore;
    if (firestore == null) return;
    
    try {
      final doc = await firestore.collection('users').doc(_userEmail).get().timeout(
        const Duration(seconds: 5),
      );

      if (doc.exists) {
        _userRole = doc.data()?['role'] ?? 'seeker';
      } else {
        // Naye user ka default role 'seeker' rakha gaya hai
        await firestore.collection('users').doc(_userEmail).set({
          'name': _userName,
          'email': _userEmail,
          'role': 'seeker', 
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _userRole = 'seeker';
      }
    } catch (e) {
      debugPrint("Firebase Sync Error: $e");
    }
    notifyListeners();
  }

  // --- Persistence ---
  Future<void> load() async {
    // ... (Load logic same rahega)
    if (_userEmail.isNotEmpty) syncUserRoleWithFirebase();
    notifyListeners();
  }

  Future<void> _save() async {
    // ... (Save logic same rahega)
  }
}
