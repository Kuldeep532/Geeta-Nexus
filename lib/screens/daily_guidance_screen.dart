import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/gita_data.dart';
import '../models/models.dart';
import '../services/kokoro_tts_service.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Personalized Daily Guidance — Aira generates custom spiritual messages.
class DailyGuidanceScreen extends StatefulWidget {
  const DailyGuidanceScreen({super.key});

  @override
  State<DailyGuidanceScreen> createState() => _DailyGuidanceScreenState();
}

class _DailyGuidanceScreenState extends State<DailyGuidanceScreen> {
  final KokoroTTSService _tts = KokoroTTSService();
  String? _guidance;
  Verse? _verseOfDay;
  bool _isGenerating = false;
  String _selectedMood = 'peaceful';

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Peaceful', 'icon': Icons.wb_sunny, 'color': kGold},
    {'label': 'Confused', 'icon': Icons.help_outline, 'color': const Color(0xFF5B8DEF)},
    {'label': 'Stressed', 'icon': Icons.waves, 'color': const Color(0xFFE67E22)},
    {'label': 'Grateful', 'icon': Icons.favorite, 'color': kSuccess},
    {'label': 'Determined', 'icon': Icons.fitness_center, 'color': kSaffron},
  ];

  @override
  void initState() {
    super.initState();
    _tts.initialize();
    _generateGuidance();
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  void _generateGuidance() {
    setState(() => _isGenerating = true);

    // Seed-based deterministic selection using today's date
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);

    // Pick a verse
    if (kChapters.isNotEmpty) {
      final chapter = kChapters[random.nextInt(kChapters.length)];
      if (chapter.verses.isNotEmpty) {
        _verseOfDay = chapter.verses[random.nextInt(chapter.verses.length)];
      }
    }

    // Generate contextual guidance based on mood
    _guidance = _buildGuidanceForMood(_selectedMood, _verseOfDay);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isGenerating = false);
    });
  }

  String _buildGuidanceForMood(String mood, Verse? verse) {
    final verseText = verse?.translation ?? '';
    final verseRef = verse != null ? 'Bhagavad Gita ${verse.chapter}.${verse.verse}' : '';

    final Map<String, String> templates = {
      'peaceful': 'Namaste, seeker. Today is a day for stillness. The Gita teaches that peace is not found in the absence of activity, but in the presence of awareness.\n\n"$verseText"\n\n— $verseRef\n\nSit quietly for five minutes. Let the world continue around you while you rest in the witness within.',
      'confused': 'Beloved seeker, confusion is the beginning of clarity. Krishna reminds Arjuna that doubt is natural on the path.\n\n"$verseText"\n\n— $verseRef\n\nDo not rush to resolve your confusion. Sit with it. Ask the question sincerely, and the answer will arrive in its own time.',
      'stressed': 'Dear soul, stress is the sign of attachment to outcomes. The Gita offers a way through: perform your duty without craving results.\n\n"$verseText"\n\n— $verseRef\n\nTake three deep breaths. Let go of what you cannot control. Focus only on the next right action.',
      'grateful': 'Radiant being, gratitude is the highest form of worship. Your thankful heart is already aligned with the divine.\n\n"$verseText"\n\n— $verseRef\n\nWrite down three things you are grateful for today. Let this practice expand your heart.',
      'determined': 'Warrior of the spirit, your determination is a sacred fire. The Gita honors the disciplined soul who walks the path without wavering.\n\n"$verseText"\n\n— $verseRef\n\nSet one small intention today. Not a grand goal, but a single step. Consistency is greater than intensity.',
    };

    return templates[mood] ?? templates['peaceful']!;
  }

  void _speakGuidance() {
    if (_guidance == null) return;
    HapticFeedback.mediumImpact();
    _tts.speak(_guidance!);
    SemanticsService.announce(
      'Aira is speaking your daily guidance.',
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(
            'Daily Guidance',
            style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Refresh guidance for today',
            child: IconButton(
              icon: const Icon(Icons.refresh, color: kGold),
              tooltip: 'Refresh',
              onPressed: () {
                HapticFeedback.mediumImpact();
                _generateGuidance();
              },
            ),
          ),
        ],
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                explicitChildNodes: true,
                label: 'Personalized daily guidance from Aira',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting
                    Semantics(
                      label: 'Greeting for ${appState.userName.isNotEmpty ? appState.userName : "seeker"}',
                      child: Text(
                        'Namaste, ${appState.userName.isNotEmpty ? appState.userName : 'Seeker'}',
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kGold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today is ${_formatDate(DateTime.now())}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mood selector
                    Semantics(
                      label: 'Select your current mood for personalized guidance',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How do you feel today?',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _moods.map((mood) {
                              final isSelected = _selectedMood == mood['label'].toString().toLowerCase();
                              return Semantics(
                                button: true,
                                selected: isSelected,
                                label: '${mood['label']}. ${isSelected ? "Selected" : "Double-tap to select"}',
                                child: ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        mood['icon'] as IconData,
                                        size: 16,
                                        color: isSelected ? Colors.black : mood['color'] as Color,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(mood['label'] as String),
                                    ],
                                  ),
                                  selected: isSelected,
                                  selectedColor: mood['color'] as Color,
                                  backgroundColor: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.grey.withOpacity(0.08),
                                  onSelected: (selected) {
                                    if (selected) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _selectedMood = mood['label'].toString().toLowerCase();
                                      });
                                      _generateGuidance();
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Guidance card
                    Semantics(
                      label: 'Aira\'s guidance for today',
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [kGold.withOpacity(0.12), kSaffron.withOpacity(0.06)]
                                : [kGold.withOpacity(0.08), kSaffron.withOpacity(0.04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kGold.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: kGold, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Aira\'s Guidance',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: kGold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _guidance ?? 'Guidance is being prepared...',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                height: 1.7,
                                color: isDark ? Colors.white.withOpacity(0.87) : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Speak button
                    Semantics(
                      button: true,
                      label: 'Listen to Aira speak this guidance aloud',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _speakGuidance,
                        icon: const Icon(Icons.volume_up),
                        label: Text(
                          'Listen to Guidance',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Verse card
                    if (_verseOfDay != null)
                      Semantics(
                        label: 'Verse of the day from Bhagavad Gita',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? kCard : const Color(0xFFFFFAEA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kGold.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verse of the Day',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: kGold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _verseOfDay!.sanskrit,
                                style: GoogleFonts.crimsonText(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _verseOfDay!.translation,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '— BG ${_verseOfDay!.chapter}.${_verseOfDay!.verse}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kGold.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
