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
    if (q.trim().isEmpty) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    setState(() {
      _results = searchVerses(q.trim());
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
        title: const Text('Search Verses'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
              ),
            ),
          ),
          if (!_searched) _buildTopics(),
          if (_searched && _results.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, color: kTextDim, size: 48),
                    const SizedBox(height: 12),
                    Text('No verses found for "${_controller.text}"',
                        style: const TextStyle(color: kTextDim, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('Try: karma, soul, devotion, wisdom',
                        style: TextStyle(color: kTextDim, fontSize: 12)),
                  ],
                ),
              ),
            ),
          if (_results.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Topics',
              style: GoogleFonts.cinzel(
                  color: kGold, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kSpiritualTopics.map((t) {
              return GestureDetector(
                onTap: () {
                  _controller.text = t;
                  _search(t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kDivider),
                  ),
                  child: Text(t,
                      style: const TextStyle(color: kGold, fontSize: 13)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _verseCard(BuildContext context, Verse verse) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: verse))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGoldDim),
                  ),
                  child: Text('Gita ${verse.id}',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              verse.translation,
              style: GoogleFonts.crimsonText(
                  color: kText, fontSize: 14, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: verse.keywords.take(3).map((k) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kDivider,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(k,
                        style:
                            const TextStyle(color: kTextDim, fontSize: 10)),
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
