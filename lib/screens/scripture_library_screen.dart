import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/scripture_model.dart';
import '../services/scripture_repository.dart';
import '../services/scripture_service.dart';
import '../theme.dart';
import 'scripture_chapter_reader_screen.dart';
import 'scripture_dharmicdata_verse_list_screen.dart';
import 'scripture_upanishads_screen.dart';

class ScriptureLibraryScreen extends StatefulWidget {
  const ScriptureLibraryScreen({super.key});

  @override
  State<ScriptureLibraryScreen> createState() => _ScriptureLibraryScreenState();
}

class _ScriptureLibraryScreenState extends State<ScriptureLibraryScreen>
    with SingleTickerProviderStateMixin {
  final ScriptureService _service = ScriptureService();
  late TabController _tabController;

  List<ScriptureChapterData> _chapters = [];
  List<UpanishadVerseData> _upanishads = [];
  bool _chaptersLoading = true;
  bool _upanishadLoading = true;
  String? _chaptersError;
  String? _upanishadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadChapters();
    _loadUpanishads();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _chaptersLoading = true;
      _chaptersError = null;
    });
    try {
      final data = await _service.fetchChapters();
      if (mounted) {
        setState(() {
          _chapters = data;
          _chaptersLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chaptersError = e.toString();
          _chaptersLoading = false;
        });
      }
    }
  }

  Future<void> _loadUpanishads() async {
    setState(() {
      _upanishadLoading = true;
      _upanishadError = null;
    });
    try {
      final data = await _service.fetchUpanishads();
      if (mounted) {
        setState(() {
          _upanishads = data;
          _upanishadLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _upanishadError = e.toString();
          _upanishadLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Scripture Library',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kGold,
          labelColor: kGold,
          unselectedLabelColor: theme.hintColor,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Bhagavad Gita'),
            Tab(icon: Icon(Icons.auto_stories_rounded), text: 'Upanishads'),
            Tab(icon: Icon(Icons.temple_hindu_rounded), text: 'Ramayana'),
            Tab(icon: Icon(Icons.brightness_5_rounded), text: 'Ramcharitmanas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GitaTabView(
            chapters: _chapters,
            isLoading: _chaptersLoading,
            error: _chaptersError,
            onRetry: _loadChapters,
            isDark: isDark,
          ),
          _UpanishadTabView(
            verses: _upanishads,
            isLoading: _upanishadLoading,
            error: _upanishadError,
            onRetry: _loadUpanishads,
            isDark: isDark,
          ),
          _DharmicSectionListView(
            source: ScriptureSource.ramayanaValmiki,
            sections: kRamayanaSections,
            title: 'Valmiki Ramayana',
            accent: kSaffron,
            isDark: isDark,
          ),
          _DharmicSectionListView(
            source: ScriptureSource.ramcharitmanas,
            sections: kRamchariSections,
            title: 'Ramcharitmanas',
            accent: kGold,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _DharmicSectionListView extends StatelessWidget {
  final ScriptureSource source;
  final List<ScriptureSectionDef> sections;
  final String title;
  final Color accent;
  final bool isDark;

  const _DharmicSectionListView({
    required this.source,
    required this.sections,
    required this.title,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ScriptureRepository();

    return Semantics(
      label: '$title, ${sections.length} sections available',
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final sec = sections[index];
          return Semantics(
            button: true,
            label: '${sec.englishName}, ${sec.devanagariName}. Double tap to open.',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: theme.cardColor,
                elevation: 0,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScriptureDharmicVerseListScreen(
                        section: sec,
                        source: source,
                        fetchVerses: source == ScriptureSource.ramayanaValmiki
                            ? () => repo.fetchRamayanaKanda(sec)
                            : () => repo.fetchRamchariKanda(sec),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withOpacity(0.22)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accent.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text(
                              '${sec.index}',
                              style: GoogleFonts.cinzel(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sec.englishName,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? kText : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sec.devanagariName,
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 13,
                                  color: accent.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: accent.withOpacity(0.6)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GitaTabView extends StatelessWidget {
  final List<ScriptureChapterData> chapters;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final bool isDark;

  const _GitaTabView({
    required this.chapters,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Semantics(
        label: 'Loading Bhagavad Gita chapters, please wait',
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kGold),
              SizedBox(height: 16),
              Text('Loading chapters…'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Semantics(
        label: 'Error loading chapters. Tap retry button to try again.',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: kGoldDim),
                const SizedBox(height: 16),
                const Text(
                  'Could not load chapters.\nCheck your connection and try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Placeholder for actual list UI if data loads successfully
    return Container();
  }
}

// Placeholder for missing _UpanishadTabView to ensure the code compiles completely
class _UpanishadTabView extends StatelessWidget {
  final List<UpanishadVerseData> verses;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final bool isDark;

  const _UpanishadTabView({
    required this.verses,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
