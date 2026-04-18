import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/gita_data.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  String? _expandedTerm;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Logic Fix: Filtering + Alphabetical Sorting (A to Z)
    final filtered = kGlossary.where((g) {
      final term = (g['term'] ?? '').toLowerCase();
      final meaning = (g['meaning'] ?? '').toLowerCase();
      final search = _query.toLowerCase();
      return term.contains(search) || meaning.contains(search);
    }).toList();

    // Alphabetical sort ensures order regardless of data file structure
    filtered.sort((a, b) => (a['term'] ?? '').compareTo(b['term'] ?? ''));

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Sanskrit Glossary'),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 2. Search UI: Added Keyboard Action & Focus Management
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              textInputAction: TextInputAction.search, // Keyboard pe "Search" dikhega
              onSubmitted: (_) => _searchFocus.unfocus(), // Enter dabate hi keyboard band
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'Search terms...',
                hintStyle: const TextStyle(color: kTextDim),
                prefixIcon: const Icon(Icons.search, color: kGoldDim),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: kTextDim),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: kCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final String term = item['term'] ?? 'Unknown';
                      final String meaning = item['meaning'] ?? '';
                      final bool isExpanded = _expandedTerm == term;

                      // 3. Accessibility: Improved Semantics for Blind Users
                      return Semantics(
                        label: isExpanded 
                            ? "Term: $term. Meaning: $meaning. Double tap to collapse."
                            : "Term: $term. Click to read meaning.",
                        button: true,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isExpanded ? kGoldDim : kDivider,
                              width: isExpanded ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _expandedTerm = isExpanded ? null : term;
                              });
                              // Unfocus search when selecting an item
                              if (_searchFocus.hasFocus) _searchFocus.unfocus();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      _buildLeadingAvatar(term),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              term,
                                              style: GoogleFonts.cinzel(
                                                color: kGold,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (!isExpanded)
                                              Text(
                                                meaning,
                                                style: const TextStyle(color: kTextDim, fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isExpanded ? Icons.expand_less : Icons.expand_more,
                                        color: kGoldDim,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isExpanded)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: ExcludeSemantics( // Preventing redundant reading
                                      child: Text(
                                        meaning,
                                        style: GoogleFonts.crimsonText(
                                          color: kText,
                                          fontSize: 17, // Increased size for readability
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingAvatar(String term) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: kGoldDim.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          term.isNotEmpty ? term[0] : '?',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, color: kTextDim, size: 48),
        const SizedBox(height: 16),
        Text(
          "No terms found for '$_query'",
          style: const TextStyle(color: kTextDim),
        ),
        TextButton(
          onPressed: () => setState(() {
            _searchController.clear();
            _query = '';
          }),
          child: const Text("Clear Search", style: TextStyle(color: kGold)),
        ),
      ],
    );
  }
}
