import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/scripture_model.dart';
import '../theme.dart';
import 'scripture_verse_detail_screen.dart';

class ScriptureDharmicVerseListScreen extends StatefulWidget {
  final ScriptureSectionDef section;
  final ScriptureSource source;
  final Future<List<ScriptureVerse>> Function() fetchVerses;

  const ScriptureDharmicVerseListScreen({
    super.key,
    required this.section,
    required this.source,
    required this.fetchVerses,
  });

  @override
  State<ScriptureDharmicVerseListScreen> createState() =>
      _ScriptureDharmicVerseListScreenState();
}

class _ScriptureDharmicVerseListScreenState
    extends State<ScriptureDharmicVerseListScreen> {
  List<ScriptureVerse> _verses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.fetchVerses();
      if (mounted) {
        setState(() {
          _verses = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme-Aware optimization
    final theme = Theme.of(context);
    final isRamayana = widget.source == ScriptureSource.ramayanaValmiki;
    final accent = isRamayana ? kSaffron : kGold;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: accent),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.section.englishName,
              style: GoogleFonts.cinzel(color: accent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              widget.section.devanagariName,
              style: GoogleFonts.notoSansDevanagari(color: accent.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
      body: _loading
          ? Semantics(
              liveRegion: true,
              label: 'Loading ${widget.section.englishName} verses, please wait',
              child: const Center(child: CircularProgressIndicator(color: kGold)),
            )
          : _error != null
              ? _buildError(theme, accent)
              : _buildVerseList(theme, accent, isRamayana),
    );
  }

  Widget _buildError(ThemeData theme, Color accent) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: accent.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Could not load content.', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseList(ThemeData theme, Color accent, bool isRamayana) {
    if (_verses.isEmpty) return const Center(child: Text('No verses found.'));

    String? currentSubLabel;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: _verses.length,
      itemBuilder: (context, index) {
        final verse = _verses[index];
        final subLabel = verse.section.subLabel;
        final showHeader = isRamayana && subLabel.isNotEmpty && subLabel != currentSubLabel;
        if (showHeader) currentSubLabel = subLabel;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                child: Text(subLabel, style: GoogleFonts.cinzel(color: accent, fontWeight: FontWeight.bold)),
              ),
            Semantics(
              button: true,
              label: 'Verse ${verse.verseIndex}. ${verse.originalText.substring(0, 40)}... Double tap to read detail.',
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: theme.cardColor,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScriptureVerseDetailScreen(allVerses: _verses, initialIndex: index),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Text('${verse.verseIndex}', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            verse.originalText.replaceAll('\n', ' '), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color)
                          ),
                        ),
                        Icon(Icons.chevron_right, color: accent.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
