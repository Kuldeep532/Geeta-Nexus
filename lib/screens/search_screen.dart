import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/scripture_model.dart';
import '../services/scripture_repository.dart';
import '../theme.dart';
import 'scripture_verse_detail_screen.dart';
import 'aira_screen.dart';

/// Semantic keyword-to-theme mappings — maps emotional / conceptual
/// user queries to relevant search terms without any paid embedding API.
/// Completely free and works offline.
const Map<String, List<String>> _semanticMap = {
  'fear': ['fear', 'courage', 'brave', 'anxiety', 'worry'],
  'anger': ['anger', 'wrath', 'control', 'calm', 'peace'],
  'grief': ['grief', 'sorrow', 'death', 'loss', 'lamentation'],
  'purpose': ['purpose', 'dharma', 'duty', 'path', 'soul'],
  'love': ['love', 'devotion', 'bhakti', 'attachment', 'heart'],
  'peace': ['peace', 'tranquil', 'calm', 'quiet', 'serenity'],
  'karma': ['karma', 'action', 'deed', 'result', 'fruit'],
  'mind': ['mind', 'thoughts', 'intellect', 'consciousness', 'control'],
  'god': ['god', 'divine', 'krishna', 'supreme', 'eternal'],
  'death': ['death', 'immortal', 'soul', 'reborn', 'liberation'],
  'success': ['success', 'victory', 'effort', 'achievement', 'perseverance'],
  'detachment': ['detachment', 'renunciation', 'desire', 'attachment', 'free'],
  'meditation': ['meditation', 'yoga', 'focus', 'practice', 'discipline'],
  'sad': ['grief', 'sorrow', 'lamentation', 'pain', 'suffering'],
  'happy': ['joy', 'bliss', 'happiness', 'peace', 'liberation'],
  'confused': ['knowledge', 'wisdom', 'clarity', 'guide', 'dharma'],
  'stress': ['peace', 'calm', 'equanimity', 'stillness', 'practice'],
};

