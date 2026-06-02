import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../data/scripture_sources.dart';
import '../models/dynamic_scripture.dart';
import '../theme.dart';
import 'dynamic_verse_reader_screen.dart';

/// Dynamic chapter list — fetches chapters from a remote JSON URL for any text
/// that has a chaptersUrl defined in the scripture catalog.
class DynamicChapterListScreen extends StatefulWidget {
  final ScriptureTextDef text;

  const DynamicChapterListScreen({super.key, required this.text});

  @override
  State<DynamicChapterListScreen> createState() => _DynamicChapterListScreenState();
}

class _DynamicChapterListScreenState extends State<DynamicChapterListScreen> {
  bool _loading = true;
  String? _error;
  List<DynamicChapter> _chapters = [];

  @override
  void initState() {
    super.initState();
    _fetchChapters();
  }

  Future<void> _fetchChapters() async {
    final url = widget.text.chaptersUrl;
    if (url == null) {
      setState(() {
        _error = 'No chapters URL available for this text.';
        _loading = false;
      });
      return;
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
        // Some APIs return {"chapters": [...]}
        raw = decoded['chapters'] as List<dynamic>? ?? [];
      }

      final chapters = raw
          .map((e) => DynamicChapter.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _chapters = chapters;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load chapters.\n$e';
          _loading = false;
        });
      }
    }
  }

  void _openChapter(DynamicChapter chapter) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicVerseReaderScreen(
          text: widget.text,
          chapter: chapter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Semantics(
          header: true,
          child: Text(
            widget.text.title,
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              color: kGold,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : _error != null
              ? _buildError()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: _chapters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final ch = _chapters[i];
                    return _ChapterTile(
                      chapter: ch,
                      index: i,
                      onTap: () => _openChapter(ch),
                    );
                  },
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
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _fetchChapters();
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
}

class _ChapterTile extends StatelessWidget {
  final DynamicChapter chapter;
  final int index;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${chapter.name ?? "Chapter ${chapter.number}"}. Double-tap to open.',
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${chapter.number ?? index + 1}',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kGold,
                        ),
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
                        chapter.name ?? 'Chapter ${chapter.number ?? index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (chapter.verseCount != null && chapter.verseCount! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${chapter.verseCount} verses',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.25)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
