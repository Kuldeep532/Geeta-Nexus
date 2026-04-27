import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

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
    // Microtask ensures context is available for Provider
    Future.microtask(() => _generateQuestionsFromState());
  }

  void _generateQuestionsFromState() {
    final state = Provider.of<AppState>(context, listen: false);
    final allVerses = state.allVerses;

    if (allVerses.isEmpty) return;

    final random = Random();
    List<QuizQuestion> tempQuestions = [];

    // 5 random questions generate karne ka logic
    for (int i = 0; i < 5; i++) {
      final correctVerse = allVerses[random.nextInt(allVerses.length)];
      List<String> options = [correctVerse.translation];

      while (options.length < 4) {
        String randomOption = allVerses[random.nextInt(allVerses.length)].translation;
        if (!options.contains(randomOption)) options.add(randomOption);
      }

      options.shuffle();

      tempQuestions.add(QuizQuestion(
        question: "Verse ${correctVerse.chapter}.${correctVerse.verse} ka sahi anuvad (translation) kya hai?",
        options: options,
        correctIndex: options.indexOf(correctVerse.translation),
        explanation: "Sahi jawab! Is shlok ka taatparya hai: ${correctVerse.meaning}",
      ));
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
    Provider.of<AppState>(context, listen: false).recordQuizAnswer(isCorrect);
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
    final bool isDark = theme.brightness == Brightness.dark;
    final Color goldColor = isDark ? const Color(0xFFFFD700) : const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Gita Quiz', style: GoogleFonts.cinzel(color: goldColor, fontWeight: FontWeight.bold)),
      ),
      body: _dynamicQuestions.isEmpty 
          ? const Center(child: CircularProgressIndicator()) 
          : (_finished ? _buildResults(goldColor, theme) : _buildQuestion(goldColor, theme)),
    );
  }

  Widget _buildQuestion(Color gold, ThemeData theme) {
    final current = _dynamicQuestions[_currentIndex];
    final progress = (_currentIndex + 1) / _dynamicQuestions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Accessibility-Friendly Progress
          Semantics(
            label: "Sawal number ${_currentIndex + 1} kul ${_dynamicQuestions.length} mein se. Aapka score hai $_score",
            child: Column(
              children: [
                LinearProgressIndicator(value: progress, color: gold, backgroundColor: gold.withOpacity(0.1), minHeight: 8),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('QUESTION ${_currentIndex + 1}/5', style: TextStyle(color: theme.hintColor, fontSize: 12)),
                    Text('SCORE: $_score', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withOpacity(0.2)),
            ),
            child: Text(current.question, style: GoogleFonts.crimsonText(fontSize: 22, height: 1.4)),
          ),
          const SizedBox(height: 24),
          // Options
          ...List.generate(current.options.length, (i) => _buildOption(i, current, gold, theme)),
          if (_answered) _buildFeedback(current, gold, theme),
        ],
      ),
    );
  }

  Widget _buildOption(int index, QuizQuestion q, Color gold, ThemeData theme) {
    bool isCorrect = index == q.correctIndex;
    bool isSelected = _selectedAnswer == index;
    Color border = theme.dividerColor;
    
    if (_answered) {
      if (isCorrect) border = Colors.green;
      else if (isSelected) border = Colors.red;
    } else if (isSelected) {
      border = gold;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: "Option ${index + 1}: ${q.options[index]}",
        child: InkWell(
          onTap: () => _select(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: [
                Text("${index + 1}.", style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(child: Text(q.options[index], style: const TextStyle(fontSize: 16))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(QuizQuestion q, Color gold, ThemeData theme) {
    bool isCorrect = _selectedAnswer == q.correctIndex;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(isCorrect ? "Bilkul Sahi! ✨" : "Galat Jawab!", 
                style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red, fontSize: 18)),
            const SizedBox(height: 10),
            Text(q.explanation, textAlign: TextAlign.center, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              child: const Text("AGLA SAWAL"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResults(Color gold, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🙏', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text('Quiz Samapt!', style: GoogleFonts.cinzel(fontSize: 28, color: gold)),
          const SizedBox(height: 10),
          Text('Aapne 5 mein se $_score ank prapt kiye.', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _finished = false;
                _currentIndex = 0;
                _score = 0;
              });
              _generateQuestionsFromState();
            },
            icon: const Icon(Icons.refresh),
            label: Text('PHIR SE KHELIE', style: TextStyle(color: gold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}
