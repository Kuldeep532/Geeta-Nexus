import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sadhana_service.dart';
import '../theme.dart';

/// Daily Sadhana — Spiritual Routine Tracker
/// Tracks morning/evening spiritual practices with streaks and haptic feedback.
class DailySadhanaScreen extends StatefulWidget {
  const DailySadhanaScreen({super.key});

  @override
  State<DailySadhanaScreen> createState() => _DailySadhanaScreenState();
}

class _DailySadhanaScreenState extends State<DailySadhanaScreen> {
  late SadhanaService _service;
  bool _isLoading = true;
  Timer? _activeTimer;
  String? _activeTaskId;
  int _activeSeconds = 0;

  @override
  void initState() {
    super.initState();
    _service = SadhanaService();
    _load();
  }

  @override
  void dispose() {
    _activeTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    await _service.load();
    if (mounted) setState(() => _isLoading = false);
  }

  void _startTimer(String taskId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _activeTaskId = taskId;
      _activeSeconds = 0;
    });
    _activeTimer?.cancel();
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _activeSeconds++);
    });
  }

  void _stopTimer() {
    HapticFeedback.mediumImpact();
    _activeTimer?.cancel();
    if (_activeTaskId != null) {
      final minutes = _activeSeconds ~/ 60;
      _service.toggleTask(_activeTaskId!, completed: true, minutes: minutes > 0 ? minutes : 1);
    }
    setState(() {
      _activeTaskId = null;
      _activeSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'rosary': return Icons.fiber_manual_record;
      case 'meditation': return Icons.self_improvement;
      case 'book': return Icons.menu_book;
      case 'prayer': return Icons.wb_sunny;
      case 'community': return Icons.people;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Semantics(
            header: true,
            child: Text('Daily Sadhana', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: kGold)),
      );
    }

    final today = _service.getToday();
    final completedCount = today.tasks.where((t) => t.isCompleted).length;
    final totalTasks = today.tasks.length;
    final progress = totalTasks > 0 ? completedCount / totalTasks : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text('Daily Sadhana', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
        ),
        actions: [
          Semantics(
            label: 'Current streak: ${_service.currentStreak} days',
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: kSaffron, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_service.currentStreak}',
                      style: GoogleFonts.poppins(
                        color: kSaffron,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress header
          Semantics(
            label: 'Sadhana progress: $completedCount of $totalTasks tasks completed. Streak: ${_service.currentStreak} days.',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [kGold.withOpacity(0.15), kSaffron.withOpacity(0.08)]
                      : [kGold.withOpacity(0.12), kSaffron.withOpacity(0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGold.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    '$completedCount / $totalTasks',
                    style: GoogleFonts.cinzel(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(kGold),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress >= 1.0
                        ? 'Sadhana complete! Hare Krishna.'
                        : 'Complete your daily spiritual practice.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Active timer banner
          if (_activeTaskId != null)
            Semantics(
              liveRegion: true,
              label: 'Timer running for ${_formatTime(_activeSeconds)}',
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSaffron.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kSaffron.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: kSaffron),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatTime(_activeSeconds),
                        style: GoogleFonts.cinzel(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kSaffron,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Stop timer and mark task as complete',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSaffron,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _stopTimer,
                        child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Task list
          ...today.tasks.map((task) => _buildTaskCard(task, isDark)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(SadhanaTask task, bool isDark) {
    final isActive = _activeTaskId == task.id;
    final isCompleted = task.isCompleted && !isActive;

    return Semantics(
      button: !isCompleted,
      label: '${task.title}. ${task.description}. '
          '${isCompleted ? "Completed" : isActive ? "Timer running" : "Not started"}. '
          '${task.targetMinutes > 0 ? "Target: ${task.targetMinutes} minutes" : ""}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? kCard : const Color(0xFFFFFAEA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? kSuccess.withOpacity(0.4)
                : isActive
                    ? kSaffron.withOpacity(0.4)
                    : kGold.withOpacity(0.15),
          ),
        ),
        child: InkWell(
          onTap: isCompleted || isActive
              ? null
              : () => _startTimer(task.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? kSuccess.withOpacity(0.15)
                        : isActive
                            ? kSaffron.withOpacity(0.15)
                            : kGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(task.iconName),
                    color: isCompleted ? kSuccess : isActive ? kSaffron : kGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isCompleted
                                  ? kSuccess
                                  : Theme.of(context).colorScheme.onSurface,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (isCompleted) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.check_circle, color: kSuccess, size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      if (task.completedMinutes > 0 && !isActive)
                        Text(
                          '${task.completedMinutes} min completed',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: kSuccess,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Semantics(
                    button: true,
                    label: 'Start ${task.title} timer',
                    child: IconButton(
                      icon: Icon(
                        isActive ? Icons.pause_circle : Icons.play_circle,
                        color: isActive ? kSaffron : kGold,
                        size: 32,
                      ),
                      onPressed: isActive ? null : () => _startTimer(task.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
