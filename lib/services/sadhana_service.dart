import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class SadhanaTask {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int targetMinutes;
  final bool isCompleted;
  final int completedMinutes;
  final DateTime? completedAt;

  const SadhanaTask({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.targetMinutes = 0,
    this.isCompleted = false,
    this.completedMinutes = 0,
    this.completedAt,
  });

  SadhanaTask copyWith({
    bool? isCompleted,
    int? completedMinutes,
    DateTime? completedAt,
  }) {
    return SadhanaTask(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
      targetMinutes: targetMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconName': iconName,
    'targetMinutes': targetMinutes,
    'isCompleted': isCompleted,
    'completedMinutes': completedMinutes,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory SadhanaTask.fromJson(Map<String, dynamic> json) => SadhanaTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    iconName: json['iconName'] as String,
    targetMinutes: json['targetMinutes'] as int? ?? 0,
    isCompleted: json['isCompleted'] == true,
    completedMinutes: json['completedMinutes'] as int? ?? 0,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );
}

class DailySadhanaRecord {
  final DateTime date;
  final List<SadhanaTask> tasks;
  final int totalMinutes;

  const DailySadhanaRecord({
    required this.date,
    required this.tasks,
    this.totalMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'totalMinutes': totalMinutes,
  };

  factory DailySadhanaRecord.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    final tasks = (json['tasks'] as List<dynamic>?)
        ?.map((e) => SadhanaTask.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return DailySadhanaRecord(
      date: date,
      tasks: tasks,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
    );
  }
}

class SadhanaService extends ChangeNotifier {
  static const String _key = 'daily_sadhana_records_v1';
  final List<DailySadhanaRecord> _records = [];

  List<DailySadhanaRecord> get records => List.unmodifiable(_records);

  static const List<SadhanaTask> _defaultTasks = [
    SadhanaTask(
      id: 'japa',
      title: 'Japa Mala',
      description: 'Chant Hare Krishna or your chosen mantra',
      iconName: 'rosary',
      targetMinutes: 15,
    ),
    SadhanaTask(
      id: 'meditation',
      title: 'Dhyana (Meditation)',
      description: 'Sit in silence and observe your breath',
      iconName: 'meditation',
      targetMinutes: 10,
    ),
    SadhanaTask(
      id: 'gita_reading',
      title: 'Gita Path',
      description: 'Read and reflect on one verse or chapter',
      iconName: 'book',
      targetMinutes: 10,
    ),
    SadhanaTask(
      id: 'prayer',
      title: 'Prarthana (Prayer)',
      description: 'Offer gratitude and set intentions',
      iconName: 'prayer',
      targetMinutes: 5,
    ),
    SadhanaTask(
      id: 'satsang',
      title: 'Satsang / Reflection',
      description: 'Listen to a discourse or spiritual talk',
      iconName: 'community',
      targetMinutes: 15,
    ),
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _records.clear();
        _records.addAll(
          list.map((e) => DailySadhanaRecord.fromJson(e as Map<String, dynamic>)),
        );
      } catch (e) {
        debugPrint('SadhanaService load error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_records.map((r) => r.toJson()).toList()),
    );
  }

  DailySadhanaRecord getToday() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final idx = _records.indexWhere(
      (r) => DateTime(r.date.year, r.date.month, r.date.day) == today,
    );
    if (idx >= 0) return _records[idx];

    // Create new record with default tasks
    final newRecord = DailySadhanaRecord(
      date: today,
      tasks: List.from(_defaultTasks),
    );
    _records.add(newRecord);
    return newRecord;
  }

  Future<void> toggleTask(String taskId, {bool completed = true, int minutes = 0}) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final idx = _records.indexWhere(
      (r) => DateTime(r.date.year, r.date.month, r.date.day) == today,
    );

    if (idx < 0) {
      final newRecord = DailySadhanaRecord(
        date: today,
        tasks: _defaultTasks.map((t) {
          if (t.id == taskId) {
            return t.copyWith(
              isCompleted: completed,
              completedMinutes: minutes,
              completedAt: completed ? DateTime.now() : null,
            );
          }
          return t;
        }).toList(),
      );
      _records.add(newRecord);
    } else {
      final record = _records[idx];
      final updatedTasks = record.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            isCompleted: completed,
            completedMinutes: minutes,
            completedAt: completed ? DateTime.now() : null,
          );
        }
        return t;
      }).toList();
      _records[idx] = DailySadhanaRecord(
        date: record.date,
        tasks: updatedTasks,
        totalMinutes: _calculateTotalMinutes(updatedTasks),
      );
    }

    await _save();
    notifyListeners();
  }

  int _calculateTotalMinutes(List<SadhanaTask> tasks) {
    return tasks.fold(0, (sum, t) => sum + t.completedMinutes);
  }

  int get currentStreak {
    if (_records.isEmpty) return 0;
    int streak = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    for (int i = _records.length - 1; i >= 0; i--) {
      final recordDate = DateTime(_records[i].date.year, _records[i].date.month, _records[i].date.day);
      final expectedDate = today.subtract(Duration(days: streak));
      if (recordDate == expectedDate && _hasCompletedAnyTask(_records[i])) {
        streak++;
      } else if (recordDate == expectedDate) {
        break;
      } else {
        break;
      }
    }
    return streak;
  }

  bool _hasCompletedAnyTask(DailySadhanaRecord record) {
    return record.tasks.any((t) => t.isCompleted);
  }

  double get todayCompletionPercent {
    final today = getToday();
    if (today.tasks.isEmpty) return 0.0;
    final completed = today.tasks.where((t) => t.isCompleted).length;
    return completed / today.tasks.length;
  }
}
