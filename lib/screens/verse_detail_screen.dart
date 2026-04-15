import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class VerseDetailScreen extends StatefulWidget {
  final Verse verse;
  const VerseDetailScreen({super.key, required this.verse});

  @override
  State<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends State<VerseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _showTransliteration = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markVerseRead(widget.verse.id);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final verse = widget.verse;
    final isBookmarked = state.isBookmarked(verse.id);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Verse ${verse.id}',
            style: GoogleFonts.cinzel(color: kGold, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: kGold),
            onPressed: () {
              state.toggleBookmark(verse.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isBookmarked
                      ? 'Removed from bookmarks'
                      : 'Bookmarked! +5 XP'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: kGold),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text: '"${verse.translation}"\n— Bhagavad Gita ${verse.id}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verse copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGoldDim.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Chapter ${verse.chapter}, Verse ${verse.verse}',
                      style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 13, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(
                          () => _showTransliteration = !_showTransliteration),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kDivider,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _showTransliteration ? 'IAST' : 'Sanskrit',
                          style:
                              const TextStyle(color: kGoldDim, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _showTransliteration
                      ? verse.sanskrit
                      : verse.transliteration,
                  style: _showTransliteration
                      ? GoogleFonts.notoSansDevanagari(
                          color: kGoldLight, fontSize: 15, height: 1.8)
                      : GoogleFonts.crimsonText(
                          color: kGoldLight,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.7),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            labelColor: kGold,
            unselectedLabelColor: kTextDim,
            indicatorColor: kGold,
            tabs: const [
              Tab(text: 'Translation'),
              Tab(text: 'Meaning'),
              Tab(text: 'Keywords'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _tabContent(
                  child: Text(
                    '"${verse.translation}"',
                    style: GoogleFonts.crimsonText(
                        color: kText,
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        height: 1.8),
                  ),
                ),
                _tabContent(
                  child: Text(
                    verse.meaning,
                    style: GoogleFonts.crimsonText(
                        color: kText, fontSize: 16, height: 1.8),
                  ),
                ),
                _tabContent(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: verse.keywords.map((k) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kGoldDim),
                        ),
                        child: Text(
                          k,
                          style: const TextStyle(color: kGold, fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabContent({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}
