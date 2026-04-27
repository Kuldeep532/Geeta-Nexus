import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = const Color(0xFFFFD700);

    final filtered = _dynamicGlossary.where((item) {
      final term = (item['term'] ?? '').toLowerCase();
      final meaning = (item['meaning'] ?? '').toLowerCase();
      final search = _query.toLowerCase();
      return term.contains(search) || meaning.contains(search);
    }).toList();

    filtered.sort((a, b) => (a['term'] ?? '').compareTo(b['term'] ?? ''));

    return Scaffold(
      // Automatic background color based on theme
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('GLOSSARY', 
          style: GoogleFonts.cinzel(color: goldColor, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        leading: BackButton(color: goldColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(context, goldColor),
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

                      return _buildGlossaryTile(context, term, meaning, isExpanded, goldColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Color goldColor) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Semantics(
        label: "Search Sanskrit terms here",
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (v) => setState(() => _query = v),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Search terms...',
            hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: goldColor.withOpacity(0.7), size: 20),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), 
              borderSide: BorderSide(color: theme.dividerColor, width: 0.5)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: goldColor, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlossaryTile(BuildContext context, String term, String meaning, bool isExpanded, Color goldColor) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      expanded: isExpanded,
      label: "$term. ${isExpanded ? 'Expanded' : 'Collapsed'}. Double tap to see meaning.",
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded ? goldColor : theme.dividerColor.withOpacity(0.1), 
            width: 1
          ),
          boxShadow: isExpanded ? [BoxShadow(color: goldColor.withOpacity(0.1), blurRadius: 8)] : null,
        ),
        child: InkWell(
          onTap: () {
            setState(() => _expandedTerm = isExpanded ? null : term);
            if (_searchFocus.hasFocus) _searchFocus.unfocus();
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: _buildLeadingAvatar(term, goldColor),
                title: Text(term, 
                  style: GoogleFonts.cinzel(
                    color: goldColor, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  )
                ),
                trailing: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                  color: goldColor.withOpacity(0.5)
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: ExcludeSemantics( // Preventing redundant reading
                    child: Text(
                      meaning,
                      style: GoogleFonts.lora(
                        color: theme.textTheme.bodyMedium?.color, 
                        fontSize: 15, 
                        height: 1.5
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar(String term, Color goldColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: goldColor.withOpacity(0.1), 
        shape: BoxShape.circle,
        border: Border.all(color: goldColor.withOpacity(0.3))
      ),
      child: Center(
        child: Text(
          term.isNotEmpty ? term[0] : '?', 
          style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 18)
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50, color: theme.hintColor),
          const SizedBox(height: 16),
          Text("No terms found for '$_query'", 
            style: TextStyle(color: theme.hintColor, fontSize: 16)
          ),
        ],
      ),
    );
  }

  static const List<Map<String, String>> _kDefaultSpiritualTerms = [
    {'term': 'Atman', 'meaning': 'The eternal, individual soul or self.'},
    {'term': 'Brahman', 'meaning': 'The ultimate, infinite reality or Godhead.'},
    {'term': 'Dharma', 'meaning': 'Righteous duty, law, and cosmic order.'},
    {'term': 'Karma', 'meaning': 'Action and its subsequent consequences.'},
    {'term': 'Yoga', 'meaning': 'Union of the individual soul with the Divine.'},
    {'term': 'Moksha', 'meaning': 'Liberation from the cycle of birth and death.'},
    {'term': 'Guna', 'meaning': 'The three qualities of nature: Sattva, Rajas, and Tamas.'},
    {'term': 'Bhakti', 'meaning': 'Devotional love and surrender to the Divine.'},
  ];
}
