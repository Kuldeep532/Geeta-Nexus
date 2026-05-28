import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/models.dart';
import '../models/scripture_model.dart';
import '../theme.dart';

class QuizScreen extends StatefulWidget {
  final dynamic currentVerse;
  const QuizScreen({super.key, required this.currentVerse});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _finished = false;
  List<QuizQuestion> _dynamicQuestions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _generateQuestionsFromState());
  }

  void _generateQuestionsFromState() {
    if (!mounted) return;
    final v = widget.currentVerse;

    final translation = (v is ScriptureVerse) ? v.translations.values.first : v.translation;
    final meaning = (v is ScriptureVerse) ? v.commentaries.values.first : v.meaning;
    final chapter = (v is ScriptureVerse) ? v.section.sectionIndex : v.chapter;
    final verseNum = (v is ScriptureVerse) ? v.verseIndex : v.verse;

    List<QuizQuestion> tempQuestions = [
      QuizQuestion(
        question: "What is the primary translation of Shlok $chapter.$verseNum?",
        options: [translation, "A guide to ritualistic worship", "A historical war report", "A temporary worldly desire"],
        correctIndex: 0,
        explanation: "Correct! The translation is: $translation",
      ),
      QuizQuestion(
        question: "What is the core spiritual essence of this verse?",
        options: [meaning, "To renounce society entirely", "To seek only material success", "To perform actions without purpose"],
        correctIndex: 0,
        explanation: "Correct! The essence is: $meaning",
      ),
      QuizQuestion(
        question: "How should one apply the wisdom of this verse in life?",
        options: ["By performing duties with detachment", "By ignoring all responsibilities", "By seeking fame above duty", "By avoiding every action"],
        correctIndex: 0,
        explanation: "Correct! The teaching is: $meaning",
      ),
      QuizQuestion(
        question: "Which virtue is emphasized in Shlok $chapter.$verseNum?",
        options: ["Righteousness and duty", "Material accumulation", "Blind faith in rituals", "Avoiding conflict"],
        correctIndex: 0,
        explanation: "Correct! This verse emphasizes: $meaning",
      ),
      QuizQuestion(
        question: "What is the final advice provided in this verse?",
        options: ["To act with clarity and purpose", "To remain passive", "To focus solely on results", "To abandon all efforts"],
        correctIndex: 0,
        explanation: "Correct! It advises: $meaning",
      ),
    ];

    for (var q in tempQuestions) {
      q.options.shuffle();
    }

    setState(() => _dynamicQuestions = tempQuestions);
  }

  void _select(int index) {
    if (_answered) return;
    final isCorrect = index == _dynamicQuestions[_currentIndex].correctIndex;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) _score++;
    });
    isCorrect ? HapticFeedback.lightImpact() : HapticFeedback.vibrate();
  }

  void _next() {
    if (_currentIndex + 1 >= _dynamicQuestions.length) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Gita Quiz', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: BackButton(
            color: kGold,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, _finished);
            },
          ),
        ),
      ),
      body: _dynamicQuestions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : (_finished ? _buildResults(theme) : _buildQuestion(theme)),
    );
  }

  Widget _buildQuestion(ThemeData theme) {
    final current = _dynamicQuestions[_currentIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LinearProgressIndicator(value: (_currentIndex + 1) / 5, color: kGold, minHeight: 8),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
            child: Text(current.question, style: GoogleFonts.crimsonText(fontSize: 20)),
          ),
          const SizedBox(height: 24),
          ...List.generate(current.options.length, (i) => _buildOption(i, current, theme)),
          if (_answered) _buildFeedback(current, theme),
        ],
      ),
    );
  }

  Widget _buildOption(int index, QuizQuestion q, ThemeData theme) {
    bool isCorrect = index == q.correctIndex;
    bool isSelected = _selectedAnswer == index;
    Color border = _answered ? (isCorrect ? Colors.green : (isSelected ? Colors.red : theme.dividerColor)) : (isSelected ? kGold : theme.dividerColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _select(index);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 2)),
          child: Text(q.options[index], style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildFeedback(QuizQuestion q, ThemeData theme) {
    bool isCorrect = _selectedAnswer == q.correctIndex;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isCorrect ? "Correct! ✨" : "Incorrect!", style: TextStyle(color: isCorrect ? Colors.green : Colors.red, fontSize: 18)),
          const SizedBox(height: 10),
          Text(q.explanation, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _next();
            },
            child: const Text("NEXT QUESTION")
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Quiz Finished!', style: GoogleFonts.cinzel(fontSize: 28, color: kGold)),
          Text('Score: $_score/5'),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, true);
            },
            child: const Text('BACK TO VERSE')
          ),
        ],
      ),
    );
  }
}
