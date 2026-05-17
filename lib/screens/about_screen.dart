import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'social_links.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('About Us'),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kGold.withOpacity(0.1),
                          border: Border.all(color: kGoldDim, width: 2),
                        ),
                        child: const Center(
                          child: Text('🕉️', style: TextStyle(fontSize: 48)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        'Geeta Nexus',
                        style: GoogleFonts.cinzel(
                          color: cs.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _section(context, 'Our Mission',
                'Synthesizing timeless Vedic wisdom with cutting-edge Large Language Models (LLMs). Bhagavad Gita AI provides an immersive, personalized spiritual ecosystem designed to foster self-realization and mental clarity in the modern age.'),

              _section(context, 'Core Features',
                '• High-fidelity translations of all 700 Shlokas.\n• Context-aware AI philosophical guidance.\n• Integrated modules for Prāṇāyāma and Japa meditation.\n• Gamified Vedic learning via cognitive flashcards.\n• Progress analytics and spiritual streak tracking.'),

              _section(context, 'Developer',
                'Satvik Technologys\nIndependent developer entity behind Geeta Nexus.'),

              _section(context, 'Leadership',
                'Kuldeep Kumar Yadav\nFounder & Lead Visionary, Satvik Technologys.'),

              const SizedBox(height: 16),
              const SocialLinksRow(),
              const SizedBox(height: 40),

              Center(
                child: Semantics(
                  label: 'Made with gratitude for seekers everywhere',
                  child: const Text(
                    'Made with 🙏 for seekers everywhere',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: cs.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.crimsonText(
              color: cs.onSurface,
              fontSize: 17,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
