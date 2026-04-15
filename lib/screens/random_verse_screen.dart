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
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _verse = _random();
    _controller.forward();
  }

  Verse _random() {
    final all = getAllVerses();
    return all[Random().nextInt(all.length)];
  }

  void _refresh() {
    _controller.reverse().then((_) {
      setState(() => _verse = _random());
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Random Verse'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle, color: kGold),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
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
                child: Text('Bhagavad Gita ${_verse.id}',
                    style: GoogleFonts.cinzel(color: kGold, fontSize: 13)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                      style: GoogleFonts.notoSansDevanagari(
                          color: kGoldLight, fontSize: 15, height: 1.8),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: kDivider),
                    const SizedBox(height: 16),
                    Text(
                      _verse.transliteration,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.crimsonText(
                          color: kGoldDim,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Translation',
                        style: GoogleFonts.cinzel(
                            color: kGold, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(
                      '"${_verse.translation}"',
                      style: GoogleFonts.crimsonText(
                          color: kText,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.7),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: kDivider),
                    const SizedBox(height: 14),
                    Text('Meaning',
                        style: GoogleFonts.cinzel(
                            color: kGold, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(_verse.meaning,
                        style: const TextStyle(
                            color: kText, fontSize: 14, height: 1.7)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _verse.keywords.map((k) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: kDivider,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(k,
                                style: const TextStyle(
                                    color: kGoldDim, fontSize: 12)),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.isBookmarked(_verse.id)
                                ? 'Bookmarked! +5 XP'
                                : 'Bookmark removed'),
                          ),
                        );
                        setState(() {});
                      },
                      icon: Icon(
                        state.isBookmarked(_verse.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                      ),
                      label: Text(state.isBookmarked(_verse.id)
                          ? 'Bookmarked'
                          : 'Bookmark'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kGold,
                        side: const BorderSide(color: kGold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  VerseDetailScreen(verse: _verse))),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Full View'),
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
                  label: const Text('Another Verse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCard,
                    foregroundColor: kGold,
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
