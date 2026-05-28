import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart'; // ERROR FIX: Theme import added

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
  List<Map<String, String>> _dynamicGlossary = [];

  @override
  void initState() {
    super.initState();
    _generateGlossaryFromData();
  }

  void _generateGlossaryFromData() {
    _dynamicGlossary = List.from(_kDefaultSpiritualTerms);
    _dynamicGlossary.sort((a, b) => (a['term'] ?? '').compareTo(b['term'] ?? ''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = _dynamicGlossary.where((item) {
      final term = (item['term'] ?? '').toLowerCase();
      final meaning = (item['meaning'] ?? '').toLowerCase();
      final search = _query.toLowerCase();
      return term.contains(search) || meaning.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('GLOSSARY', 
          style: GoogleFonts.cinzel(color: kGold, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: BackButton(
            color: kGold,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final String term = item['term'] ?? 'Unknown';
                      final String meaning = item['meaning'] ?? 'No definition available.';
                      final bool isExpanded = _expandedTerm == term;

                      return _buildGlossaryTile(context, term, meaning, isExpanded);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (v) => setState(() => _query = v),
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: 'Search terms...',
          hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: kGold.withOpacity(0.7), size: 20),
          suffixIcon: _query.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: kGold), 
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _searchController.clear();
                  setState(() => _query = '');
                }) 
            : null,
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2))
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: kGold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildGlossaryTile(BuildContext context, String term, String meaning, bool isExpanded) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? kGold : theme.dividerColor.withOpacity(0.1), 
          width: 1
        ),
        boxShadow: isExpanded 
          ? [BoxShadow(color: kGold.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)] 
          : null,
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _expandedTerm = isExpanded ? null : term);
          if (_searchFocus.hasFocus) _searchFocus.unfocus();
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: _buildLeadingAvatar(term),
              title: Text(term, 
                style: GoogleFonts.cinzel(
                  color: kGold, 
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                )
              ),
              trailing: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                color: kGold.withOpacity(0.5)
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  meaning,
                  style: GoogleFonts.lora(
                    color: theme.textTheme.bodyMedium?.color, 
                    fontSize: 15, 
                    height: 1.5
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar(String term) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.1), 
        shape: BoxShape.circle,
        border: Border.all(color: kGold.withOpacity(0.2))
      ),
      child: Center(
        child: Text(
          term.isNotEmpty ? term[0].toUpperCase() : '?', 
          style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 18)
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 60, color: theme.hintColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("No matches for '$_query'", 
            style: TextStyle(color: theme.hintColor, fontSize: 16)
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _searchController.clear();
              setState(() => _query = '');
            },
            child: const Text("Clear Search", style: TextStyle(color: kGold)),
          )
        ],
      ),
    );
  }

  static const List<Map<String, String>> _kDefaultSpiritualTerms = [
    {'term': 'Atman', 'meaning': 'The eternal, individual soul or self that is distinct from the body and mind.'},
    {'term': 'Brahman', 'meaning': 'The ultimate, infinite, and unchanging reality that is the source of everything.'},
    {'term': 'Dharma', 'meaning': 'Righteous duty, moral law, and the cosmic order that sustains the universe.'},
    {'term': 'Karma', 'meaning': 'Action and the law of cause and effect, where every deed has a consequence.'},
    {'term': 'Yoga', 'meaning': 'The spiritual discipline or union of the individual soul with the Divine consciousness.'},
    {'term': 'Moksha', 'meaning': 'The final liberation from the cycle of birth, death, and rebirth (Samsara).'},
    {'term': 'Guna', 'meaning': 'The three qualities of nature: Sattva (purity), Rajas (passion), and Tamas (ignorance).'},
    {'term': 'Bhakti', 'meaning': 'The path of devotional love and absolute surrender to the Supreme Divine.'},
    {'term': 'Samsara', 'meaning': 'The continuous cycle of birth, death, and rebirth that the soul undergoes.'},
    {'term': 'Maya', 'meaning': 'The cosmic illusion that creates the perception of duality and veils the true reality.'},
  ];
}
