import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _flipped = false;
  late AnimationController _controller;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _verses = getAllVerses();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFlip() {
    if (_controller.isAnimating) return;

    HapticFeedback.mediumImpact();

    if (_flipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    setState(() => _flipped = !_flipped);

    SemanticsService.announce(
      _flipped ? "Showing Translation" : "Showing Sanskrit Verse",
      TextDirection.ltr,
    );
  }

  void _moveNext(AppState state) {
    if (state.currentFlashcardIndex < _verses.length - 1) {
      if (_flipped) {
        _controller.reverse();
        setState(() => _flipped = false);
      }
      state.updateFlashcardIndex(state.currentFlashcardIndex + 1);
      state.addXp(5);
    }
  }

  void _movePrev(AppState state) {
    if (state.currentFlashcardIndex > 0) {
      if (_flipped) {
        _controller.reverse();
        setState(() => _flipped = false);
      }
      state.updateFlashcardIndex(state.currentFlashcardIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentIndex = appState.currentFlashcardIndex;

    if (_verses.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No verses found")),
      );
    }

    final safeIndex =
        currentIndex.clamp(0, _verses.length - 1);
    final verse = _verses[safeIndex];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Gita Flashcards'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${safeIndex + 1}/${_verses.length}',
                style: GoogleFonts.inter(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildProgressHeader(safeIndex),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                onTap: _handleFlip,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (context, child) {
                    final angle = _flipAnim.value * math.pi;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: _flipAnim.value < 0.5
                          ? _buildCardSide(verse, isFront: true)
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateY(math.pi),
                              child:
                                  _buildCardSide(verse, isFront: false),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
          _buildBottomControls(appState),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LinearProgressIndicator(
        value: (index + 1) / _verses.length,
        backgroundColor: kDivider,
        color: kGold,
        minHeight: 8,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildCardSide(Verse verse,
      {required bool isFront}) {
    return Semantics(
      label: isFront ? "Verse Card" : "Translation Card",
      container: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isFront
                ? [
                    const Color(0xFF2D240B),
                    const Color(0xFF1A1404)
                  ]
                : [
                    const Color(0xFF0A192F),
                    const Color(0xFF020C1B)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isFront
                ? kGold.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.menu_book,
                  size: 100,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: isFront
                          ? _buildFrontContent(verse)
                          : _buildBackContent(verse),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFrontContent(Verse verse) {
    return [
      Text(
        "SHLOKA",
        style: GoogleFonts.inter(
          letterSpacing: 4,
          color: kGoldDim,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        verse.sanskrit,
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSansDevanagari(
          color: kGoldLight,
          fontSize: 22,
          height: 1.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 40),
      const Icon(Icons.touch_app,
          color: kTextDim, size: 20),
      const SizedBox(height: 8),
      const Text(
        "Tap to Flip",
        style:
            TextStyle(color: kTextDim, fontSize: 12),
      ),
    ];
  }

  List<Widget> _buildBackContent(Verse verse) {
    return [
      Text(
        "TRANSLATION",
        style: GoogleFonts.inter(
          letterSpacing: 4,
          color: Colors.blueAccent,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        verse.translation,
        textAlign: TextAlign.center,
        style: GoogleFonts.lora(
          color: Colors.white,
          fontSize: 18,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(color: Colors.white10),
      ),
      Text(
        verse.meaning,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: kTextDim,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    ];
  }

  Widget _buildBottomControls(AppState state) {
    final isFirst = state.currentFlashcardIndex == 0;
    final isLast =
        state.currentFlashcardIndex == _verses.length - 1;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _navButton(
            Icons.chevron_left,
            "Prev",
            isFirst ? null : () => _movePrev(state),
          ),
          const SizedBox(width: 16),
          _navButton(
            Icons.chevron_right,
            isLast ? "Finish" : "Next",
            isLast ? null : () => _moveNext(state),
            primary: true,
          ),
        ],
      ),
    );
  }

  Widget _navButton(
    IconData icon,
    String label,
    VoidCallback? onPressed, {
    bool primary = false,
  }) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon,
              color: primary ? Colors.black : kGold),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                primary ? kGold : Colors.transparent,
            foregroundColor:
                primary ? Colors.black : kGold,
            elevation: primary ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15),
              side: BorderSide(
                color: kGold,
                width: primary ? 0 : 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
