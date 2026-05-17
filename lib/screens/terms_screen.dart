import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Terms and Conditions'),
        ),
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
              _Heading('Terms and Conditions'),
              _Body(
                'Geeta Nexus is provided by Satvik Technologys, an independent developer entity led by Kuldeep Kumar Yadav. By installing and using the app, you agree to the following terms.',
              ),
              _Heading('1. Use of the App'),
              _Body(
                'Geeta Nexus is provided for personal, non-commercial spiritual and educational use. You agree to use the app respectfully and lawfully.',
              ),
              _Heading('2. Spiritual Content'),
              _Body(
                'Translations, summaries, and AI-generated answers are presented for inspiration and study. They are not a substitute for guidance from a qualified spiritual teacher.',
              ),
              _Heading('3. AI-Generated Responses'),
              _Body(
                'AI features may occasionally produce inaccurate or incomplete information. Always use your own judgement.',
              ),
              _Heading('4. Intellectual Property'),
              _Body(
                'The Bhagavad Gita is in the public domain. App design, code, UI, and original content are the property of Satvik Technologys.',
              ),
              _Heading('5. Limitation of Liability'),
              _Body(
                'The app is provided "as is" without warranties of any kind. Satvik Technologys and the developer are not liable for any decisions made based on the content of the app.',
              ),
              _Heading('6. Changes to Terms'),
              _Body(
                'These terms may be updated from time to time. Continued use of the app means you accept the latest version.',
              ),
              _Heading('7. Governing Context'),
              _Body(
                'These terms are intended to be interpreted in line with applicable laws of India.',
              ),
              _Heading('8. Contact'),
              _Body(
                'For questions about these terms, contact Satvik Technologys:\nEmail: kuldeepky538@gmail.com\nAddress: Korba, Chhattisgarh, India.',
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
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Semantics(
          header: true,
          child: Text(
            text,
            style: GoogleFonts.cinzel(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.crimsonText(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      );
}
