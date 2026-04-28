import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart'; // ERROR FIX: Theme import added

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
  
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _isListening = false;
  String _userSpokenText = "";

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _initSpeech();
    
    Future.microtask(() {
      if (mounted) {
        context.read<AppState>().markVerseRead(widget.verse.id);
      }
    });
  }

  void _initSpeech() async {
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.4);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  // --- Core Features ---

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
    String original = widget.verse.transliteration.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    String spoken = _userSpokenText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    if (spoken.isEmpty) return;

    if (original.contains(spoken) || spoken.contains(original)) {
      _showSnack("Sahi Uchcharan! ✨", Colors.green);
    } else {
      HapticFeedback.heavyImpact(); 
      _showSnack("Phir se koshish karein.", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: kGold),
        title: Text('Verse ${widget.verse.chapter}.${widget.verse.verse}', 
          style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: kGold),
            onPressed: () => _speakVerse(_showTransliteration ? widget.verse.transliteration : widget.verse.sanskrit),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: kGold),
            onPressed: () => _copyVerse(widget.verse),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeroCard(context),
          _buildPracticeBar(),
          _buildTabSystem(theme),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF2A1F00), const Color(0xFF1A1500)] 
              : [Colors.white, const Color(0xFFFFF9E6)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SHLOKA', style: GoogleFonts.cinzel(color: kGold, fontSize: 12, fontWeight: FontWeight.bold)),
              _languageToggle(),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _showTransliteration ? widget.verse.transliteration : widget.verse.sanskrit,
            textAlign: TextAlign.center,
            style: _showTransliteration 
              ? GoogleFonts.crimsonText(fontSize: 20, fontStyle: FontStyle.italic)
              : GoogleFonts.notoSansDevanagari(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _languageToggle() {
    return InkWell(
      onTap: () => setState(() => _showTransliteration = !_showTransliteration),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: kGold.withOpacity(0.1),
          border: Border.all(color: kGold), 
          borderRadius: BorderRadius.circular(20)
        ),
        child: Text(_showTransliteration ? "IAST" : "Sanskrit", 
          style: const TextStyle(color: kGold, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPracticeBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isListening ? "Listening... Pronounce now" : "Practice Pronunciation",
              style: TextStyle(color: _isListening ? Colors.red : kGold, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.stop_circle : Icons.mic, 
              color: _isListening ? Colors.red : kGold),
            onPressed: _startPractice,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSystem(ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: kGold,
            unselectedLabelColor: theme.hintColor,
            indicatorColor: kGold,
            tabs: const [Tab(text: "Translation"), Tab(text: "Meaning"), Tab(text: "Tags")],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _tabPadding(Text(widget.verse.translation, 
                  style: GoogleFonts.crimsonText(fontSize: 19, height: 1.4))),
                _tabPadding(Text(widget.verse.meaning, 
                  style: const TextStyle(height: 1.6, fontSize: 16))),
                _tabPadding(Wrap(
                  spacing: 8, 
                  runSpacing: 8,
                  children: widget.verse.keywords.map((k) => Chip(
                    backgroundColor: kGold.withOpacity(0.1),
                    side: BorderSide(color: kGold.withOpacity(0.2)),
                    label: Text(k, style: const TextStyle(color: kGold, fontSize: 12)),
                  )).toList(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabPadding(Widget child) => SingleChildScrollView(
    padding: const EdgeInsets.all(24), 
    child: child
  );

  void _copyVerse(Verse v) {
    Clipboard.setData(ClipboardData(text: "${v.sanskrit}\n\n${v.translation}"));
    _showSnack("Copied to clipboard", kGold);
  }
}
