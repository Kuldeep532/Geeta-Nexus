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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRamayana = widget.source == ScriptureSource.ramayanaValmiki;
    final accent = isRamayana ? kSaffron : kGold;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(color: accent),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.section.englishName,
              style: GoogleFonts.cinzel(
                  color: accent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              widget.section.devanagariName,
              style: GoogleFonts.notoSansDevanagari(
                  color: accent.withOpacity(0.65), fontSize: 12),
            ),
          ],
        ),
      ),
      body: _loading
          ? Semantics(
              label:
                  'Loading ${widget.section.englishName} verses, please wait',
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: kGold),
                    SizedBox(height: 14),
                    Text('Loading verses…'),
                  ],
                ),
              ),
            )
          : _error != null
              ? _buildError(accent)
              : _buildVerseList(theme, isDark, accent, isRamayana),
    );
  }

  Widget _buildError(Color accent) {
    return Semantics(
      label: 'Error loading verses. Tap retry to try again.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: accent.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text(
                'Could not load verses.\nCheck your connection and try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: 'Retry loading verses',
                child: ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kGold, foregroundColor: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseList(
      ThemeData theme, bool isDark, Color accent, bool isRamayana) {
    if (_verses.isEmpty) {
      return const Center(child: Text('No verses found.'));
    }

    String? currentSubLabel;

    return Semantics(
      label: '${_verses.length} verses in ${widget.section.englishName}',
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _verses.length,
        itemBuilder: (context, index) {
          final verse = _verses[index];
          final subLabel = verse.section.subLabel;
          final showHeader = isRamayana &&
              subLabel.isNotEmpty &&
              subLabel != currentSubLabel;
          if (showHeader) currentSubLabel = subLabel;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Text(
                    subLabel,
                    style: GoogleFonts.cinzel(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              Semantics(
                button: true,
                label: '${verse.section.displayLabel}, verse ${verse.verseIndex}. '
                    '${verse.verseType != null ? "Type: ${verse.verseType}. " : ""}'
                    '${verse.originalText.replaceAll('\n', ' ').substring(0, verse.originalText.length.clamp(0, 100))}. '
                    'Double tap to open.',
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScriptureVerseDetailScreen(
                            allVerses: _verses,
                            initialIndex: index,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: accent.withOpacity(0.18)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: accent.withOpacity(0.3)),
                              ),
                              child: Center(
                                child: Text(
                                  '${verse.verseIndex}',
                                  style: GoogleFonts.cinzel(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: accent),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  if (verse.verseType != null)
                                    Text(
                                      verse.verseType!,
                                      style:
                                          GoogleFonts.notoSansDevanagari(
                                        fontSize: 11,
                                        color: kSaffron,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  Text(
                                    verse.originalText.replaceAll('\n', ' '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.notoSansDevanagari(
                                      fontSize: 14,
                                      height: 1.55,
                                      color: isDark
                                          ? kText
                                          : const Color(0xFF2A1F00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: accent.withOpacity(0.5), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
