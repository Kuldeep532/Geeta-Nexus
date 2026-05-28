import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ai_service.dart';
import '../services/kokoro_tts_service.dart';
import '../theme.dart';

class _Habit {
  String id;
  String goal;
  int targetCount;
  int currentCount;
  String airaEncouragement;
  DateTime createdAt;

  _Habit({
    required this.id,
    required this.goal,
    required this.targetCount,
    this.currentCount = 0,
    this.airaEncouragement = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress =>
      targetCount == 0 ? 0 : (currentCount / targetCount).clamp(0.0, 1.0);
  bool get isComplete => currentCount >= targetCount;
}

/// Feature 5: Daily Spiritual Resolution & Habit Tracker.
/// Users set goals (e.g. "Read 2 Shlokas today") and Aira
/// gently tracks and encourages via audio.
class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _countController =
      TextEditingController(text: '1');
  final FocusNode _goalFocus = FocusNode();
  final AIService _ai = AIService();
  final KokoroTTSService _tts = KokoroTTSService();

  final List<_Habit> _habits = [];
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _tts.initialize();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    // Habits persist via SharedPreferences as simple serialized strings.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('habit_goals') ?? [];
    final targets = prefs.getStringList('habit_targets') ?? [];
    final counts = prefs.getStringList('habit_counts') ?? [];
    final encouragements =
        prefs.getStringList('habit_encouragements') ?? [];

    if (raw.isEmpty) return;

    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final savedDay = prefs.getString('habit_day') ?? '';

    setState(() {
      for (int i = 0; i < raw.length; i++) {
        _habits.add(_Habit(
          id: 'h$i',
          goal: raw[i],
          targetCount: int.tryParse(targets.elementAtOrNull(i) ?? '1') ?? 1,
          currentCount: savedDay == todayKey
              ? int.tryParse(counts.elementAtOrNull(i) ?? '0') ?? 0
              : 0,
          airaEncouragement: encouragements.elementAtOrNull(i) ?? '',
        ));
      }
    });
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(
        'habit_day', '${now.year}-${now.month}-${now.day}');
    await prefs.setStringList(
        'habit_goals', _habits.map((h) => h.goal).toList());
    await prefs.setStringList(
        'habit_targets', _habits.map((h) => h.targetCount.toString()).toList());
    await prefs.setStringList(
        'habit_counts',
        _habits.map((h) => h.currentCount.toString()).toList());
    await prefs.setStringList('habit_encouragements',
        _habits.map((h) => h.airaEncouragement).toList());
  }

  Future<void> _addHabit() async {
    final goal = _goalController.text.trim();
    final target = int.tryParse(_countController.text.trim()) ?? 1;
    if (goal.isEmpty) return;

    HapticFeedback.lightImpact();
    _goalController.clear();
    _countController.text = '1';

    final habit = _Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goal: goal,
        targetCount: target);

    setState(() {
      _habits.add(habit);
      _isAdding = true;
    });

    

