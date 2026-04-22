import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart'; 
import '../data/gita_data.dart'; 

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  int _index = 0;

  void _next() {
    if (kChapters.isEmpty) return; 
    setState(() {
      _index = (_index + 1) % kChapters.length;
    });
    HapticFeedback.lightImpact();
  }

  void _prev() {
    if (kChapters.isEmpty) return; 
    setState(() {
      _index = (_index - 1 + kChapters.length) % kChapters.length;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (kChapters.isEmpty) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: Text(
            "Wisdom is loading...", 
            style: TextStyle(color: kGoldDim)
          )
        )
      );
    }

    final chapter = kChapters[_index];
    final String text = chapter.summary; 
    final String source = chapter.nameSanskrit; 

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Gita Wisdom',
          style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Copy to clipboard',
            icon: const Icon(Icons.copy_outlined, color: kGold),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$text\n— $source'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wisdom copied!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProgressDots(),
            const SizedBox(height: 8),
            Text(
              'Chapter ${_index + 1} of ${kChapters.length}',
              style: const TextStyle(color: kTextDim, fontSize: 12),
            ),
            
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildAffirmationCard(text, source),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildNavigationButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        kChapters.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: i == _index ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: i == _index ? kGold : kDivider,
          ),
        ),
      ),
    );
  }

  Widget _buildAffirmationCard(String text, String source) {
    return Semantics(
      label: "Chapter ${_index + 1}. $text. From $source",
      child: KeyedSubtree(
        key: ValueKey<int>(_index), 
        // FIXED: Removed the leading comma before Center
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kGoldDim.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔱', style: TextStyle(fontSize: 40)), 
                const SizedBox(height: 24),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.crimsonText(
                    color: kGoldLight, 
                    fontSize: 20,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    source,
                    style: GoogleFonts.cinzel(
                      color: kGoldDim, 
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: _prev,
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          label: const Text('PREV'),
          style: OutlinedButton.styleFrom(
            foregroundColor: kGold,
            side: const BorderSide(color: kGoldDim),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _next,
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          label: const Text('NEXT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 5,
          ),
        ),
      ],
    );
  } // FIXED: Removed extra comma before closing bracket
}
