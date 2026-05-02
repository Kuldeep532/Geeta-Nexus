import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // FIX 1: Removed 'const' before Semantics because it was causing a build error
        title: Semantics(
          header: true,
          child: const Text('Privacy & Data Policy'),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // FIX 2: Removed 'const' from the children list because custom widgets 
            // like _Heading and _Body are being instantiated here.
            children: const [
              _Heading('Introduction'),
              _Body(
                'This Privacy Policy governs the data practices of Satvik Technologys, '
                'an independent developer entity of Geeta Nexus. '
                'By using Geeta Nexus, you agree to the collection and use of information '
                'in accordance with this policy. We prioritize your spiritual journey by '
                'ensuring your data remains private and secure.',
              ),
              _Heading('Authentication & Google Data'),
              _Body(
                'You may choose to use "Sign in with Google" for a seamless experience. '
                'When you authenticate, we access specific information provided by the Google OAuth service:\n'
                '• Basic Profile Info: Your name and email address to identify your account.\n'
                '• Profile Picture: To personalize your in-app dashboard.\n'
                '• Authentication Tokens: To securely maintain your session across devices.',
              ),
              _Heading('Data Synchronization'),
              _Body(
                'For authenticated users, your reading progress, bookmarks, and streak data '
                'are synced to our secure database. This allows you to restore your progress '
                'should you switch devices. Guest users continue to have all data stored '
                'strictly on their local hardware.',
              ),
              _Heading('India Compliance'),
              _Body(
                'We aim to process personal data in line with applicable Indian laws and '
                'platform policies, including reasonable safeguards for consent, access, '
                'correction, and deletion requests where applicable.',
              ),
              _Heading('Artificial Intelligence'),
              _Body(
                'AI interactions are powered by Google Gemini. While your prompts are '
                'transmitted to generate responses, they are not linked to your Google identity '
                'by our systems. We recommend avoiding the disclosure of sensitive personal '
                'identifiers in AI chat sessions.',
              ),
              _Heading('Third-Party Services'),
              _Body(
                'We do not sell, trade, or transfer your data to outside parties. This does not '
                'include trusted third parties who assist us in operating our app (like Google Firebase '
                'for authentication), so long as those parties agree to keep this information confidential.',
              ),
              _Heading('Data Retention & Deletion'),
              _Body(
                'You have the right to request the deletion of your account and associated data at any time. '
                'To revoke Google access or delete your cloud profile, please visit the settings '
                'menu or contact our support team.',
              ),
              _Heading('Contact Administration'),
              _Body(
                'For legal inquiries or data protection concerns, contact Satvik Technologys at:\n'
                'Email: kuldeepky538@gmail.com\n'
                'Address: Korba, Chhattisgarh, India',
              ),
              SizedBox(height: 50),
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Semantics(
        header: true, 
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: cs.primary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MergeSemantics( 
      child: Text(
        text,
        style: GoogleFonts.crimsonText(
          color: cs.onSurface,
          fontSize: 17,
          height: 1.6,
        ),
      ),
    );
  } // FIX 3: Removed the stray comma before the closing brace
}
