import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
              _Heading('Terms & Conditions'),
              _Body(
                'By installing and using Geeta AI, you agree to the following terms.',
              ),
              _Heading('1. Use of the app'),
              _Body(
                'Geeta AI is provided for personal, non-commercial spiritual and educational use. You agree to use the app respectfully and lawfully.',
              ),
              _Heading('2. Spiritual content'),
              _Body(
                'Translations, summaries, and AI-generated answers are presented for inspiration and study. They are not a substitute for guidance from a qualified spiritual teacher.',
              ),
              _Heading('3. AI-generated responses'),
              _Body(
                'AI features may occasionally produce inaccurate or incomplete information. Always use your own judgement.',
              ),
              _Heading('4. Intellectual property'),
              _Body(
                'The Bhagavad Gita is in the public domain. App design, code, UI, and original content are the property of the developer.',
              ),
              _Heading('5. Limitation of liability'),
              _Body(
                'The app is provided "as is" without warranties of any kind. The developer is not liable for any decisions made based on the content of the app.',
              ),
              _Heading('6. Changes to terms'),
              _Body(
                'These terms may be updated from time to time. Continued use of the app means you accept the latest version.',
              ),
              _Heading('7. Contact'),
              _Body(
                'For questions about these terms, write to kuldeepky538@gmail.com.',
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
