import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/gita_data.dart';
import '../models/models.dart';
import 'verse_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Verse> _results = [];
  bool _searched = false;

  void _search(String q) {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    setState(() {
      _results = searchVerses(query);
      _searched = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Search Verses', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _search,
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'Search by keyword, topic, or meaning...',
                prefixIcon: const Icon(Icons.search, color: kTextDim),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: kTextDim),
                        onPressed: () {
                          _controller.clear();
                          _search('');
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
            child: _searched ? _buildResults() : _buildTopics(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Topics',
              style: GoogleFonts.cinzel(color: kGold, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: kSpiritualTopics.map((t) {
              return ActionChip(
                label: Text(t),
                labelStyle: const TextStyle(color: kGold, fontSize: 13),
                backgroundColor: kCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: kDivider),
                ),
                onPressed: () {
                  _controller.text = t;
                  _search(t);
                  FocusScope.of(context).unfocus();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: Main => MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: kTextDim, size: 48),
            const SizedBox(height: 12),
            Text('No results for "${_controller.text}"',
                style: const TextStyle(color: kTextDim, fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${_results.length} verse${_results.length != 1 ? 's' : ''} found',
                style: const TextStyle(color: kTextDim, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (ctx, i) => _verseCard(ctx, _results[i]),
          ),
        ),
      ],
    );
  }

  Widget _verseCard(BuildContext context, Verse verse) {
    return Semantics(
      label: 'Verse ${verse.id}. ${verse.translation}',
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: verse)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Verse ${verse.id}',
                    style: GoogleFonts.cinzel(
                        color: kGold, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text(
                verse.translation,
                style: GoogleFonts.crimsonText(color: kText, fontSize: 15, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
