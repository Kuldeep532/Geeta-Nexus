import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/models.dart';
import '../state/app_state.dart';

class VerseDetailScreen extends StatefulWidget {
  final Verse verse;
  const VerseDetailScreen({super.key, required this.verse});

  @override
  State<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends State<VerseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _showTransliteration = true;
  
  // Audio & Speech objects
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _isListening = false;
  String _userSpokenText = "";

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _initSpeech();
    
    // Mark as read
    Future.microtask(() {
      if (mounted) {
        context.read<AppState>().markVerseRead(widget.verse.id);
      }
    });
  }

  void _initSpeech() async {
    await _stt.initialize();
    await _tts.setLanguage("hi-IN"); // Best for Sanskrit/Hindi pronunciation
    await _tts.setSpeechRate(0.4);   // Slow rate for better learning
  }

  @override
  void dispose() {
    _tabs.dispose();
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  // --- Logic Features ---

  Future<void> _speakVerse(String text) async {
    HapticFeedback.selectionClick();
    await _tts.speak(text);
  }

  void _startPractice() async {
    if (!_isListening) {
      bool available = await _stt.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _userSpokenText = "";
        });
        _stt.listen(
          localeId: "hi_IN",
          onResult: (val) => setState(() {
            _userSpokenText = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              _validateSpeech();
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _stt.stop();
    }
  }

  void _validateSpeech() {
    // Normalizing text for comparison
    String original = widget.verse.transliteration.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    String spoken = _userSpokenText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    if (spoken.isEmpty) return;

    if (original.contains(spoken) || spoken.contains(original)) {
      _showSnack("Sahi Uchcharan! ✨", Colors.green);
    } else {
      HapticFeedback.heavyImpact(); // Physical error feedback
      _showSnack("Galti hui! Phir se koshish karein.", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color goldColor = isDark ? const Color(0xFFFFD700) : const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Verse ${widget.verse.id}', 
          style: GoogleFonts.cinzel(color: goldColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: "Listen to Verse",
            icon: Icon(Icons.volume_up, color: goldColor),
            onPressed: () => _speakVerse(_showTransliteration ? widget.verse.transliteration : widget.verse.sanskrit),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyVerse(widget.verse),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeroCard(context, goldColor, isDark),
          _buildPracticeBar(goldColor),
          _buildTabSystem(goldColor),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(goldColor),
    );
  }

  Widget _buildHeroCard(BuildContext context, Color gold, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF2A1F00), const Color(0xFF1A1500)] : [Colors.white, const Color(0xFFFFF9E6)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BG ${widget.verse.chapter}.${widget.verse.verse}', 
                style: GoogleFonts.cinzel(color: gold, fontSize: 14)),
              _languageToggle(gold),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            label: "Verse Text",
            child: Text(
              _showTransliteration ? widget.verse.transliteration : widget.verse.sanskrit,
              textAlign: TextAlign.center,
              style: _showTransliteration 
                ? GoogleFonts.crimsonText(fontSize: 20, fontStyle: FontStyle.italic)
                : GoogleFonts.notoSansDevanagari(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageToggle(Color gold) {
    return InkWell(
      onTap: () => setState(() => _showTransliteration = !_showTransliteration),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(border: Border.all(color: gold), borderRadius: BorderRadius.circular(20)),
        child: Text(_showTransliteration ? "IAST" : "Sanskrit", style: TextStyle(color: gold, fontSize: 12)),
      ),
    );
  }

  Widget _buildPracticeBar(Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isListening ? "Listening..." : "Practice Pronunciation:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Semantics(
            label: "Mic for practice",
            child: IconButton(
              icon: Icon(_isListening ? Icons.stop_circle : Icons.mic, 
                color: _isListening ? Colors.red : gold, size: 30),
              onPressed: _startPractice,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSystem(Color gold) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: gold,
            indicatorColor: gold,
            tabs: const [Tab(text: "Translation"), Tab(text: "Meaning"), Tab(text: "Tags")],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _tabPadding(Text(widget.verse.translation, style: GoogleFonts.crimsonText(fontSize: 18))),
                _tabPadding(Text(widget.verse.meaning, style: const TextStyle(height: 1.5))),
                _tabPadding(Wrap(spacing: 8, children: widget.verse.keywords.map((k) => Chip(label: Text(k))).toList())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabPadding(Widget child) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: child);

  Widget _buildBottomNav(Color gold) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios), label: const Text("Prev")),
          const VerticalDivider(),
          TextButton.icon(onPressed: () {}, label: const Text("Next"), icon: const Icon(Icons.arrow_forward_ios)),
        ],
      ),
    );
  }

  void _copyVerse(Verse v) {
    Clipboard.setData(ClipboardData(text: "${v.sanskrit}\n${v.translation}"));
    _showSnack("Copied to clipboard", Colors.grey[800]!);
  }
}
