import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  static const String kAdminEmail = 'kuldeepky538@gmail.com';
  // --- Private State ---
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
  int _currentFlashcardIndex = 0;
  String _userName = '';
  String _userEmail = '';
  bool _isGoogleAccountLinked = false;
  List<AppNotification> _notifications = [];
  ThemeMode _themeMode = ThemeMode.system;

  // --- Getters ---
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isGoogleAccountLinked => _isGoogleAccountLinked;
  bool get isAdmin => _userEmail.toLowerCase() == kAdminEmail;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;
  ThemeMode get themeMode => _themeMode;
  int get xp => _xp;
  int get streak => _streak;
  DateTime? get lastVisit => _lastVisit;
  Set<String> get bookmarks => _bookmarks;
  Set<String> get readVerses => _readVerses;
  List<JournalEntry> get journalEntries => List.unmodifiable(_journalEntries);
  int get quizScore => _quizScore;
  int get totalQuizAnswered => _totalQuizAnswered;
  int get japaCount => _japaCount;
  int get totalMeditationMinutes => _totalMeditationMinutes;
  bool get onboardingComplete => _onboardingComplete;
  int get currentReadingChapter => _currentReadingChapter;
  List<String> get completedChapters => List.unmodifiable(_completedChapters);
  int get currentFlashcardIndex => _currentFlashcardIndex;

  // Compatibility getter for reading plan screens
  int? get userCurrentDay => _currentReadingChapter; 

  int get level => (_xp / 100).floor() + 1;
  int get xpInLevel => _xp % 100;
  double get quizAccuracy =>
      _totalQuizAnswered == 0 ? 0 : _quizScore / _totalQuizAnswered;

  // --- Methods ---

  void updateFlashcardIndex(int index) {
    _currentFlashcardIndex = index;
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('xp') ?? 0;
    _streak = prefs.getInt('streak') ?? 0;
    
    final lastVisitStr = prefs.getString('lastVisit');
    if (lastVisitStr != null) {
      _lastVisit = DateTime.tryParse(lastVisitStr);
    }
    
    _bookmarks = Set<String>.from(prefs.getStringList('bookmarks') ?? []);
    _readVerses = Set<String>.from(prefs.getStringList('readVerses') ?? []);
    _quizScore = prefs.getInt('quizScore') ?? 0;
    _totalQuizAnswered = prefs.getInt('totalQuizAnswered') ?? 0;
    _japaCount = prefs.getInt('japaCount') ?? 0;
    _totalMeditationMinutes = prefs.getInt('totalMeditationMinutes') ?? 0;
    _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    _currentReadingChapter = prefs.getInt('currentReadingChapter') ?? 1;
    _completedChapters = prefs.getStringList('completedChapters') ?? [];
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _isGoogleAccountLinked = prefs.getBool('isGoogleAccountLinked') ?? false;
    final notificationJson = prefs.getStringList('notifications') ?? [];
    _notifications = notificationJson
        .map((e) => AppNotification.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final tm = prefs.getString('themeMode') ?? 'system';
    _themeMode = tm == 'light'
        ? ThemeMode.light
        : tm == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;

    final journalJson = prefs.getStringList('journalEntries') ?? [];
    _journalEntries = journalJson
        .map((e) => JournalEntry.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    _updateStreak();
    notifyListeners();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastVisit == null) {
      _streak = 1;
      _lastVisit = today;
      _save();
      return;
    }
    
    final lastDay = DateTime(_lastVisit!.year, _lastVisit!.month, _lastVisit!.day);
    final diff = today.difference(lastDay).inDays;
    
    if (diff == 0) return;
    if (diff == 1) {
      _streak++;
    } else {
      _streak = 1;
    }
    _lastVisit = today;
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('streak', _streak);
    
    if (_lastVisit != null) {
      await prefs.setString('lastVisit', _lastVisit!.toIso8601String());
    }
    
    await prefs.setStringList('bookmarks', _bookmarks.toList());
    await prefs.setStringList('readVerses', _readVerses.toList());
    await prefs.setInt('quizScore', _quizScore);
    await prefs.setInt('totalQuizAnswered', _totalQuizAnswered);
    await prefs.setInt('japaCount', _japaCount);
    await prefs.setInt('totalMeditationMinutes', _totalMeditationMinutes); 
    await prefs.setBool('onboardingComplete', _onboardingComplete);
    await prefs.setInt('currentReadingChapter', _currentReadingChapter);
    await prefs.setStringList('completedChapters', _completedChapters);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setBool('isGoogleAccountLinked', _isGoogleAccountLinked);
    final notificationsJson =
        _notifications.map((n) => jsonEncode(n.toMap())).toList();
    await prefs.setStringList('notifications', notificationsJson);
    await prefs.setString(
        'themeMode',
        _themeMode == ThemeMode.light
            ? 'light'
            : _themeMode == ThemeMode.dark
                ? 'dark'
                : 'system');
    
    final journalJson = _journalEntries.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('journalEntries', journalJson);
  }

  // --- Feature Logic ---

  void addXp(int amount) {
    _xp += amount;
    notifyListeners();
    _save();
  }

  void markChapterComplete(int chapterNumber) {
    final key = 'chapter_$chapterNumber';
    if (!_completedChapters.contains(key)) {
      _completedChapters.add(key);
      addXp(100);
      notifyListeners();
      _save();
    }
  }

  void toggleBookmark(String verseId) {
    if (_bookmarks.contains(verseId)) {
      _bookmarks.remove(verseId);
    } else {
      _bookmarks.add(verseId);
      addXp(5);
    }
    notifyListeners();
    _save();
  }

  bool isBookmarked(String verseId) => _bookmarks.contains(verseId);

  void markVerseRead(String verseId) {
    if (!_readVerses.contains(verseId)) {
      _readVerses.add(verseId);
      addXp(10);
      notifyListeners();
      _save();
    }
  }

  void recordQuizAnswer(bool correct) {
    _totalQuizAnswered++;
    if (correct) {
      _quizScore++;
      addXp(20);
    } else {
      addXp(2);
    }
    notifyListeners();
    _save();
  }

  // MATCH FIX: Changed to named parameters to match UI calls
  void addJournalEntry({required String content, required String mood, String? id}) {
    final entry = JournalEntry(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      mood: mood,
      date: DateTime.now(),
    );
    _journalEntries.insert(0, entry);
    addXp(15);
    notifyListeners();
    _save();
  }

  void deleteJournalEntry(String id) {
    _journalEntries.removeWhere((e) => e.id == id);
    notifyListeners();
    _save();
  }

  void incrementJapa() {
    _japaCount++;
    if (_japaCount % 108 == 0) addXp(50);
    notifyListeners();
    _save();
  }

  void resetJapa() {
    _japaCount = 0;
    notifyListeners();
    _save();
  }

  void addMeditationMinutes(int minutes) {
    _totalMeditationMinutes += minutes;
    addXp(minutes * 5);
    notifyListeners();
    _save();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _save();
  }

  void setUserName(String name) {
    _userName = name.trim();
    notifyListeners();
    _save();
  }

  void updateGoogleAccount({required String name, required String email}) {
    _userName = name.trim();
    _userEmail = email.trim();
    _isGoogleAccountLinked = true;
    notifyListeners();
    _save();
  }

  void clearGoogleAccount() {
    _userName = '';
    _userEmail = '';
    _isGoogleAccountLinked = false;
    notifyListeners();
    _save();
  }

  void sendAdminNotification({required String title, required String body}) {
    if (!isAdmin) return;
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      body: body.trim(),
      createdAt: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, notification);
    notifyListeners();
    _save();
  }

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index < 0 || _notifications[index].isRead) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
    _save();
  }

  void completeOnboarding() {
    _onboardingComplete = true;
    _xp = 50;
    notifyListeners();
    _save();
  }

  void setCurrentReadingChapter(int chapter) {
    _currentReadingChapter = chapter;
    notifyListeners();
    _save();
  }

  bool isChapterCompleted(int chapterNumber) =>
      _completedChapters.contains('chapter_$chapterNumber');

  // --- Badges Logic ---
  List<Map<String, dynamic>> get badges {
    final result = <Map<String, dynamic>>[];
    if (_xp >= 50) result.add({'icon': '🌱', 'name': 'Seeker', 'desc': 'Started the journey'});
    if (_streak >= 3) result.add({'icon': '🔥', 'name': 'Devoted', 'desc': '3-day streak'});
    if (_streak >= 7) result.add({'icon': '⚡', 'name': 'Yogi', 'desc': '7-day streak'});
    if (_readVerses.length >= 5) result.add({'icon': '📖', 'name': 'Scholar', 'desc': 'Read 5 verses'});
    if (_readVerses.length >= 20) result.add({'icon': '🏛️', 'name': 'Sage', 'desc': 'Read 20 verses'});
    if (_quizScore >= 10) result.add({'icon': '🎯', 'name': 'Sharp Mind', 'desc': '10 correct answers'});
    if (_japaCount >= 108) result.add({'icon': '📿', 'name': 'Japa Yogi', 'desc': 'Completed one mala'});
    if (_totalMeditationMinutes >= 60) result.add({'icon': '🧘', 'name': 'Meditator', 'desc': '1 hour of meditation'});
    if (_journalEntries.isNotEmpty) result.add({'icon': '✍️', 'name': 'Reflector', 'desc': 'First journal entry'});
    if (_bookmarks.length >= 5) result.add({'icon': '🔖', 'name': 'Collector', 'desc': '5 bookmarks'});
    return result;
  }
}