/// Expands an emotional/semantic query into concrete search terms.
List<String> _expandQuery(String query) {
  final lower = query.toLowerCase().trim();
  final results = <String>{lower};

  for (final entry in _semanticMap.entries) {
    if (lower.contains(entry.key) ||
        entry.value.any((v) => lower.contains(v))) {
      results.addAll(entry.value);
    }
  }

  // Add individual words as fallback
  results.addAll(lower.split(' ').where((w) => w.length > 2));
  return results.toList();
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScriptureRepository _repo = ScriptureRepository();
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();

  List<dynamic> _results = [];
  bool _isSearching = false;
  bool _isListening = false;
  String _aiQuery = '';

  static const _suggestedQueries = [
    'I feel afraid',
    'What is karma?',
    'Control anger',
    'Find peace',
    'My duty',
    'Soul and death',
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.44);
  }

  /// Semantic search: expands emotional/conceptual queries into
  /// multiple keyword searches, then de-duplicates results.
  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _isSearching = true;
      _aiQuery = query;
    });

    SemanticsService.announce(
        'Searching for: $query', TextDirection.ltr);

    final expandedTerms = _expandQuery(query);

    try {
      final Set<String> seenIds = {};
      final List<dynamic> merged = [];

      for (final term in expandedTerms.take(6)) {
        final gita = await _repo.searchGita(term);
        final ramayana = await _repo.searchRamayana(term);
        for (final item in [...gita, ...ramayana]) {
          final String uniqueId = item is ScriptureVerse
              ? '${item.section.sectionIndex}_${item.verseIndex}_${item.localVerseId ?? ""}'
              : item.toString();
          if (!seenIds.contains(uniqueId)) {
            seenIds.add(uniqueId);
            merged.add(item);
          }
        }
        if (merged.length >= 30) break;
      }

      if (!mounted) return;
      setState(() {
        _results = merged;
        _isSearching = false;
      });

      SemanticsService.announce(
          '${merged.length} results found for $query', TextDirection.ltr);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  Future<void> _startVoiceSearch() async {
    final available = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          setState(() => _isListening = false);
          if (_controller.text.trim().isNotEmpty) {
            _search(_controller.text.trim());
          }
        }
      },
      onError: (_) => setState(() => _isListening = false),
    );
    if (!available) return;
    setState(() => _isListening = true);
    SemanticsService.announce('Voice search active — speak your query',
        TextDirection.ltr);
    _speech.listen(
      pauseFor: const Duration(seconds: 4),
      listenFor: const Duration(seconds: 30),
      partialResults: true,
      onResult: (r) {
        setState(() => _controller.text = r.recognizedWords);
      },
    );
  }

  Future<void> _stopVoiceSearch() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_controller.text.trim().isNotEmpty) {
      _search(_controller.text.trim());
    }
  }

  void _navigateToDestination(BuildContext ctx, dynamic item) {
    if (item is ScriptureVerse) {
      Navigator.push(
          ctx,
          MaterialPageRoute(
              builder: (_) => ScriptureVerseDetailScreen(
                  allVerses: [item], initialIndex: 0)));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_rounded, color: kGold),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Semantics(
          header: true,
          child: Text(
            'Search Scriptures',
            style: GoogleFonts.cinzel(color: kGold, fontSize: 18),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Ask Aira about search results',
            hint: 'Double tap to open Aira with your current query',
            child: IconButton(
              tooltip: 'Ask Aira',
              icon: const Icon(Icons.support_agent_rounded, color: kGold),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AiraScreen(
                          contextShloka: _controller.text.trim().isNotEmpty
                              ? 'Search query: ${_controller.text.trim()}'
                              : null,
                        )),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── SEMANTIC SEARCH BAR ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Semantics(
              textField: true,
              label: 'Semantic search — type a keyword or describe how you feel',
              hint:
                  'For example: I feel afraid, What is karma, or find peace',
              child: TextField(
                controller: _controller,
                focusNode: _searchFocus,
                onChanged: _search,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search verses, or describe how you feel...',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: kGold),
                  suffixIcon: Semantics(
                    button: true,
                    label: _isListening
                        ? 'Stop voice search'
                        : 'Start voice search',
                    child: IconButton(
                      tooltip: _isListening ? 'Stop' : 'Voice search',
                      icon: Icon(
                        _isListening
                            ? Icons.mic_rounded
                            : Icons.mic_none_rounded,
                        color: _isListening ? Colors.red : kGold,
                      ),
                      onPressed:
                          _isListening ? _stopVoiceSearch : _startVoiceSearch,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── SUGGESTED SEMANTIC QUERIES ──────────────────────────────────
          if (_results.isEmpty && !_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try semantic search:',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'Suggested search queries',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _suggestedQueries.map((q) {
                        return Semantics(
                          button: true,
                          label: q,
                          hint: 'Double tap to search for $q',
                          child: ActionChip(
                            label: Text(q,
                                style: GoogleFonts.poppins(fontSize: 12)),
                            backgroundColor: isDark
                                ? kGold.withOpacity(0.12)
                                : kGold.withOpacity(0.1),
                            onPressed: () {
                              _controller.text = q;
                              _search(q);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Semantics(
                liveRegion: true,
                label: 'Searching...',
                child: const Center(
                  child: LinearProgressIndicator(
                    color: kGold,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),

          // ─── RESULTS COUNT ────────────────────────────────────────────────
          if (_results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Semantics(
                liveRegion: true,
                label: '${_results.length} results for $_aiQuery',
                child: Text(
                  '${_results.length} result${_results.length == 1 ? "" : "s"} found',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: kGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // ─── RESULTS LIST ─────────────────────────────────────────────────
          Expanded(
            child: _results.isEmpty && !_isSearching
                ? Center(
                    child: Semantics(
                      label:
                          'No results yet. Enter a keyword or emotional phrase to search.',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded,
                              size: 56, color: kGold.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'Search for wisdom\nor describe how you feel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isDark
                                  ? kTextDim
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final item = _results[i];
                      final title = item is ScriptureVerse
                          ? 'Ch.${item.section.sectionIndex} V.${item.verseIndex}: ${item.section.displayLabel}'
                          : (item.title ?? 'Verse');
                      final preview = item is ScriptureVerse
                          ? (item.translations['English'] ?? item.originalText)
                          : (item.previewText ?? '');

                      return Semantics(
                        button: true,
                        label: 'Result ${i + 1}: $title. $preview',
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kGold.withOpacity(0.12),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: GoogleFonts.cinzel(
                                    fontSize: 12,
                                    color: kGold,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          title: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            preview,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Semantics(
                                button: true,
                                label: 'Listen to this verse',
                                child: IconButton(
                                  tooltip: 'Listen',
                                  icon: const Icon(Icons.volume_up_rounded,
                                      size: 18, color: kGold),
                                  onPressed: () => _tts.speak(preview),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 20),
                            ],
                          ),
                          onTap: () =>
                              _navigateToDestination(ctx, item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
