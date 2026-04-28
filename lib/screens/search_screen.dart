import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';
import '../models/models.dart';
import '../theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Verse> _results = [];
  bool _isSearching = false;

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      // gita_data.dart se search function call ho raha hai
      _results = searchVerses(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Shlokas'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search by keyword, topic or verse ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty && _isSearching
                ? const Center(child: Text('No results found.'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final verse = _results[index];
                      return ListTile(
                        title: Text('Chapter ${verse.chapter}, Verse ${verse.verse}'),
                        subtitle: Text(
                          verse.translation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: kGoldDim,
                          child: Text(
                            '${verse.verse}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        onTap: () {
                          // Navigate to detail screen logic
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
