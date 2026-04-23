import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Heading('Privacy Policy'),
              _Body(
                'Last updated: 2026\n\nBhagavad Gita AI is developed by Kuldeep Kumar Yadav at Satvik Technology ("we", "our"). We are committed to protecting your privacy. This policy explains what information we handle when you use the app.',
              ),
              _Heading('Information we store'),
              _Body(
                '• Your name (only stored locally on your device).\n'
                '• Your reading progress, bookmarks, journal entries, XP and streaks (all stored locally).\n'
                '• Optional permissions you grant: microphone (for voice features) and notifications.',
              ),
              _Heading('Information we DO NOT collect'),
              _Body(
                'We do not collect personal data on our servers. We do not sell or share your data with third parties.',
              ),
              _Heading('AI features'),
              _Body(
                'When you ask the AI guide a question, your message is sent to a third-party AI provider (Google Gemini) to generate a response. Please avoid sharing sensitive personal information in your prompts.',
              ),
              _Heading('Third-party links'),
              _Body(
                'The app contains links to social media (Instagram, Facebook, LinkedIn) and external websites. Their privacy policies apply when you visit them.',
              ),
              _Heading('Your control'),
              _Body(
                'You may clear all locally stored data at any time by uninstalling the app or clearing app storage from your device settings.',
              ),
              _Heading('Contact'),
              _Body(
                'For privacy questions, email Satvik Technology at kuldeepky538@gmail.com.',
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(text.toUpperCase(),
            style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1)),
      );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.crimsonText(
            color: kText, fontSize: 15, height: 1.55),
      );
}
