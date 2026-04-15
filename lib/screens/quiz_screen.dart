import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';

const List<QuizQuestion> _questions = [
  QuizQuestion(
    question: "What does 'karmaṇy evādhikāras te' mean?",
    options: [
      "You have a right to the fruits of your actions",
      "You have a right to perform your prescribed duties",
      "You must renounce all actions",
      "Actions are determined by fate",
    ],
    correctIndex: 1,
    explanation: "Gita 2.47 teaches that we have the right to act, but not to the fruits. This is the essence of karma yoga — act without attachment to results.",
  ),
  QuizQuestion(
    question: "According to the Gita, what is the nature of the soul (Atman)?",
    options: [
      "It is born and dies with the body",
      "It is eternal, unborn, and cannot be destroyed",
      "It reincarnates until it reaches perfection",
      "It merges with nature after death",
    ],
    correctIndex: 1,
    explanation: "Gita 2.20 declares: 'The soul is never born nor dies at any time. It is unborn, eternal, ever-existing, and primeval.'",
  ),
  QuizQuestion(
    question: "What is the main teaching of Bhakti Yoga?",
    options: [
      "Performing actions without results",
      "Acquiring spiritual knowledge",
      "Pure devotion and love for the Divine",
      "Controlling the senses through asceticism",
    ],
    correctIndex: 2,
    explanation: "Bhakti Yoga (Chapter 12) teaches that pure devotion and unconditional love for God is the highest and most accessible path to liberation.",
  ),
  QuizQuestion(
    question: "In Gita 6.5, Krishna says the mind is:",
    options: [
      "Always your enemy",
      "Always your friend",
      "Both a friend and an enemy",
      "Neither friend nor enemy",
    ],
    correctIndex: 2,
    explanation: "The mind can be your greatest friend when disciplined, or your worst enemy when uncontrolled. Yoga is the art of befriending your own mind.",
  ),
  QuizQuestion(
    question: "What does Krishna promise in Gita 18.66?",
    options: [
      "Victory in battle to the righteous",
      "Material prosperity to devotees",
      "Complete liberation to those who surrender",
      "Reincarnation in a higher body",
    ],
    correctIndex: 2,
    explanation: "In the climax of the Gita, Krishna promises: 'Surrender unto Me alone; I shall deliver you from all sinful reactions. Do not fear.'",
  ),
  QuizQuestion(
    question: "The three Gunas (modes of nature) are:",
    options: [
      "Brahma, Vishnu, Shiva",
      "Sattva, Rajas, Tamas",
      "Karma, Dharma, Moksha",
      "Body, Mind, Soul",
    ],
    correctIndex: 1,
    explanation: "Chapter 14 explains the three gunas: Sattva (goodness/clarity), Rajas (passion/activity), and Tamas (ignorance/inertia). All of nature operates through these three modes.",
  ),
  QuizQuestion(
    question: "When does Krishna say he descends to Earth? (Gita 4.7-8)",
    options: [
      "Every thousand years regardless of conditions",
      "Only when devotees pray for help",
      "Whenever dharma declines and adharma rises",
      "At the end of each cosmic cycle",
    ],
    correctIndex: 2,
    explanation: "Krishna declares: 'Whenever there is a decline in dharma and a rise of adharma, I manifest Myself.' This is the principle of divine incarnation (Avatar).",
  ),
  QuizQuestion(
    question: "What does 'yoga' literally mean in the Gita?",
    options: [
      "Physical exercise and postures",
      "Union, discipline, and equanimity",
      "Renunciation of worldly life",
      "Devotional worship and prayer",
    ],
    correctIndex: 1,
    explanation: "Yoga means union with the Divine, and also refers to any disciplined path to liberation. Gita 2.48 defines it as: 'Perform your duty equipoised — such equanimity is called yoga.'",
  ),
];

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

  QuizQuestion get current => _questions[_currentIndex];

  void _select(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });
    final correct = index == current.correctIndex;
    context.read<AppState>().recordQuizAnswer(correct);
    if (correct) _score++;
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
        title: const Text('Gita Quiz'),
        leading: const BackButton(),
      ),
      body: _finished ? _buildResults() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final progress = (_currentIndex + 1) / _questions.length;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: const TextStyle(color: kTextDim, fontSize: 13),
              ),
              const Spacer(),
              Text('Score: $_score',
                  style: GoogleFonts.cinzel(
                      color: kGold, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: kDivider,
            color: kGold,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDivider),
            ),
            child: Text(
              current.question,
              style: GoogleFonts.crimsonText(
                  color: kText, fontSize: 18, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(current.options.length, (i) => _buildOption(i)),
          if (_answered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedAnswer == current.correctIndex
                    ? const Color(0xFF003300)
                    : const Color(0xFF330000),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedAnswer == current.correctIndex
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedAnswer == current.correctIndex
                        ? '✅ Correct! +20 XP'
                        : '❌ Incorrect — +2 XP for trying',
                    style: const TextStyle(
                        color: kGold, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(current.explanation,
                      style: const TextStyle(color: kText, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_currentIndex + 1 >= _questions.length
                    ? 'See Results'
                    : 'Next Question →'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(int index) {
    Color borderColor = kDivider;
    Color bgColor = kCard;
    if (_answered) {
      if (index == current.correctIndex) {
        borderColor = Colors.green;
        bgColor = const Color(0xFF002200);
      } else if (index == _selectedAnswer) {
        borderColor = Colors.red;
        bgColor = const Color(0xFF220000);
      }
    } else if (_selectedAnswer == index) {
      borderColor = kGold;
    }

    return GestureDetector(
      onTap: () => _select(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kDivider,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  ['A', 'B', 'C', 'D'][index],
                  style: TextStyle(
                      color: borderColor == kDivider ? kTextDim : borderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(current.options[index],
                  style: const TextStyle(color: kText, fontSize: 14, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final pct = (_score / _questions.length * 100).round();
    String emoji = pct >= 80 ? '🏆' : pct >= 60 ? '⭐' : '🌱';
    String msg = pct >= 80
        ? 'Excellent! You know the Gita well!'
        : pct >= 60
            ? 'Good effort! Keep studying the teachings.'
            : 'Keep learning — each question plants a seed!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('Quiz Complete!',
                style: GoogleFonts.cinzel(
                    color: kGold, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('$_score / ${_questions.length} correct ($pct%)',
                style: GoogleFonts.cinzel(color: kText, fontSize: 18)),
            const SizedBox(height: 12),
            Text(msg,
                style:
                    const TextStyle(color: kTextDim, fontSize: 15, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
