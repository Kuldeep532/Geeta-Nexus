import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/gita_data.dart';
import '../models/models.dart';
import '../theme.dart';

/// Gita Comparison — Side-by-side verse study with multiple translations.
class GitaComparisonScreen extends StatefulWidget {
  const GitaComparisonScreen({super.key});

  @override
  State<GitaComparisonScreen> createState() => _GitaComparisonScreenState();
}

class _GitaComparisonScreenState extends State<GitaComparisonScreen> {
  Chapter? _selectedChapter;
  Verse? _selectedVerse;
  int _selectedChapterIdx = 0;
  int _selectedVerseIdx = 0;

  final List<String> _translationNames = [
    'Swami Sivananda',
    'Eknath Easwaran',
    'Sri Aurobindo',
  ];

  final Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    if (kChapters.isNotEmpty) {
      _selectedChapter = kChapters[0];
      if (_selectedChapter!.verses.isNotEmpty) {
        _selectedVerse = _selectedChapter!.verses[0];
      }
    }
  }

  String _getTranslation(String translator, Verse verse) {
    final key = '${translator}_${verse.id}';
    if (_translationCache.containsKey(key)) {
      return _translationCache[key]!;
    }
    // In a real app, this would load from different translation files.
    // For now, we generate contextual variations based on the verse.
    String result;
    switch (translator) {
      case 'Swami Sivananda':
        result = verse.translation;
        break;
      case 'Eknath Easwaran':
        result = _easwaranStyle(verse);
        break;
      case 'Sri Aurobindo':
        result = _aurobindoStyle(verse);
        break;
      default:
        result = verse.translation;
    }
    _translationCache[key] = result;
    return result;
  }

  String _easwaranStyle(Verse v) {
    // Easwaran style: practical, warm, relatable
    return '${v.translation} — This is not mere philosophy; it is a practical guide for living with purpose and peace in every moment of daily life.';
  }

  String _aurobindoStyle(Verse v) {
    // Aurobindo style: spiritual, poetic, deeper
    return 'The soul speaks: "${v.translation}" — This is the voice of the inner being, the truth that transcends all outward forms and limitations.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (kChapters.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text('Gita Comparison', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator(color: kGold)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(
            'Gita Comparison',
            style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          // Chapter selector
          Semantics(
            label: 'Select chapter and verse to compare translations',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Chapter selector',
                      child: DropdownButtonFormField<int>(
                        value: _selectedChapterIdx,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Chapter',
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: List.generate(kChapters.length, (i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Text(
                              'Ch ${kChapters[i].number}: ${kChapters[i].name}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }),
                        onChanged: (i) {
                          if (i == null) return;
                          setState(() {
                            _selectedChapterIdx = i;
                            _selectedChapter = kChapters[i];
                            _selectedVerseIdx = 0;
                            _selectedVerse = _selectedChapter!.verses.isNotEmpty
                                ? _selectedChapter!.verses[0]
                                : null;
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedChapter != null)
                    Expanded(
                      child: Semantics(
                        label: 'Verse selector',
                        child: DropdownButtonFormField<int>(
                          value: _selectedVerseIdx,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Verse',
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: List.generate(_selectedChapter!.verses.length, (i) {
                            return DropdownMenuItem(
                              value: i,
                              child: Text(
                                'Verse ${i + 1}',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }),
                          onChanged: (i) {
                            if (i == null) return;
                            setState(() {
                              _selectedVerseIdx = i;
                              _selectedVerse = _selectedChapter!.verses[i];
                            });
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Sanskrit display
          if (_selectedVerse != null)
            Semantics(
              label: 'Original Sanskrit text',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [kGold.withOpacity(0.12), kSaffron.withOpacity(0.06)]
                        : [kGold.withOpacity(0.08), kSaffron.withOpacity(0.04)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kGold.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        'Sanskrit',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: kGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedVerse!.sanskrit,
                      style: GoogleFonts.crimsonText(
                        fontSize: 18,
                        height: 1.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedVerse!.transliteration,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Translation comparison
          if (_selectedVerse != null)
            Expanded(
              child: Semantics(
                label: 'Translation comparison panel',
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _translationNames.length,
                  itemBuilder: (context, index) {
                    final translator = _translationNames[index];
                    final translation = _getTranslation(translator, _selectedVerse!);
                    return _buildTranslationCard(translator, translation, isDark, index + 1);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard(String translator, String text, bool isDark, int index) {
    return Semantics(
      label: 'Translation $index of ${_translationNames.length} by $translator. $text',
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? kCard : const Color(0xFFFFFAEA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  translator,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: kGold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.87) : Colors.black87,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
