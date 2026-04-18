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
    // Initialize TabController with a listener if you need to track tab changes
    _tabs = TabController(length: 3, vsync: this);
    
    // Using microtask or PostFrameCallback is correct for state updates during init
    Future.microtask(() {
      if (mounted) {
        context.read<AppState>().markVerseRead(widget.verse.id);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Selector is more efficient than watch if you only care about specific properties
    return Consumer<AppState>(
      builder: (context, state, child) {
        final verse = widget.verse;
        final isBookmarked = state.isBookmarked(verse.id);

        return Scaffold(
          backgroundColor: kBg,
          appBar: AppBar(
            elevation: 0,
            title: Text(
              'Verse ${verse.id}',
              style: GoogleFonts.cinzel(color: kGold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: kGold,
                ),
                onPressed: () => _handleBookmark(context, state, isBookmarked),
              ),
              IconButton(
                tooltip: 'Copy to Clipboard',
                icon: const Icon(Icons.copy, color: kGold),
                onPressed: () => _copyToClipboard(context, verse),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildVerseHeader(verse),
              _buildTabBar(),
              _buildTabContent(verse),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerseHeader(Verse verse) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGoldDim.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.separated,
            children: [
              Expanded(
                child: Text(
                  'Chapter ${verse.chapter}, Verse ${verse.verse}',
                  style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 14,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildLanguageToggle(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _showTransliteration ? verse.transliteration : verse.sanskrit,
            textAlign: TextAlign.center,
            style: _showTransliteration
                ? GoogleFonts.crimsonText(
                    color: kGoldLight,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  )
                : GoogleFonts.notoSansDevanagari(
                    color: kGoldLight,
                    fontSize: 20,
                    height: 1.6,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return InkWell(
      onTap: () => setState(() => _showTransliteration = !_showTransliteration),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kDivider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kGoldDim.withOpacity(0.2)),
        ),
        child: Text(
          _showTransliteration ? 'IAST' : 'Sanskrit',
          style: const TextStyle(
            color: kGoldDim,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabs,
      labelColor: kGold,
      unselectedLabelColor: kTextDim,
      indicatorColor: kGold,
      indicatorWeight: 3,
      tabs: const [
        Tab(child: Text('Translation', style: TextStyle(fontSize: 13))),
        Tab(child: Text('Meaning', style: TextStyle(fontSize: 13))),
        Tab(child: Text('Keywords', style: TextStyle(fontSize: 13))),
      ],
    );
  }

  Widget _buildTabContent(Verse verse) {
    return Expanded(
      child: TabBarView(
        controller: _tabs,
        children: [
          _scrollablePadding(
            child: Text(
              '"${verse.translation}"',
              style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 19,
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
            ),
          ),
          _scrollablePadding(
            child: Text(
              verse.meaning,
              style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 17,
                height: 1.6,
              ),
            ),
          ),
          _scrollablePadding(
            child: Wrap(
              spacing: 10,
              runSpacing: 12,
              children: verse.keywords.map((k) => _buildChip(k)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGoldDim.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: kGold, fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _scrollablePadding({required Widget child}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: child,
    );
  }

  void _handleBookmark(BuildContext context, AppState state, bool isBookmarked) {
    state.toggleBookmark(widget.verse.id);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: kCard,
        content: Text(
          isBookmarked ? 'Removed from bookmarks' : 'Verse Bookmarked',
          style: const TextStyle(color: kGold),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, Verse verse) {
    Clipboard.setData(ClipboardData(
      text: '${verse.sanskrit}\n\n${verse.translation}\n— Bhagavad Gita ${verse.chapter}.${verse.verse}',
    ));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verse details copied')),
    );
  }
}