    try {
      final prompt =
          '[Spiritual Habit Tracker] The seeker has set this daily goal: "$goal" '
          '(target: $target times). Write one warm, encouraging sentence '
          'in the spirit of Bhagavad Gita — acknowledging their commitment '
          'and inspiring steady action. Keep it under 30 words.';
      final enc = await _ai.getSmartResponse(prompt);
      if (!mounted) return;
      setState(() {
        habit.airaEncouragement = enc;
        _isAdding = false;
      });
      await _tts.speak(enc);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        habit.airaEncouragement =
            'Steady practice is the path to liberation. Begin now, dear seeker.';
        _isAdding = false;
      });
    }

    await _saveHabits();
  }

  Future<void> _increment(_Habit habit) async {
    if (habit.isComplete) return;
    HapticFeedback.selectionClick();
    setState(() => habit.currentCount++);
    await _saveHabits();

    if (habit.isComplete) {
      await _tts.speak(
          'Excellent! You have completed: ${habit.goal}. Well done, seeker!');
    } else {
      final remaining = habit.targetCount - habit.currentCount;
      await _tts.speak(
          '$remaining more to go for ${habit.goal}. Keep going!');
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _countController.dispose();
    _goalFocus.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completed = _habits.where((h) => h.isComplete).length;
    final total = _habits.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_rounded, color: kGold),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        title: Semantics(
          header: true,
          child: Text(
            'Spiritual Habit Tracker',
            style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold, color: kGold, fontSize: 17),
          ),
        ),
      ),
      body: Column(
        children: [
          if (total > 0) _buildDayProgress(completed, total, isDark),
          _buildAddHabitForm(theme, isDark),
          Expanded(child: _buildHabitList(isDark)),
        ],
      ),
    );
  }

  Widget _buildDayProgress(int completed, int total, bool isDark) {
    final pct = total == 0 ? 0.0 : completed / total;
    return Semantics(
      label: 'Today\'s progress: $completed of $total habits completed',
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [kGold.withOpacity(0.10), kSaffron.withOpacity(0.05)]
                : [kGold.withOpacity(0.15), kSaffron.withOpacity(0.07)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Progress",
                  style: GoogleFonts.cinzel(
                      fontSize: 13,
                      color: kGold,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '$completed / $total',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: pct == 1.0 ? kSuccess : kGold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor:
                    isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                    pct == 1.0 ? kSuccess : kGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddHabitForm(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set a Spiritual Goal',
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? kTextDim : Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Semantics(
                button: true,
                child: IconButton(
                  tooltip: 'Add goal',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _addHabit();
                  },
                  icon: const Icon(Icons.add_rounded, color: kGold, size: 26),
                ),
              ),
              Expanded(
                flex: 3,
                child: Semantics(
                  textField: true,
                  label: 'Enter spiritual goal',
                  child: TextField(
                    controller: _goalController,
                    focusNode: _goalFocus,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Read 2 Shlokas, meditate 10 minutes',
                      filled: true,
                      fillColor: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: Semantics(
                  textField: true,
                  label: 'Target count',
                  child: TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '#',
                      filled: true,
                      fillColor: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Add goal',
                enabled: !_isAdding,
                child: FloatingActionButton.small(
                  tooltip: 'Add goal',
                  backgroundColor: kGold,
                  heroTag: 'habit_add_fab',
                  onPressed: _isAdding ? null : () {
                    HapticFeedback.lightImpact();
                    _addHabit();
                  },
                  child: _isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.add_rounded, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList(bool isDark) {
    if (_habits.isEmpty) {
      return Center(
        child: Semantics(
          label: 'No habits yet. Add a spiritual goal above to begin tracking.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.track_changes_rounded,
                  size: 56, color: kGold.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text(
                'Tell Aira your spiritual goals\nto begin tracking your progress',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? kTextDim : Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _habits.length,
      itemBuilder: (ctx, i) {
        final h = _habits[i];
        return Semantics(
          label:
              '${h.isComplete ? "Complete" : "In progress"}: ${h.goal}. '
              '${h.currentCount} of ${h.targetCount} done.',
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: h.isComplete
                      ? kSuccess.withOpacity(0.4)
                      : kGold.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    color: Colors.black.withOpacity(0.04))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      h.isComplete
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: h.isComplete ? kSuccess : kGold,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        h.goal,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: h.isComplete
                              ? TextDecoration.lineThrough
                              : null,
                          color: h.isComplete
                              ? (isDark ? Colors.grey : Colors.grey.shade500)
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      '${h.currentCount}/${h.targetCount}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: h.isComplete ? kSuccess : kGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Log one completion for ${h.goal}',
                      hint: 'Double tap to mark one count done',
                      child: IconButton(
                        tooltip: 'Log completion',
                        icon: const Icon(Icons.add_circle_outline_rounded,
                            color: kGold, size: 22),
                        onPressed: h.isComplete ? null : () {
                          HapticFeedback.lightImpact();
                          _increment(h);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Semantics(
                      button: true,
                      label: 'Remove habit ${h.goal}',
                      child: IconButton(
                        tooltip: 'Remove',
                        icon: Icon(Icons.close_rounded,
                            size: 18,
                            color: isDark ? Colors.grey : Colors.grey.shade400),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          setState(() => _habits.removeAt(i));
                          await _saveHabits();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: h.progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white12
                        : Colors.black.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        h.isComplete ? kSuccess : kGold),
                  ),
                ),
                if (h.airaEncouragement.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _tts.speak(h.airaEncouragement);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 13, color: kGold),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              h.airaEncouragement,
                              style: GoogleFonts.lora(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                                color: isDark ? kTextDim : kGoldDim,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
