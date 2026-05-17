import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          header: true,
          headingLevel: 1, // HTML Style Main Page Heading <h1>
          child: Text(
            'TERMS AND CONDITIONS',
            style: GoogleFonts.cinzel(
              color: kGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: kGold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Last Updated: May 18, 2026\nDeveloper Identity: Satvik Technologies\nLocation: Korba, Chhattisgarh, India",
                style: TextStyle(color: theme.hintColor, fontSize: 12, fontStyle: FontStyle.italic, height: 1.4),
              ),
              const SizedBox(height: 20),
              
              const _TermsHeading('Agreement to Terms'),
              const _TermsBody(
                'Geeta Nexus is owned and operated by Satvik Technologies, an independent developer project located in Korba, Chhattisgarh, India. By installing, accessing, or utilizing any component of this application, you explicitly execute a legally binding agreement to comply with these Terms and Conditions.',
              ),

              const _TermsHeading('1. Scope of Use & Community Guidelines'),
              const _TermsBody(
                'Geeta Nexus is provided strictly for personal, non-commercial, spiritual, and intellectual study. You agree to interact with the system platform, its data nodes, and other community vectors lawfully, respectfully, and in perfect alignment with a clean, satvik lifestyle framework.',
              ),

              const _TermsHeading('2. Nature of Spiritual Content'),
              const _TermsBody(
                'All textual translations, content summaries, verse breakdowns, and automated theological answers rendered within the software container are presented solely for inspirational, educational, and reference purposes. This data does not constitute professional instruction or a substitute for expert traditional guidance from verified spiritual mentors.',
              ),

              const _TermsHeading('3. Artificial Intelligence Engine Processing (Google Gemini)'),
              const _TermsBody(
                'The analytical chat panels and query synthesis features within the application leverage advanced Large Language Model (LLM) pipelines powered by Google Gemini integration. You acknowledge that AI systems may occasionally output incomplete, incorrect, or inaccurate responses. Users are strictly instructed to apply personal intellectual discernment.',
              ),

              const _TermsHeading('4. Account Registration & Data Sovereignty'),
              const _TermsBody(
                'Users who voluntarily instantiate dynamic cloud syncing via Google OAuth acknowledge that their display metadata (Name, Email, Profile Picture Asset) is processed by Satvik Technologies to secure account token management. You retain absolute control over your profile and hold the right to invoke permanent deletion of your cloud data node instantly through the application settings at any time.',
              ),

              const _TermsHeading('5. Open Source Autonomy & Intellectual Property'),
              const _TermsBody(
                'The core scripture verses of the Bhagavad Gita are recognized as public domain material. However, the custom UI compilation, software container code, visual themes, custom layouts, engineering logic, and original architectural content are the exclusive proprietary property of Satvik Technologies.',
              ),

              const _TermsHeading('6. Comprehensive Limitation of Liability'),
              const _TermsBody(
                'This application structure is delivered to the endpoint user on an "As-Is" and "As-Available" baseline without warranties of any variety, either express or implied. Satvik Technologies and its single-member community administration shall bear zero legal or financial liability for any specific choices, conclusions, or actions initiated by you based on the metrics or text processed inside the app.',
              ),

              const _TermsHeading('7. Compliance Revisions & Amendments'),
              const _TermsBody(
                'Satvik Technologies retains the definitive structural right to modify these terms from time to time to address emerging platform regulatory shifts (Google Play Store and Apple App Store compliance updates) or global statutory privacy legal changes. Continuous usage of the software interface following an update implies complete validation of the revised parameters.',
              ),

              const _TermsHeading('8. Statutory Governing Law & Jurisdiction'),
              const _TermsBody(
                'These terms, along with your interaction pathway inside Geeta Nexus, are governed completely by and interpreted via the legal framework of the Republic of India. Any official administrative concerns or legal disputes arising directly out of these terms shall be subject strictly to the courts of Chhattisgarh, India.',
              ),

              const _TermsHeading('9. Official Communication Channel'),
              const _PolicyBody('For dynamic clarification regarding these binding parameters, or to process legal operational concerns, contact Satvik Technologies at our official node:'),
              const SizedBox(height: 12),
              
              _buildCorporateContactBox(theme),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorporateContactBox(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SATVIK TECHNOLOGIES",
            style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
          ),
          const Divider(height: 20, color: kGoldDim),
          Semantics(
            label: "Official Developer Support Email Asset Link",
            child: Row(
              children: [
                const Icon(Icons.email_outlined, size: 18, color: kGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "kuldeepky538@gmail.com",
                    style: GoogleFonts.crimsonText(fontSize: 16, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: "Developer Operation Base Location Address",
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: kGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Korba, Chhattisgarh, India",
                    style: GoogleFonts.crimsonText(fontSize: 16, color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsHeading extends StatelessWidget {
  final String text;
  const _TermsHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Semantics(
        header: true,
        headingLevel: 2, // Perfect HTML structure for high-level screen reader tracking
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _TermsBody extends StatelessWidget {
  final String text;
  const _TermsBody(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: GoogleFonts.crimsonText(
          color: cs.onSurface.withOpacity(0.85),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}
