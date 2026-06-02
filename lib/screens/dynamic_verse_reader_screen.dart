import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../data/scripture_sources.dart';
import '../models/dynamic_scripture.dart';
import '../theme.dart';
import 'aira_screen.dart';

/// Dynamic verse reader — fetches verses for any chapter from a remote JSON URL.
/// Works with any text that has a versesUrlTemplate defined.
class DynamicVerseReaderScreen extends StatefulWidget {
  final ScriptureTextDef text;
  final DynamicChapter chapter;

  const DynamicVerseReaderScreen({
    super.key,
    required this.text,
    required this.chapter,
  });

  @override
  State<DynamicVerseReaderScreen> createState() => _DynamicVerseReaderScreenState();
}

class _DynamicVerseReaderScreenState extends State<DynamicVerseReaderScreen> {
  bool _loading = true;
  String? _error;
  List<DynamicVerse> _verses = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchVerses();
  }

  Future<void> _fetchVerses() async {
    final template = widget.text.versesUrlTemplate;
    final chapterNum = widget.chapter.number ?? 1;

    String url;
    if (template != null) {
      url = template.replaceAll('{ch}', '$chapterNum');
    } else {
      // Try to infer from chaptersUrl
      final chaptersUrl = widget.text.chaptersUrl ?? '';
      if (chaptersUrl.endsWith('_index.json')) {
        url = chaptersUrl.replaceAll('_index.json', '/chapter_$chapterNum.json');
      } else if (chaptersUrl.endsWith('.json')) {
        url = chaptersUrl.replaceAll('.json', '/$chapterNum.json');
      } else {
        url = '$chaptersUrl/$chapterNum.json';
      }
    }

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> raw = [];
      if (decoded is List) {
        raw = decoded;
      } else if (decoded is Map) {
        raw = decoded['verses'] as List<dynamic>? ?? [];
      }

      final verses = raw
          .map((e) => DynamicVerse.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _verses = verses;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load verses.\n$e';
          _loading = false;
        });
      }
    }
  }

  void _goNext() {
    if (_currentIndex < _verses.length - 1) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex++);
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chName = widget.chapter.name ?? 'Chapter ${widget.chapter.number ?? 1}';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          widget.text.title,
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : _error != null
              ? _buildError()
              : _verses.isEmpty
                  ? _buildEmpty()
                  : Column(
                      children: [
                        _buildVerseIndicator(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            child: _buildVerseCard(_verses[_currentIndex], theme, isDark),
                          ),
                        ),
                        _buildNavBar(),
                      ],
                    ),

      // Ask Aira FAB
      floatingActionButton: _verses.isEmpty || _loading
          ? null
          : Semantics(
              button: true,
              label: 'Ask Aira about ${widget.text.title} ${chName}.',
              hint: 'Double-tap to open the AI assistant with this chapter as context.',
              child: FloatingActionButton.extended(
                heroTag: 'dynamic_aira_fab',
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.support_agent_rounded),
                label: Text('Ask Aira',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                tooltip: 'Ask Aira about this chapter',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final verse = _verses[_currentIndex];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiraScreen(
                        contextShloka:
                            '${widget.text.title} — ${chName}: ${verse.text.substring(0, verse.text.length > 200 ? 200 : verse.text.length)}...',
                        contextVerse:
                            '${widget.text.title}, ${chName} — Verse ${verse.verseNumber ?? _currentIndex + 1}',
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildVerseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Verse ${_currentIndex + 1} of ${_verses.length}',
            style: GoogleFonts.cinzel(
              fontSize: 12,
              color: kGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(DynamicVerse verse, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(20),
      child: Semantics(
        explicitChildNodes: true,
        label: 'Verse ${verse.verseNumber ?? _currentIndex + 1} of ${_verses.length}.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.chapter.number ?? 1}.${verse.verseNumber ?? _currentIndex + 1}',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  color: kGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (verse.text.isNotEmpty)
              Text(
                verse.text,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  height: 1.9,
                  fontStyle: FontStyle.italic,
                  color: isDark ? kText : null,
                ),
              ),
            if (verse.transliteration.isNotEmpty) ...[
              const Divider(height: 24, color: kDivider),
              Text(
                verse.transliteration,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  height: 1.6,
                  color: kGoldDim,
                ),
              ),
            ],
            if (verse.translation.isNotEmpty) ...[
              const Divider(height: 24, color: kDivider),
              Text(
                verse.translation,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  height: 1.7,
                  color: isDark ? kTextDim : null,
                ),
              ),
            ],
            if (verse.wordMeanings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Word meanings',
                    style: GoogleFonts.lato(fontSize: 12, color: theme.hintColor)),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      verse.wordMeanings,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        height: 1.6,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < _verses.length - 1;
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: kGold.withOpacity(0.12))),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: hasPrev ? kGold : kGold.withOpacity(0.25),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: hasPrev ? _goPrev : null,
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                label: Text('Previous',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: hasNext ? kGold : kGold.withOpacity(0.25),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: hasNext ? _goNext : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                iconAlignment: IconAlignment.end,
                label: Text('Next',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: kGoldDim),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _fetchVerses();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'No verses found for this chapter.',
        style: GoogleFonts.inter(color: kGoldDim),
      ),
    );
  }
}

