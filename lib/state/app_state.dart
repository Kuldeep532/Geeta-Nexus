import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../models/scripture_model.dart';

class AppState extends ChangeNotifier {
  // ---------------- STATE VARIABLES ----------------

  List<ScriptureVerse> _allVerses = [];

  int _xp = 0;
  int _streak = 0;

  final Set<String> _bookmarks = {};
  final Set<String> _readVerses = {};
  final List<ScriptureVerse> _bookmarkedVerses = [];

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

  bool _isAdmin = false;
  bool _isSuperAdmin = false;

  int _userCurrentDay = 1;

  // ---------------- GETTERS ----------------

  List<ScriptureVerse> get allVerses => _allVerses;

  int get xp => _xp;

  int get streak => _streak;

  int get level => (_xp ~/ 100) + 1;

  Set<String> get bookmarks => _bookmarks;

  Set<String> get readVerses => _readVerses;

  List<ScriptureVerse> get bookmarkedVerses => _bookmarkedVerses;

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

  bool get isAdmin => _isAdmin;

  bool get isSuperAdmin => _isSuperAdmin;

  int? get userCurrentDay => _userCurrentDay;

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

  void completeOnboarding() {
    _onboardingComplete = true;
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

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void setSuperAdmin(bool value) {
    _isSuperAdmin = value;
    notifyListeners();
  }

  void addXp(int amount) {
    _xp += amount;
    notifyListeners();
  }

  void incrementJapa() {
    _japaCount++;
    notifyListeners();
  }

  void resetJapa() {
    _japaCount = 0;
    notifyListeners();
  }

  void addJapaCount() {
    _japaCount++;
    notifyListeners();
  }

  bool isBookmarked(String id) => _bookmarks.contains(id);

  void toggleBookmarkById(String id) {
    if (_bookmarks.contains(id)) {
      _bookmarks.remove(id);
      _bookmarkedVerses.removeWhere(
        (v) => (v.localVerseId ?? '${v.source}-${v.verseIndex}') == id,
      );
    } else {
      _bookmarks.add(id);
    }
    notifyListeners();
  }

  void toggleBookmark(dynamic verseOrId) {
    if (verseOrId is String) {
      toggleBookmarkById(verseOrId);
    } else if (verseOrId is ScriptureVerse) {
      final id = verseOrId.localVerseId ?? '${verseOrId.source}-${verseOrId.verseIndex}';
      if (_bookmarks.contains(id)) {
        _bookmarks.remove(id);
        _bookmarkedVerses.removeWhere(
          (v) => (v.localVerseId ?? '${v.source}-${v.verseIndex}') == id,
        );
      } else {
        _bookmarks.add(id);
        _bookmarkedVerses.add(verseOrId);
      }
      notifyListeners();
    }
  }

  void addJournalEntry({required String content, required String mood}) {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      content: content,
      mood: mood,
      date: DateTime.now(),
    );
    _journalEntries.insert(0, entry);
    notifyListeners();
  }

  void deleteJournalEntry(String id) {
    _journalEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void updateFlashcardIndex(int index) {
    _currentFlashcardIndex = index;
    notifyListeners();
  }

  void setUserCurrentDay(int day) {
    _userCurrentDay = day;
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

  void markChapterComplete(String chapterId) {
    completeChapter(chapterId);
  }

  void markNotificationRead(String id) {
    _notifications = _notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    notifyListeners();
  }

  Future<void> sendGlobalNotification({required String title, required String body}) async {
    final notification = AppNotification(
      id: const Uuid().v4(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> syncUserRoleWithFirebase() async {
    // Firebase sync disabled — connect real Firebase credentials to enable
  }

  // ---------------- LOAD ----------------

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingComplete = prefs.getBool('onboarding_completed') ?? false;
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _isAdmin = prefs.getBool('is_admin') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Load error: $e');
    }
  }
}
