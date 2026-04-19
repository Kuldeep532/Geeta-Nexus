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

class _AffirmationsScreenState extends State<AffirmationsScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isAnimating) return;
    _isAnimating = true;
    _controller.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % kAffirmations.length;
      });
      _controller.forward().then((_) => _isAnimating = false);
    });
  }

  void _prev() {
    if (_isAnimating) return;
    _isAnimating = true;
    _controller.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _index = (_index - 1 + kAffirmations.length) % kAffirmations.length;
      });
      _controller.forward().then((_) => _isAnimating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aff = kAffirmations[_index];
    final String affirmationText = aff['text'] ?? '';
    final String sourceText = aff['source'] ?? '';

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Daily Affirmations'),
        leading: const BackButton(),
        actions: [
          Semantics(
            label: 'Copy affirmation to clipboard',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.copy_outlined, color: kGold),
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: '$affirmationText\n— $sourceText'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Affirmation copied!')),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Progress Indicator for screen readers
            Semantics(
              label: 'Progress: ${_index + 1} of ${kAffirmations.length}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  kAffirmations.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index ? kGold : kDivider,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ExcludeSemantics(
              child: Text(
                '${_index + 1} of ${kAffirmations.length}',
                style: const TextStyle(color: kTextDim, fontSize: 12),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
,                   position: _slideAnim,
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
                        border: Border.all(
                          color: kGoldDim.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 24),
                          Semantics(
                            label: 'Affirmation text',
                            child: Text(
                              affirmationText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.crimsonText(
                                color: kGoldLight,
                                fontSize: 22,
                                height: 1.7,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            label: 'Source',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: kDivider,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                sourceText,
                                style: GoogleFonts.cinzel(
                                    color: kGoldDim, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Semantics(
                  label: 'Previous Affirmation',
                  button: true,
                  child: OutlinedButton.icon(
                    onPressed: _prev,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Prev'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGold,
                      side: const BorderSide(color: kGold),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                Semantics(
                  label: 'Next Affirmation',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
 ,  }
}
