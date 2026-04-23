import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'social_links.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
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
                    const SizedBox(height: 16),
                    Text('Bhagavad Gita AI',
                        style: GoogleFonts.cinzel(
                          color: kGold, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Version 1.0.0',
                        style: TextStyle(color: kTextDim, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _section('Our Mission',
                  'Geeta AI brings the timeless wisdom of the Bhagavad Gita to your fingertips with the power of modern AI. Read all 700 verses, ask questions to a Krishna-inspired guide, build a daily spiritual practice, and grow on your inner journey.'),
              _section('What you can do',
                  '• Read all 18 chapters with translations\n• Ask Krishna AI for guidance\n• Daily meditation, breathing & japa\n• Quizzes, flashcards & wisdom cards\n• Track XP, streaks and badges'),
              _section('Created by',
                  'Kuldeep Kumar Yadav\nA spiritual & AI enthusiast.'),
              const SizedBox(height: 12),
              const SocialLinksRow(),
              const SizedBox(height: 30),
              const Center(
                child: Text('Made with 🙏 for seekers everywhere',
                    style: TextStyle(color: kTextDim, fontSize: 12)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: kGold, fontSize: 13, fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(body,
              style: GoogleFonts.crimsonText(
                color: kText, fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}
