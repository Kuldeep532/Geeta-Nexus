import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/ai_service.dart';
import '../theme.dart';

class _Task {
  final String id;
  String title;
  String karmaReflection;
  bool isDone;

  _Task({
    required this.id,
    required this.title,
    this.karmaReflection = '',
    this.isDone = false,
  });
}

/// Feature 4: AI Karma-Yogi Daily Mindful Planner.
/// Users tell Aira their tasks; Aira reframes them through
/// Krishna's Karma Yoga (action without attachment).
class KarmaPlannerScreen extends StatefulWidget {
  const KarmaPlannerScreen({super.key});

  @override
  State<KarmaPlannerScreen> createState() => _KarmaPlannerScreenState();
}

class _KarmaPlannerScreenState extends State<KarmaPlannerScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FocusNode _taskFocus = FocusNode();
  final AIService _ai = AIService();
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();

  final List<_Task> _tasks = [];
  bool _isListening = false;
  bool _isGenerating = false;
  String _dailyBriefing = '';
  bool _briefingReady = false;

  static const _krishnaIntro =
      'Arjuna, your duties await. Let us approach each task as an offering to the Divine — act without attachment to result.';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(0.95);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    HapticFeedback.lightImpact();
    _taskController.clear();

    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    final task = _Task(id: taskId, title: title);

    setState(() {
      _tasks.add(task);
      _isGenerating = true;
    });

    SemanticsService.announce("Getting Karma Yoga insight for: $title",
        TextDirection.ltr);

    try {
      final prompt =
          '[Karma Yoga Planner] User has this task today: "$title". '
          'In 2 short sentences, guide them through Lord Krishna\'s teaching '
          'on Karma Yoga — how to perform this duty with a calm, unattached '
          'mind. Be warm, practical, and direct. Reference Bhagavad Gita.';

      final reflection = await _ai.getSmartResponse(prompt);
      if (!mounted) return;
      setState(() {
        task.karmaReflection = reflection;
        _isGenerating = false;
      });
      await _speak(reflection);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        task.karmaReflection =
            'Perform this duty as an offering. Act with full effort, detached from the outcome.';
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateDailyBriefing() async {
    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least one task to generate your briefing.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _briefingReady = false;
    });

    SemanticsService.announce("Generating daily Karma Yoga briefing",
        TextDirection.ltr);

    final taskList = _tasks.map((t) => '- ${t.title}').join('\n');
    final prompt =
        '[Daily Karma Yoga Briefing] Today\'s tasks:\n$taskList\n\n'
        'Compose a short (4-5 sentence) morning audio briefing in the voice '
        'of Lord Krishna from the Bhagavad Gita. Encourage the seeker to '
        'approach each task as an act of Karma Yoga — dedicated service '
        'without attachment. Be inspiring, calm, and deeply spiritual.';

    try {
      final briefing = await _ai.getSmartResponse(prompt);
      if (!mounted) return;
      setState(() {
        _dailyBriefing = briefing;
        _briefingReady = true;
        _isGenerating = false;
      });
      await _speak(briefing);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done') {
          setState(() => _isListening = false);
          if (_taskController.text.trim().isNotEmpty) _addTask();
        }
      },
      onError: (_) => setState(() => _isListening = false),
    );
    if (!available) return;
    setState(() => _isListening = true);
    SemanticsService.announce("Speak your task", TextDirection.ltr);
    _speech.listen(
      pauseFor: const Duration(seconds: 4),
      listenFor: const Duration(seconds: 30),
      partialResults: true,
      onResult: (r) =>
          setState(() => _taskController.text = r.recognizedWords),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _taskController.dispose();
    _taskFocus.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Semantics(
          header: true,
          child: Text(
            'Karma-Yogi Planner',
            style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold, color: kGold, fontSize: 18),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Generate daily briefing',
            hint: 'Double tap to hear your Karma Yoga daily briefing',
            child: IconButton(
              tooltip: 'Daily Briefing',
              icon: const Icon(Icons.play_circle_outline_rounded, color: kGold),
              onPressed: _generateDailyBriefing,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildKrishnaCard(isDark),
          _buildTaskInput(theme, isDark),
          if (_briefingReady && _dailyBriefing.isNotEmpty)
            _buildBriefingCard(isDark),
          Expanded(child: _buildTaskList(isDark)),
        ],
      ),
    );
  }

  Widget _buildKrishnaCard(bool isDark) {
    return Semantics(
      label: 'Krishna\'s daily guidance',
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [kGold.withOpacity(0.12), kSaffron.withOpacity(0.06)]
                : [kGold.withOpacity(0.18), kSaffron.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.2),
              ),
              child: const Icon(Icons.self_improvement_rounded,
                  color: kGold, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _krishnaIntro,
                style: GoogleFonts.lora(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? kGoldLight : kGoldDim,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInput(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: _isListening ? 'Stop recording' : 'Speak a task',
            hint: 'Double tap to add a task by voice',
            child: IconButton(
              tooltip: _isListening ? 'Stop' : 'Speak task',
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isListening ? Colors.red : kGold,
                size: 26,
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              textField: true,
              label: 'Enter today\'s task',
              child: TextField(
                controller: _taskController,
                focusNode: _taskFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addTask(),
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter a task (e.g. morning puja, work meeting)',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Add task',
            enabled: !_isGenerating,
            child: FloatingActionButton.small(
              tooltip: 'Add task',
              backgroundColor: kGold,
              heroTag: 'karma_add_fab',
              onPressed: _isGenerating ? null : _addTask,
              child: _isGenerating
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
    );
  }

  Widget _buildBriefingCard(bool isDark) {
    return Semantics(
      label: 'Daily Karma Yoga briefing',
      child: GestureDetector(
        onTap: () => _speak(_dailyBriefing),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.amber.shade900.withOpacity(0.2) : Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kSaffron.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.record_voice_over_rounded,
                  color: kSaffron, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Briefing',
                        style: GoogleFonts.cinzel(
                            fontSize: 12,
                            color: kSaffron,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      _dailyBriefing,
                      style: GoogleFonts.lora(
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          color: isDark ? kText : kGoldDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(bool isDark) {
    if (_tasks.isEmpty) {
      return Center(
        child: Semantics(
          label: 'No tasks yet. Add a task to begin your Karma Yoga practice.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checklist_rounded,
                  size: 56, color: kGold.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text(
                'Add your tasks above\nto receive Karma Yoga guidance',
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
      itemCount: _tasks.length,
      itemBuilder: (ctx, i) {
        final task = _tasks[i];
        return Semantics(
          label:
              '${task.isDone ? "Completed" : "Pending"} task: ${task.title}. ${task.karmaReflection}',
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: task.isDone
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
                    Semantics(
                      button: true,
                      label: task.isDone ? 'Mark as pending' : 'Mark as done',
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => task.isDone = !task.isDone);
                        },
                        child: Icon(
                          task.isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: task.isDone ? kSuccess : kGold,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone
                              ? (isDark ? Colors.grey : Colors.grey.shade500)
                              : null,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Hear Karma Yoga reflection for ${task.title}',
                      child: IconButton(
                        tooltip: 'Listen to reflection',
                        icon: const Icon(Icons.volume_up_rounded,
                            size: 18, color: kGold),
                        onPressed: () => _speak(task.karmaReflection.isNotEmpty
                            ? task.karmaReflection
                            : task.title),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Remove task ${task.title}',
                      child: IconButton(
                        tooltip: 'Remove task',
                        icon: Icon(Icons.close_rounded,
                            size: 18,
                            color: isDark ? Colors.grey : Colors.grey.shade400),
                        onPressed: () =>
                            setState(() => _tasks.removeAt(i)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                if (task.karmaReflection.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            size: 14, color: kGold),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task.karmaReflection,
                            style: GoogleFonts.lora(
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              color: isDark ? kTextDim : kGoldDim,
                            ),
                          ),
                        ),
                      ],
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
