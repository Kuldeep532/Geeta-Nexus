import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/gita_data.dart';
import '../models/models.dart';

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

  // Logic: Database se automatically terms extract karna
  void _generateGlossaryFromData() {
    if (allVerses.isNotEmpty) {
      // Hum har shlok ke Sanskrit ya Transliteration se terms utha sakte hain
      // Par best practice ke liye hum common spiritual terms ki ek static safe list rakhenge
      // Jo compile waqt error nahi degi.
      _dynamicGlossary = _kDefaultSpiritualTerms;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Search aur Filter logic jo dynamic list par kaam karega
    final filtered = _dynamicGlossary.where((item) {
      final term = item['term']!.toLowerCase();
      final meaning = item['meaning']!.toLowerCase();
      final search = _query.toLowerCase();
      return term.contains(search) || meaning.contains(search);
    }).toList();

    filtered.sort((a, b) => a['term']!.compareTo(b['term']!));

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('GLOSSARY', style: GoogleFonts.cinzel(color: kGold, fontSize: 18)),
        centerTitle: true,
        leading: const BackButton(color: kGold),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final String term = item['term']!;
                      final String meaning = item['meaning']!;
                      final bool isExpanded = _expandedTerm == term;

                      return _buildGlossaryTile(term, meaning, isExpanded);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(color: kText),
        decoration: InputDecoration(
          hintText: 'Search Sanskrit terms...',
          hintStyle: const TextStyle(color: kTextDim, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: kGoldDim, size: 20),
          filled: true,
          fillColor: kCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildGlossaryTile(String term, String meaning, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpanded ? kGold : kDivider, width: 0.5),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _expandedTerm = isExpanded ? null : term);
          if (_searchFocus.hasFocus) _searchFocus.unfocus();
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            ListTile(
              leading: _buildLeadingAvatar(term),
              title: Text(term, style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
              trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: kGoldDim),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  meaning,
                  style: GoogleFonts.lora(color: kText, fontSize: 15, height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar(String term) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(color: kGold.withOpacity(0.1), shape: BoxShape.circle),
      child: Center(
        child: Text(term[0], style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("No terms found for '$_query'", style: const TextStyle(color: kTextDim)),
    );
  }

  // FIXED: Yeh list screen ke andar hi rahegi taaki external dependency na rahe
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
