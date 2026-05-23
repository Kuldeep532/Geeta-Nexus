import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/gita_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart'; 

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  
  List<Verse> _verses = []; 
  bool _flipped = false;
  late AnimationController _controller;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _loadVersesFromDatabase();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _loadVersesFromDatabase() {
    // Flatten the verses from all chapters into a single list
    if (kChapters.isNotEmpty) {
      setState(() {
        _verses = kChapters.expand((chapter) => chapter.verses).toList();
      });
    }
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

    // Live accessibility announcement when card flips
    final sideAnnouncement = _flipped 
        ? "Showing Translation and Meaning" 
        : "Showing Sanskrit Verse";
    SemanticsService.announce(sideAnnouncement, TextDirection.ltr);
  }

  void _navigate(AppState state, bool forward) {
    HapticFeedback.lightImpact();
    
    // Reset card to front side before navigating to the next one
    if (_flipped) {
      _controller.reverse();
      setState(() => _flipped = false);
    }
    
    int newIndex = forward 
        ? (state.currentFlashcardIndex + 1) 
        : (state.currentFlashcardIndex - 1);

    if (newIndex >= 0 && newIndex < _verses.length) {
      state.updateFlashcardIndex(newIndex);
      if (forward) state.addXp(5);

      // Announce current card position update for screen readers
      SemanticsService.announce(
        "Card ${newIndex + 1} of ${_verses.length}", 
        TextDirection.ltr
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final goldColor = kGold; 
    
    if (_verses.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: goldColor,
            semanticsLabel: "Loading verses",
          ),
        ),
      );
    }

    // Clamp index to prevent out-of-bounds runtime errors
    final safeIndex = appState.currentFlashcardIndex.clamp(0, _verses.length - 1);
    final verse = _verses[safeIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'GITA FLASHCARDS', 
          style: GoogleFonts.cinzel(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Semantics(
                label: "Card position",
                value: "${safeIndex + 1} of ${_verses.length}",
                excludeSemantics: true,
                child: Text(
                  '${safeIndex + 1}/${_verses.length}', 
                  style: TextStyle(color: goldColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Semantics(
            label: "Progress bar",
            value: "${((safeIndex + 1) / _verses.length * 100).toStringAsFixed(0)} percent completed",
            child: LinearProgressIndicator(
              value: (safeIndex + 1) / _verses.length,
              backgroundColor: theme.dividerColor.withOpacity(0.1),
              color: goldColor,
              minHeight: 4,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Semantics(
                label: "Flashcard. Double tap to flip between Sanskrit verse and translation.",
                button: true,
                onTap: _handleFlip,
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
                            ? _buildCardSide(verse, true, theme, goldColor)
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _buildCardSide(verse, false, theme, goldColor),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          _buildControls(appState, goldColor, theme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardSide(Verse verse, bool isFront, ThemeData theme, Color goldColor) {
    final isDark = theme.brightness == Brightness.dark;
    
    // MergeSemantics groups text elements into a single readable block for assistive technologies
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isDark ? theme.cardColor : Colors.white,
          border: Border.all(color: goldColor.withOpacity(isFront ? 0.5 : 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: goldColor.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isFront ? "SANSKRIT VERSE" : "TRANSLATION AND MEANING", 
                  style: GoogleFonts.cinzel(color: goldColor, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Text(
                  isFront ? verse.sanskrit : verse.translation,
                  textAlign: TextAlign.center,
                  style: isFront 
                      ? GoogleFonts.notoSansDevanagari(fontSize: 22, height: 1.6)
                      : GoogleFonts.lora(fontSize: 18, height: 1.5, fontStyle: FontStyle.italic),
                ),
                if (!isFront) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                  Text(
                    verse.meaning, 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.hintColor, fontSize: 14, height: 1.4),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(AppState state, Color goldColor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _navBtn(
            Icons.arrow_back_ios_new, 
            () => _navigate(state, false), 
            state.currentFlashcardIndex > 0, 
            goldColor, 
            theme, 
            "Previous Card",
          ),
          const SizedBox(width: 15),
          _navBtn(
            Icons.arrow_forward_ios, 
            () => _navigate(state, true), 
            state.currentFlashcardIndex < _verses.length - 1, 
            goldColor, 
            theme, 
            "Next Card", 
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback? onTap, bool active, Color goldColor, ThemeData theme, String label, {bool isPrimary = false}) {
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        enabled: active,
        child: InkWell(
          onTap: active ? onTap : null,
          borderRadius: BorderRadius.circular(15),
          child: Opacity(
            opacity: active ? 1.0 : 0.2,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: isPrimary ? goldColor : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: goldColor, width: 2),
              ),
              child: Icon(
                icon, 
                color: isPrimary ? Colors.black : goldColor,
                semanticLabel: label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
