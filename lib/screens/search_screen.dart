import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scripture_model.dart';
import '../services/scripture_repository.dart';
import '../theme.dart';
import 'scripture_verse_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScriptureRepository _repo = ScriptureRepository();
  List<dynamic> _results = [];
  bool _isSearching = false;

  void _search(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }
    
    setState(() => _isSearching = true);
    
    // Yahan hum multiple sources mein search kar rahe hain
    final gitaResults = await _repo.searchGita(query);
    final ramayanaResults = await _repo.searchRamayana(query);
    
    setState(() {
      _results = [...gitaResults, ...ramayanaResults];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Search Scriptures', style: GoogleFonts.cinzel(color: kGold)),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              textField: true,
              label: 'Search input field',
              child: TextField(
                controller: _controller,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Search verses, chapters...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty 
              ? const Center(child: Text('Search for wisdom...'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, i) {
                    final item = _results[i];
                    return Semantics(
                      button: true,
                      label: 'Result ${i+1}: ${item.toString()}',
                      child: ListTile(
                        title: Text(item.title ?? 'Verse'),
                        subtitle: Text(item.previewText ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigateToDestination(context, item),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToDestination(BuildContext context, dynamic item) {
    // Navigation Router Logic
    if (item is ScriptureVerse) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ScriptureVerseDetailScreen(allVerses: [item], initialIndex: 0),
      ));
    } 
    // Yahan aur bhi conditions (e.g., if item is Chapter) add kar sakte hain
  }
}
