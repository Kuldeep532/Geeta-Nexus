import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';
import '../models/models.dart'; 
import '../models/scripture_model.dart';
import 'scripture_verse_detail_screen.dart';

// ... (Other imports remain the same as per your original file)

import HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Verse? _dailyVerse; 
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyVerse();
    });
    _initTts();
  }

  void _loadDailyVerse() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.allVerses.isNotEmpty) {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      setState(() {
        _dailyVerse = state.allVerses[dayOfYear % state.allVerses.length];
      });
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Fixed Syntax Error
                children: [
                  _buildGreetingSection(state, isDark),
                  const SizedBox(height: 16),
                  _buildStreakBar(state, isDark, theme),
                  const SizedBox(height: 24),
                  if (_dailyVerse != null) 
                    _buildDailyVerseCard(context, _dailyVerse!, isDark, theme),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBar(AppState state, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1500) : const Color(0xFFFFF9E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)), // Ensure kGold is defined
      ),
      child: Row(
        children: [
          _buildStatItem('🔥', '${state.streak}', 'Days'),
          const SizedBox(width: 20),
          _buildStatItem('📖', '${state.readVerses.length}', 'Verses'),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Daily Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: LinearProgressIndicator(
                  value: (state.readVerses.length / 700).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard(BuildContext context, Verse verse, bool isDark, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScriptureVerseDetailScreen(
            allVerses: [ScriptureVerse.fromLocalVerse(verse)],
            initialIndex: 0,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2000) : const Color(0xFFFFF6DD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DAILY VERSE', style: TextStyle(letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 12),
            Text(verse.translation, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Text('Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon), 
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)), 
        Text(label, style: const TextStyle(fontSize: 10))
      ]
    );
  }
  
  // Keep your remaining methods (_buildAppBar, _buildGreetingSection, etc.) here.
}
