import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
  State<ScriptureLibraryScreen> createState() =>
      _ScriptureLibraryScreenState();
}

class _ScriptureLibraryScreenState
    extends State<ScriptureLibraryScreen>
    with SingleTickerProviderStateMixin {
  final ScriptureService _service = ScriptureService();
  late final TabController _tabController;

  List<ScriptureChapterData> _chapters = [];
  List<UpanishadVerseData> _upanishads = [];

  bool _chaptersLoading = true;
  bool _upanishadsLoading = true;
  bool _chaptersError = false;
  bool _upanishadsError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_loadChapters(), _loadUpanishads()]);
  }

  Future<void> _loadChapters() async {
    setState(() {
      _chaptersLoading = true;
      _chaptersError = false;
    });
    SemanticsService.announce(
        'Loading Bhagavad Gita chapters', TextDirection.ltr);
    try {
      final data = await _service.fetchChapters();
      if (!mounted) return;
      setState(() {
        _chapters = data;
        _chaptersLoading = false;
      });
      SemanticsService.announce(
          '${data.length} chapters loaded', TextDirection.ltr);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chaptersLoading = false;
        _chaptersError = true;
      });
      SemanticsService.announce(
          'Failed to load chapters. Double tap Retry to try again.',
          TextDirection.ltr);
    }
  }

  Future<void> _loadUpanishads() async {
    setState(() {
      _upanishadsLoading = true;
      _upanishadsError = false;
    });
    SemanticsService.announce('Loading Upanishads', TextDirection.ltr);
    try {
      final data = await _service.fetchUpanishads();
      if (!mounted) return;
      setState(() {
        _upanishads = data;
        _upanishadsLoading = false;
      });
      SemanticsService.announce('Upanishads loaded', TextDirection.ltr);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _upanishadsLoading = false;
        _upanishadsError = true;
      });
      SemanticsService.announce(
          'Failed to load Upanishads. Double tap Retry to try again.',
          TextDirection.ltr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = isDark ? Colors.amberAccent : kGold;
    final saffronColor = isDark ? Colors.orangeAccent : kSaffron;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Semantics(
          header: true,
          namesRoute: true,
          child: Text(
            'Scripture Library',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              color: goldColor,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: goldColor,
          labelColor: goldColor,
          unselectedLabelColor: theme.hintColor,
          tabs: const [
            Tab(text: 'Gita'),
            Tab(text: 'Upanishads'),
            Tab(text: 'Ramayana'),
            Tab(text: 'Manas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GitaTabView(
            chapters: _chapters,
            isLoading: _chaptersLoading,
            hasError: _chaptersError,
            onRetry: _loadChapters,
            onChapterTap: (chapter) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ScriptureChapterReaderScreen(chapter: chapter),
              ),
            ),
          ),
          _UpanishadTabView(
            verses: _upanishads,
            isLoading: _upanishadsLoading,
            hasError: _upanishadsError,
            onRetry: _loadUpanishads,
          ),
          _DharmicSectionListView(
            source: ScriptureSource.ramayanaValmiki,
            sections: kRamayanaSections,
            title: 'Valmiki Ramayana',
            accent: saffronColor,
          ),
          _DharmicSectionListView(
            source: ScriptureSource.ramcharitmanas,
            sections: kRamchariSections,
            title: 'Ramcharitmanas',
            accent: goldColor,
          ),
        ],
      ),
    );
  }
}

// ─── Gita tab ────────────────────────────────────────────────────────────────

class _GitaTabView extends StatelessWidget {
  final List<ScriptureChapterData> chapters;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final void Function(ScriptureChapterData) onChapterTap;

  const _GitaTabView({
    required this.chapters,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Semantics(
        label: 'Loading Bhagavad Gita chapters, please wait.',
        liveRegion: true,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kGold),
              SizedBox(height: 16),
              ExcludeSemantics(
                child: Text('Loading chapters…'),
              ),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Semantics(
        label: 'Failed to load chapters.',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ExcludeSemantics(
                  child: Icon(Icons.wifi_off_rounded,
                      size: 48, color: kGoldDim),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Could not load chapters.\nCheck your connection.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Retry loading chapters',
                  hint: 'Double tap to try again',
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (chapters.isEmpty) {
      return Semantics(
        label: 'No chapters found. Double tap Retry to reload.',
        child: Center(
          child: Semantics(
            button: true,
            label: 'Retry loading chapters',
            hint: 'Double tap to try again',
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final ch = chapters[index];
        final title = ch.nameTranslation.isNotEmpty
            ? ch.nameTranslation
            : ch.name;
        final label =
            'Chapter ${ch.chapterNumber}: $title. ${ch.nameTransliterated}. '
            '${ch.versesCount} verses. Double tap to open.';

        return Semantics(
          button: true,
          label: label,
          hint: 'Double tap to read this chapter',
          child: ExcludeSemantics(
            child: Card(
              child: ListTile(
                leading: ExcludeSemantics(
                  child: CircleAvatar(
                    backgroundColor: kGold.withOpacity(0.15),
                    child: Text(
                      '${ch.chapterNumber}',
                      style: const TextStyle(
                        color: kGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(title),
                subtitle: Text(ch.nameTransliterated),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onChapterTap(ch),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Upanishad tab ───────────────────────────────────────────────────────────

class _UpanishadTabView extends StatelessWidget {
  final List<UpanishadVerseData> verses;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  const _UpanishadTabView({
    required this.verses,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Semantics(
        label: 'Loading Upanishads, please wait.',
        liveRegion: true,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kGold),
              SizedBox(height: 16),
              ExcludeSemantics(child: Text('Loading Upanishads…')),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Semantics(
        label: 'Failed to load Upanishads.',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ExcludeSemantics(
                  child: Icon(Icons.wifi_off_rounded,
                      size: 48, color: kGoldDim),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Could not load Upanishads.\nCheck your connection.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Retry loading Upanishads',
                  hint: 'Double tap to try again',
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (verses.isEmpty) {
      return Semantics(
        label: 'No Upanishads found. Double tap Retry to reload.',
        child: Center(
          child: Semantics(
            button: true,
            label: 'Retry loading Upanishads',
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          button: true,
          label: 'Upanishad Collection. Tap to explore all Upanishad verses.',
          hint: 'Double tap to open',
          child: ExcludeSemantics(
            child: Card(
              child: ListTile(
                title: const Text('Upanishad Collection'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScriptureUpanishadsScreen(
                        name: 'Upanishads',
                        verses: verses,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Dharmic section list ────────────────────────────────────────────────────

class _DharmicSectionListView extends StatelessWidget {
  final ScriptureSource source;
  final List<ScriptureSectionDef> sections;
  final String title;
  final Color accent;

  const _DharmicSectionListView({
    required this.source,
    required this.sections,
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final repo = ScriptureRepository();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final sec = sections[index];
        final label =
            'Section ${sec.index}: ${sec.englishName}. Double tap to read.';

        return Semantics(
          button: true,
          label: label,
          hint: 'Double tap to open',
          child: ExcludeSemantics(
            child: Card(
              child: ListTile(
                leading: Text(
                  '${sec.index}',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(sec.englishName),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScriptureDharmicVerseListScreen(
                        section: sec,
                        source: source,
                        fetchVerses: () {
                          if (source == ScriptureSource.ramayanaValmiki) {
                            return repo.fetchRamayanaKanda(sec);
                          }
                          return repo.fetchRamchariKanda(sec);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
