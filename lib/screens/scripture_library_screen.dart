import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scripture_model.dart';
import '../services/scripture_repository.dart';
import '../services/scripture_service.dart';
import '../theme.dart';
import 'scripture_verse_detail_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _loadChapters();
    _loadUpanishads();
  }

  Future<void> _loadChapters() async {
    try {
      final data = await _service.fetchChapters();
      if (mounted) setState(() { _chapters = data; _chaptersLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _chaptersLoading = false);
    }
  }

  Future<void> _loadUpanishads() async {
    try {
      final data = await _service.fetchUpanishads();
      if (mounted) setState(() { _upanishads = data; _upanishadLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _upanishadLoading = false);
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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Scripture Library', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: goldColor)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: goldColor,
          labelColor: goldColor,
          unselectedLabelColor: theme.hintColor,
          isScrollable: true,
          tabs: const [Tab(text: 'Gita'), Tab(text: 'Upanishads'), Tab(text: 'Ramayana'), Tab(text: 'Manas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GitaTabView(chapters: _chapters, isLoading: _chaptersLoading, onRetry: _loadChapters),
          _UpanishadTabView(verses: _upanishads, isLoading: _upanishadLoading, onRetry: _loadUpanishads),
          _DharmicSectionListView(source: ScriptureSource.ramayanaValmiki, sections: kRamayanaSections, title: 'Valmiki Ramayana', accent: saffronColor),
          _DharmicSectionListView(source: ScriptureSource.ramcharitmanas, sections: kRamchariSections, title: 'Ramcharitmanas', accent: goldColor),
        ],
      ),
    );
  }
}

class _GitaTabView extends StatelessWidget {
  final List<ScriptureChapterData> chapters;
  final bool isLoading;
  final VoidCallback onRetry;

  const _GitaTabView({required this.chapters, required this.isLoading, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: kGold));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final ch = chapters[index];
        return Card(
          color: Theme.of(context).cardColor,
          child: ListTile(
            title: Text(ch.englishName),
            subtitle: Text(ch.devanagariName),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScriptureVerseDetailScreen(allVerses: ch.verses, initialIndex: 0),
            )),
          ),
        );
      },
    );
  }
}

class _UpanishadTabView extends StatelessWidget {
  final List<UpanishadVerseData> verses;
  final bool isLoading;
  final VoidCallback onRetry;

  const _UpanishadTabView({required this.verses, required this.isLoading, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: kGold));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1, // Assuming list of Upanishads
      itemBuilder: (context, index) => Card(
        child: ListTile(
          title: const Text("Upanishad Collection"),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ScriptureUpanishadsScreen(name: "Upanishad", verses: verses),
          )),
        ),
      ),
    );
  }
}

class _DharmicSectionListView extends StatelessWidget {
  final ScriptureSource source;
  final List<ScriptureSectionDef> sections;
  final String title;
  final Color accent;

  const _DharmicSectionListView({required this.source, required this.sections, required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    final repo = ScriptureRepository();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final sec = sections[index];
        return Card(
          child: ListTile(
            leading: Text('${sec.index}', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
            title: Text(sec.englishName),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScriptureDharmicVerseListScreen(
                section: sec,
                source: source,
                fetchVerses: () => source == ScriptureSource.ramayanaValmiki ? repo.fetchRamayanaKanda(sec) : repo.fetchRamchariKanda(sec),
              ),
            )),
          ),
        );
      },
    );
  }
}
