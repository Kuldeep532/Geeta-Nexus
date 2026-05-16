import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/scripture_service.dart';
import '../theme.dart';
import 'scripture_chapter_reader_screen.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
      if (mounted) setState(() { _chapters = data; _chaptersLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _chaptersError = e.toString(); _chaptersLoading = false; });
    }
  }

  Future<void> _loadUpanishads() async {
    setState(() {
      _upanishadLoading = true;
      _upanishadError = null;
    });
    try {
      final data = await _service.fetchUpanishads();
      if (mounted) setState(() { _upanishads = data; _upanishadLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _upanishadError = e.toString(); _upanishadLoading = false; });
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
          tabs: const [
            Tab(
              icon: Icon(Icons.menu_book_rounded),
              text: 'Bhagavad Gita',
            ),
            Tab(
              icon: Icon(Icons.auto_stories_rounded),
              text: 'Upanishads',
            ),
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
        ],
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
    final theme = Theme.of(context);

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
                const Text('Could not load chapters.\nCheck your connection and try again.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Retry loading chapters',
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Bhagavad Gita, ${chapters.length} chapters available',
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final ch = chapters[index];
          return Semantics(
            button: true,
            label: 'Chapter ${ch.chapterNumber}: ${ch.nameTranslation}, also known as ${ch.name}. ${ch.versesCount} verses. Double tap to open.',
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
                      builder: (_) => ScriptureChapterReaderScreen(chapter: ch),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kGold.withOpacity(0.18)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kGold.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text(
                              '${ch.chapterNumber}',
                              style: GoogleFonts.cinzel(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kGold,
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
                                ch.nameTranslation,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? kText : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ch.name,
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: kGoldDim,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ch.versesCount} verses · ${ch.nameMeaning}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.hintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: kGoldDim),
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
    if (isLoading) {
      return Semantics(
        label: 'Loading Upanishads data, please wait',
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kGold),
              SizedBox(height: 16),
              Text('Loading Upanishads…'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Semantics(
        label: 'Error loading Upanishads. Tap retry to try again.',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: kGoldDim),
                const SizedBox(height: 16),
                const Text('Could not load Upanishads.\nCheck your connection and try again.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Retry loading Upanishads',
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final grouped = <String, List<UpanishadVerseData>>{};
    for (final v in verses) {
      if (v.upanishadName.isEmpty) continue;
      grouped.putIfAbsent(v.upanishadName, () => []).add(v);
    }
    final names = grouped.keys.toList();

    return Semantics(
      label: '${names.length} Upanishads available',
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: names.length,
        itemBuilder: (context, i) {
          final name = names[i];
          final count = grouped[name]!.length;
          return Semantics(
            button: true,
            label: '$name Upanishad, $count verses. Double tap to open.',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScriptureUpanishadsScreen(
                        name: name,
                        verses: grouped[name]!,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kSaffron.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kSaffron.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_stories_rounded, color: kSaffron, size: 24),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$count verses',
                                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: kSaffron),
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
