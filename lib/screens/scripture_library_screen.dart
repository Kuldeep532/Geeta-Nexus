import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scripture_model.dart';
import '../services/scripture_repository.dart';
import '../services/scripture_service.dart';
import '../theme.dart';
import 'scripture_verse_detail_screen.dart';
import 'scripture_dharmicdata_verse_list_screen.dart';

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
  bool _chaptersLoading = true;
  String? _chaptersError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadChapters();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = isDark ? Colors.amberAccent : kGold;
    final saffronColor = isDark ? Colors.orangeAccent : kSaffron;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        title: Text('Scripture Library', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: goldColor)),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: goldColor,
          labelColor: goldColor,
          unselectedLabelColor: theme.hintColor,
          isScrollable: true,
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
          _GitaTabView(chapters: _chapters, isLoading: _chaptersLoading, error: _chaptersError, onRetry: _loadChapters),
          const Center(child: Text("Upanishad Section - Coming Soon")),
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
  final String? error;
  final VoidCallback onRetry;

  const _GitaTabView({required this.chapters, required this.isLoading, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: kGold));
    if (error != null) return Center(child: ElevatedButton(onPressed: onRetry, child: const Text("Retry")));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final ch = chapters[index];
        return Semantics(
          button: true,
          label: 'Chapter ${ch.chapterNumber}: ${ch.englishName}. Double tap to open.',
          child: Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScriptureVerseDetailScreen(allVerses: ch.verses, initialIndex: 0),
              )),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: kGold.withOpacity(0.2), child: Text('${ch.chapterNumber}')),
                title: Text(ch.englishName),
                subtitle: Text(ch.devanagariName),
              ),
            ),
          ),
        );
      },
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
        return Semantics(
          button: true,
          label: '${sec.englishName}. Double tap to open.',
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Theme.of(context).cardColor,
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScriptureDharmicVerseListScreen(
                  section: sec,
                  source: source,
                  fetchVerses: () => source == ScriptureSource.ramayanaValmiki ? repo.fetchRamayanaKanda(sec) : repo.fetchRamchariKanda(sec),
                ),
              )),
              child: ListTile(
                leading: Text('${sec.index}', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                title: Text(sec.englishName),
                subtitle: Text(sec.devanagariName),
                trailing: Icon(Icons.chevron_right, color: accent),
              ),
            ),
          ),
        );
      },
    );
  }
}
