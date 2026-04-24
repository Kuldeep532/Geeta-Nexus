import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme.dart';
import 'social_links.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('About the Application'),
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
                    // Decorative icon hidden from screen readers to reduce noise
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
                    Text(
                      'Bhagavad Gita AI',
                      style: GoogleFonts.cinzel(
                        color: kGold, 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Dynamic Version Fetching
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.data?.version ?? '...';
                        return Semantics(
                          label: 'Application version $version',
                          child: Text(
                            'Version $version',
                            style: const TextStyle(color: kTextDim, fontSize: 13),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _section(
                'Our Mission',
                'Synthesizing timeless Vedic wisdom with cutting-edge Large Language Models (LLMs). Bhagavad Gita AI provides an immersive, personalized spiritual ecosystem designed to foster self-realization and mental clarity in the modern age.',
              ),
              
              _section(
                'Core Features',
                '• High-fidelity translations of all 700 Shlokas.\n• Context-aware AI philosophical guidance.\n• Integrated modules for Prāṇāyāma and Japa meditation.\n• Gamified Vedic learning via cognitive flashcards.\n• Progress analytics and spiritual streak tracking.',
              ),

              _section(
                'Organization',
                'Satvik Technology\nArchitecting ethical and spiritual-centric AI solutions.',
              ),

              _section(
                'Leadership',
                'Kuldeep Kumar Yadav\nFounder & Lead Visionary, Satvik Technology.',
              ),

              const SizedBox(height: 16),
              const SocialLinksRow(),
              const SizedBox(height: 40),
              
              Center(
                child: Semantics(
                  label: 'Made with gratitude for seekers everywhere',
                  child: const Text(
                    'Made with 🙏 for seekers everywhere',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextDim, fontSize: 13, fontStyle: FontStyle.italic),
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

  Widget _section(String title, String body) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: GoogleFonts.crimsonText(
                color: kText,
                fontSize: 17,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
