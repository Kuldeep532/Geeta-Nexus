import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/gita_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'verse_detail_screen.dart';

class RandomVerseScreen extends StatefulWidget {
  const RandomVerseScreen({super.key});

  @override
  State<RandomVerseScreen> createState() => _RandomVerseScreenState();
}

class _RandomVerseScreenState extends State<RandomVerseScreen>
    with SingleTickerProviderStateMixin {
  late Verse _verse;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _verse = _random();
    _controller.forward();
  }

  Verse _random() {
    final all = getAllVerses(); 
    if (all.isEmpty) {
      throw Exception("Verse data is empty");
    }
    return all[Random().nextInt(all.length)];
  }

  void _refresh() {
    if (_controller.isAnimating) return;
    _controller.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _verse = _random();
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.cinzel(
        color: kSaffron,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool isBookmarked = state.isBookmarked(_verse.id);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Random Verse'),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle, color: kGold),
            onPressed: _refresh,
            tooltip: 'Refresh Verse',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGoldDim),
                ),
                child: Text(
                  'Bhagavad Gita ${_verse.id}',
                  style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGoldDim.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      _verse.sanskrit,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansDevanagari( // FIXED: Removed leading comma
                        color: kGoldLight, 
                        fontSize: 18,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: kDivider, thickness: 0.5),
                    const SizedBox(height: 16),
                    Text(
                      _verse.transliteration,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.crimsonText(
                        color: kGoldDim,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Translation'),
                    const SizedBox(height: 10),
                    Text(
                      '"${_verse.translation}"',
                      style: GoogleFonts.crimsonText(
                        color: kText,
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: kDivider),
                    ),
                    _sectionHeader('Meaning'),
                    const SizedBox(height: 10),
                    Text(
                      _verse.meaning,
                      style: const TextStyle(
                        color: kText,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _verse.keywords.map((k) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kGold.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kDivider),
                        ),
                        child: Text(
                          k,
                          style: const TextStyle(color: kGoldDim, fontSize: 12),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        state.toggleBookmark(_verse.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(!isBookmarked
                                ? 'Bookmarked to your profile'
                                : 'Removed from bookmarks'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        ); // FIXED: Removed misplaced comma
                      },
                      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                      label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: kGold,
                        side: const BorderSide(color: kGold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VerseDetailScreen(verse: _verse),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Full View'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: kGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Get Another Random Verse'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), // FIXED: Incomplete method
                    backgroundColor: kCard,
                    foregroundColor: kGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kGoldDim),
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
}
