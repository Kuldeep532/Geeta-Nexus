import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';

import 'search_screen.dart';
import 'random_verse_screen.dart';
import 'wisdom_cards_screen.dart';
import 'affirmations_screen.dart';
import 'reading_plan_screen.dart';
import 'verse_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late dynamic _dailyVerse;
  final FlutterTts _tts = FlutterTts();
  bool _isPlayingDharmaAudio = false;

  @override
  void initState() {
    super.initState();
    _dailyVerse = _loadAutomatedVerse();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingDharmaAudio = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isPlayingDharmaAudio = false);
    });
  }


  String _timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning · Jai Shri Krishna';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon · Jai Shri Krishna';
    }
    if (hour >= 17 && hour < 21) {
      return 'Good Evening · Jai Shri Krishna';
    }
    return 'Good Night · Hare Krishna';
  }



  String _timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning · Jai Shri Krishna';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon · Jai Shri Krishna';
    }
    if (hour >= 17 && hour < 21) {
      return 'Good Evening · Jai Shri Krishna';
    }
    return 'Good Night · Hare Krishna';
  }

  final List<Map<String, String>> _newFeatures = const [
    {'title': 'Adaptive Reading Mode', 'subtitle': 'Cleaner typography and calmer spacing for long study sessions'},
    {'title': 'Smart Verse Context', 'subtitle': 'Chapter-aware suggestions to continue reading with flow'},
    {'title': 'Distraction-Free View', 'subtitle': 'Focused layouts to keep attention on verses and meaning'},
    {'title': 'Accessible Navigation', 'subtitle': 'Improved labels and structure for screen readers'},
    {'title': 'Linked Account Profile', 'subtitle': 'View connected name and email in one place'},
    {'title': 'Live Version Awareness', 'subtitle': 'App version and update checks are now easier to track'},
    {'title': 'Notification Stream', 'subtitle': 'Admin broadcasts appear in the new notifications section'},
    {'title': 'Astrology Studio', 'subtitle': 'Generate kundli and life-horoscope insights locally'},
  ];

  dynamic _loadAutomatedVerse() {
    if (allVerses.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return allVerses[dayOfYear % allVerses.length];
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Time-based greeting: ${_timeBasedGreeting()}',
                    child: Text(
                      _timeBasedGreeting(),
                      style: GoogleFonts.crimsonText(
                        color: theme.brightness == Brightness.dark
                            ? kGoldLight
                            : kGoldDim,
                        color: kGoldLight,
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state.userName.isNotEmpty) ...[
                    Text(
                      'Namaste, ${state.userName}',
                      style: GoogleFonts.cinzel(
                        color: kGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildStreakBar(state),
                  const SizedBox(height: 24),
                  _buildDailyVerse(context, _dailyVerse),
                  const SizedBox(height: 16),
                  _buildDailyDharmaCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('New Features'),
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'New features list',
                    child: _buildNewFeatures(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Today's Wisdom"),
                  const SizedBox(height: 12),
                  _buildWisdomPreview(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'BHAGAVAD GITA',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF1A1500), kBg]
                  : const [Color(0xFFFFF1CE), Color(0xFFFFF8E7)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Search Verses',
          icon: const Icon(Icons.search, color: kGold),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBar(AppState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Semantics(
      label: "Progress Overview: Level ${state.level}, Streak ${state.streak} days",
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF2A1F00), Color(0xFF1A1500)]
                : const [Color(0xFFFFF6D9), Color(0xFFFFF1CE)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            _statChip('🔥', '${state.streak}', 'Days'),
            _statChip('📖', '${state.readVerses.length}', 'Verses'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Level ${state.level}',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (state.xp / 100).clamp(0.0, 1.0),
                      backgroundColor: kDivider,
                      color: kGold,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${state.xp} XP', 
                      style: const TextStyle(color: kTextDim, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: kGold, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: kTextDim, fontSize: 9)),
      ],
    );
  }

  Widget _buildDailyVerse(BuildContext context, dynamic verse) {
    if (verse == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: verse)),
      ),
      child: Semantics(
        button: true,
        label: "Daily Verse from Chapter ${verse.chapter}. Tap to read details.",
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF2A2000), Color(0xFF1A1500)]
                  : const [Color(0xFFFFF6DD), Color(0xFFFFF1CF)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('✨ DAILY VERSE',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Ch. ${verse.chapter}',
                      style: const TextStyle(color: kGoldDim, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                verse.sanskrit ?? '',
                style: GoogleFonts.notoSansDevanagari(
                  color: isDark ? kGoldLight : kGoldDim,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"${verse.translation ?? ''}"',
                style: GoogleFonts.crimsonText(
                  color: isDark ? kText : const Color(0xFF2A1F00),
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleDharmaAudio() async {
    if (_dailyVerse == null) return;
    if (_isPlayingDharmaAudio) {
      await _tts.stop();
      if (mounted) setState(() => _isPlayingDharmaAudio = false);
      return;
    }

    final text =
        'Daily Dharma verse. ${_dailyVerse.translation ?? ''}';
    setState(() => _isPlayingDharmaAudio = true);
    await _tts.speak(text);
  }

  Widget _buildDailyDharmaCard() {
    if (_dailyVerse == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY DHARMA AUDIO',
            style: GoogleFonts.cinzel(
              color: kGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (_dailyVerse.sanskrit ?? '').toString(),
            style: GoogleFonts.notoSansDevanagari(
              color: theme.brightness == Brightness.dark
                  ? kGoldLight
                  : kGoldDim,
              fontSize: 16,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            (_dailyVerse.translation ?? '').toString(),
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? kTextDim
                  : const Color(0xFF7A6A3A),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _toggleDharmaAudio,
              icon: Icon(_isPlayingDharmaAudio ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlayingDharmaAudio ? 'Stop Audio' : 'Play Daily Sloka'),
            ),
          ),
        ],
      ),
  Widget _buildNewFeatures() {
    return Column(
      children: _newFeatures
          .map(
            (feature) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kDivider.withOpacity(0.45)),
              ),
              child: Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(Icons.auto_awesome, color: kGold, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] ?? '',
                          style: GoogleFonts.cinzel(
                            color: kGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          feature['subtitle'] ?? '',
                          style: const TextStyle(
                            color: kTextDim,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.cinzel( // FIXED: Removed leading comma
        color: theme.colorScheme.primary,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.shuffle, 'label': 'Random', 'color': const Color(0xFF3E2723), 'screen': const RandomVerseScreen()},
      {'icon': Icons.style, 'label': 'Cards', 'color': const Color(0xFF1A237E), 'screen': const WisdomCardsScreen()},
      {'icon': Icons.format_quote, 'label': 'Quotes', 'color': const Color(0xFF311B92), 'screen': const AffirmationsScreen()},
      {'icon': Icons.map, 'label': 'Plan', 'color': const Color(0xFF1B5E20), 'screen': const ReadingPlanScreen()},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget)),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: action['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(action['icon'] as IconData, color: kGold, size: 22),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWisdomPreview() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: kDivider,
            child: Icon(Icons.lightbulb_outline, color: kGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deepen your practice",
                  style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Meditation is the journey of the self, through the self, to the self.",
                  style: TextStyle(color: kTextDim, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
