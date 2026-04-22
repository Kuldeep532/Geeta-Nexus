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
    // kChapters check karne ke baad use properly flat list mein convert karna
    if (kChapters != null && kChapters.isNotEmpty) {
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
    HapticFeedback.lightImpact();

    if (_flipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  void _navigate(AppState state, bool forward) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    // Safety check: Agar data list khali hai
    if (_verses.isEmpty) {
      return Scaffold(
        backgroundColor: kBg,
        body: const Center(child: CircularProgressIndicator(color: kGold)),
      );
    }

    final safeIndex = appState.currentFlashcardIndex.clamp(0, _verses.length - 1);
    final verse = _verses[safeIndex];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('GITA FLASHCARDS', style: GoogleFonts.cinzel(color: kGold, fontSize: 16)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${safeIndex + 1}/${_verses.length}', 
                style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _verses.isNotEmpty ? (safeIndex + 1) / _verses.length : 0,
            backgroundColor: kDivider,
            color: kGold,
            minHeight: 4,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: GestureDetector(
                onTap: _handleFlip,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (context, child) {
                    final angle = _flipAnim.value * math.pi;
                    return Transform(
                      alignment: Alignment.center, // FIXED: Removed leading comma
                      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                      child: _flipAnim.value < 0.5
                          ? _buildCardSide(verse, true)
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildCardSide(verse, false),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
          _buildControls(appState),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardSide(Verse verse, bool isFront) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFront 
              ? [const Color(0xFF2A1F00), const Color(0xFF1A1500)]
              : [const Color(0xFF001A30), const Color(0xFF000510)],
        ),
        border: Border.all(color: kGoldDim.withOpacity(0.3)),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isFront ? "SANSKRIT" : "TRANSLATION", 
                style: GoogleFonts.cinzel(color: kGoldDim, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 20),
              Text(
                isFront ? verse.sanskrit : verse.translation,
                textAlign: TextAlign.center,
                style: isFront 
                    ? GoogleFonts.notoSansDevanagari(color: kGoldLight, fontSize: 20, height: 1.6)
                    : GoogleFonts.crimsonText(color: kText, fontSize: 18, height: 1.5, fontStyle: FontStyle.italic),
              ),
              if (!isFront) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white10)),
                Text(verse.meaning, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kTextDim, fontSize: 13, height: 1.4)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _navBtn(Icons.arrow_back_ios, () => _navigate(state, false), state.currentFlashcardIndex > 0),
          const SizedBox(width: 15),
          _navBtn(Icons.arrow_forward_ios, () => _navigate(state, true), state.currentFlashcardIndex < _verses.length - 1, isPrimary: true),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback? onTap, bool active, {bool isPrimary = false}) {
    return Expanded(
      child: InkWell(
        onTap: active ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: Opacity(
          opacity: active ? 1.0 : 0.3,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isPrimary ? kGold : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: kGold),
            ),
            child: Icon(icon, color: isPrimary ? Colors.black : kGold),
          ),
        ),
      ),
    );
  } // FIXED: Removed extra comma and cleaned up bracket
}
