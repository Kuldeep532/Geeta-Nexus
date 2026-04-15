import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/gita_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late List<Verse> _verses;
  int _index = 0;
  bool _flipped = false;
  late AnimationController _controller;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _verses = getAllVerses()..shuffle();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  void _next() {
    context.read<AppState>().markVerseRead(_verses[_index].id);
    context.read<AppState>().addXp(5);
    _controller.reset();
    setState(() {
      _index = (_index + 1) % _verses.length;
      _flipped = false;
    });
  }

  void _prev() {
    _controller.reset();
    setState(() {
      _index = (_index - 1 + _verses.length) % _verses.length;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final verse = _verses[_index];
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Flashcards'),
        leading: const BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_index + 1}/${_verses.length}',
                  style: const TextStyle(color: kTextDim, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Tap to flip the card',
              style: const TextStyle(color: kTextDim, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (_, __) {
                    final angle = _flipAnim.value * 3.14159;
                    final showFront = _flipAnim.value < 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: showFront
                          ? _buildFront(verse)
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _buildBack(verse),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _prev,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Prev'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGold,
                    side: const BorderSide(color: kGold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next +5 XP'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_index + 1) / _verses.length,
              backgroundColor: kDivider,
              color: kGold,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront(Verse verse) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGoldDim.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Verse ${verse.id}',
              style: GoogleFonts.cinzel(color: kGoldDim, fontSize: 14)),
          const SizedBox(height: 20),
          Text(
            verse.sanskrit.split('\n').take(2).join('\n'),
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansDevanagari(
                color: kGoldLight, fontSize: 16, height: 1.8),
          ),
          const Spacer(),
          Text('Tap to reveal translation',
              style: const TextStyle(color: kTextDim, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBack(Verse verse) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF001A30), Color(0xFF001020)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1A4060), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Translation',
              style: GoogleFonts.cinzel(
                  color: const Color(0xFF4AA8FF), fontSize: 14)),
          const SizedBox(height: 20),
          Text(
            '"${verse.translation}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.7),
          ),
          const SizedBox(height: 16),
          const Divider(color: kDivider),
          const SizedBox(height: 10),
          Text(
            verse.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextDim, fontSize: 13, height: 1.5),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
