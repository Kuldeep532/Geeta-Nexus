import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Sirf ek hi theme file rakhein taaki 'Ambiguous' error na aaye
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
    if (kAffirmations.isEmpty) return; // Safety check
    setState(() {
      _index = (_index + 1) % kAffirmations.length;
    });
  }

  void _prev() {
    if (kAffirmations.isEmpty) return; // Safety check
    setState(() {
      _index = (_index - 1 + kAffirmations.length) % kAffirmations.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Agar list khali hai toh crash na ho, isliye safety check
    if (kAffirmations.isEmpty) {
      return const Scaffold(body: Center(child: Text("No affirmations available")));
    }

    final Map<String, String> currentAff = kAffirmations[_index];
    final String text = currentAff['text'] ?? "No text found";
    final String source = currentAff['source'] ?? "Unknown Source";

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Daily Affirmations'),
        actions: [
          IconButton(
            tooltip: 'Copy to clipboard',
            icon: const Icon(Icons.copy_outlined, color: kGold),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$text\n— $source'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Affirmation copied!')),
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
              '${_index + 1} of ${kAffirmations.length}',
              style: const TextStyle(color: kTextDim, fontSize: 12),
            ),
            
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // 3. Named argument 'position' ka sahi istemal
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
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
        kAffirmations.length,
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
    return KeyedSubtree(
      key: ValueKey<int>(_index), 
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 24),
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.crimsonText(
                  color: kGoldLight,
                  fontSize: 22,
                  height: 1.6,
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
                  style: GoogleFonts.cinzel(color: kGoldDim, fontSize: 12),
                ),
              ),
            ],
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
          icon: const Icon(Icons.arrow_back),
          label: const Text('Prev'),
          style: OutlinedButton.styleFrom(foregroundColor: kGold),
        ),
        ElevatedButton.icon(
          onPressed: _next,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }
}
