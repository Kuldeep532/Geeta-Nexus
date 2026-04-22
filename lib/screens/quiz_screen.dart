import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
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

  final List<QuizQuestion> _questions = [
    const QuizQuestion(
      question: "What does 'karmaṇy evādhikāras te' mean?",
      options: [
        "You have a right to the fruits of your actions",
        "You have a right to perform your prescribed duties",
        "You must renounce all actions",
        "Actions are determined by fate",
      ],
      correctIndex: 1,
      explanation: "Gita 2.47 teaches that we have the right to act, but not to the fruits. This is the essence of karma yoga.",
    ),
  ];

  QuizQuestion get current => _questions[_currentIndex];

  void _select(int index) {
    if (_answered) return;
    
    final isCorrect = index == current.correctIndex;
    
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) _score++;
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }

    Provider.of<AppState>(context, listen: false).recordQuizAnswer(isCorrect);
  }

  void _next() {
    if (_currentIndex + 1 >= _questions.length) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Gita Wisdom Quiz', style: GoogleFonts.cinzel()),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _finished ? _buildResults() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final progress = (_currentIndex + 1) / _questions.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar(progress),
          const SizedBox(height: 32),
          _buildQuestionCard(),
          const SizedBox(height: 24),
          ...List.generate(current.options.length, (i) => _buildOption(i)),
          if (_answered) _buildFeedbackArea(),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Semantics(
      label: "Progress indicator. Question ${_currentIndex + 1} of ${_questions.length}",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PROGRESS', style: TextStyle(color: kTextDim, fontSize: 11, letterSpacing: 1.2)),
              Text('SCORE: $_score', style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: kDivider,
            color: kGold,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() { // FIXED: Removed leading comma
    return Semantics(
      header: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kDivider),
        ),
        child: Text(
          current.question,
          style: GoogleFonts.crimsonText(color: kText, fontSize: 22, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildOption(int index) {
    final bool isCorrect = index == current.correctIndex;
    final bool isSelected = _selectedAnswer == index;
    
    Color borderColor = kDivider;
    if (_answered) {
      borderColor = isCorrect ? Colors.green : (isSelected ? Colors.red : kDivider);
    } else if (isSelected) {
      borderColor = kGold;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        enabled: !_answered,
        label: "Option ${['A', 'B', 'C', 'D'][index]}: ${current.options[index]}",
        child: InkWell(
          onTap: () => _select(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Text(['A', 'B', 'C', 'D'][index], 
                  style: TextStyle(color: borderColor, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(current.options[index], 
                    style: const TextStyle(color: kText, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackArea() {
    final bool correct = _selectedAnswer == current.correctIndex;
    return Semantics(
      liveRegion: true,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: correct ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: correct ? Colors.green : Colors.red),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(correct ? "Correct" : "Incorrect",
                    style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(current.explanation, style: const TextStyle(color: kText, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              child: Text(_currentIndex + 1 >= _questions.length ? 'FINISH' : 'NEXT QUESTION'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🕉️', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text('Quiz Complete', style: GoogleFonts.cinzel(fontSize: 28, color: kGold)),
          const SizedBox(height: 8),
          Text('Score: $_score / ${_questions.length}', style: const TextStyle(color: kText, fontSize: 18)),
          const SizedBox(height: 40),
          TextButton(
            onPressed: _restart, 
            child: const Text('RESTART QUIZ', style: TextStyle(color: kGold, letterSpacing: 1.2))
          ),
        ],
      ),
    );
  }
}
