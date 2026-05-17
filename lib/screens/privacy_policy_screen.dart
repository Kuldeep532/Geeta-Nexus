import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
            'PRIVACY POLICY',
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
              
              const _PolicyHeading('1. Scope & Developer Identity'),
              const _PolicyBody('This Privacy Policy defines the transparent data practices of Geeta Nexus. This application is maintained, owned, and operated by Satvik Technologies as an independent, community-led developer project for open spiritual and intellectual study. We ensure that your personal metrics are never sold, traded, or commercialized.'),

              const _PolicyHeading('2. Open Source Transparency & Public Codebase'),
              const _PolicyBody('Geeta Nexus is built as an open-source initiative under Satvik Technologies to guarantee absolute data transparency. While the client-side application source code is publicly accessible and auditable by the global developer community, all private operational data transmitted by active users is structurally isolated and encrypted.'),

              const _PolicyHeading('3. Infrastructure Security & Cloud Subsystems'),
              const _PolicyBody('To guarantee maximum security, our backend data layer utilizes enterprise-grade architecture. Our application infrastructure is deployed across decentralized secure servers whose underlying hardware and physical network isolation protocols are securely powered by global networks including Google Cloud, Microsoft Azure, and IBM Enterprise Systems.'),

              const _PolicyHeading('4. Authentication Framework & Google OAuth'),
              const _PolicyBody('Users can voluntarily utilize "Sign in with Google" to enable cross-device synchronization. This integration uses secure OAuth handshake protocols that authenticate your identity without capturing or storing your private Google account password.'),

              const _PolicyHeading('5. Exact Google Profile Data Collected'),
              const _PolicyBody('When you authenticate via Google OAuth, our database maps only three essential parameters explicitly authorized by your profile node: your display name, your registered email address locator, and your public profile picture asset URL.'),

              const _PolicyHeading('6. Purpose Specification for Personal Profile Data'),
              const _PolicyBody('Your display name and email are processed solely to verify your personal account node and maintain synchronization metrics. The profile picture asset is rendered strictly in local volatile runtime memory to personalize your user dashboard and is never stored on external trackers.'),

              const _PolicyHeading('7. Cryptographic Session Management (JWT)'),
              const _PolicyBody('Upon successful authentication, our secure server endpoints generate unique JSON Web Tokens (JWT). These short-lived cryptographic tokens are stored on your local hardware using secure platform-level keychain storage to keep your session valid across application cold starts.'),

              const _PolicyHeading('8. Dynamic Metrics & Progress Synchronization'),
              const _PolicyBody('For authenticated profiles, explicit progress indicators—such as active scripture text bookmarks, completed chapter reading milestones, and daily habit streak numbers—are synchronized to our cloud servers to prevent progress loss.'),

              const _PolicyHeading('9. Local-First Sandbox Architecture for Guest Nodes'),
              const _PolicyBody('If you choose to use the application without logging in (Guest Mode), all behavioral parameters, custom bookmarks, and session statistics remain completely locked inside your physical device’s local sandbox storage utilizing encrypted SQLite or local preference engines.'),

              const _PolicyHeading('10. India Digital Personal Data Protection (DPDP) Act Compliance'),
              const _PolicyBody('In absolute compliance with the Digital Personal Data Protection (DPDP) Act of India, Satvik Technologies acts strictly under user authorization. We implement comprehensive data minimization protocols, ensuring we only request access to elements necessary for application execution.'),

              const _PolicyHeading('11. International Data Protection Standards (GDPR & CCPA)'),
              const _PolicyBody('We respect international privacy protocols. For global community members, Satvik Technologies acts as the Data Controller. We enforce comprehensive measures to honor universal digital rights, including the rights to data access, portability, rectification, and absolute erasure.'),

              const _PolicyHeading('12. Artificial Intelligence Processing Model (Google Gemini)'),
              const _PolicyBody('Interactive theological queries and conversational chat modules inside the app are evaluated using cutting-edge LLM pipelines powered by Google Gemini integration nodes.'),

              const _PolicyHeading('13. Anonymization of AI Prompt Streams'),
              const _PolicyBody('To protect your private identity, our API gateway strips all Google account profile indicators and email references before routing text queries to the Gemini AI processing node. Prompts are treated as isolated, anonymous text objects.'),

              const _PolicyHeading('14. Essential Warning on Sensitive User Disclosures'),
              const _PolicyBody('Even though we strip identity signatures from AI operations, Satvik Technologies strictly advises all community members against typing raw personal identifiers, financial credentials, or health data inside any active AI chat field.'),

              const _PolicyHeading('15. Zero Monetization & Third-Party Disclosure Ban'),
              const _PolicyBody('We maintain an absolute ban on data commercialization. We do not sell, lease, rent, or distribute user metrics to advertising networks, corporate data brokers, or marketing aggregates under any circumstances.'),

              const _PolicyHeading('16. Authorized Operational Infrastructure Providers'),
              const _PolicyBody('Data is only processed by essential backend services required for application performance (such as Google Firebase for identity state tracking). These entities process metrics under strict enterprise confidentiality configurations.'),

              const _PolicyHeading('17. Localized Haptic Telemetry Isolation'),
              const _PolicyBody('Physical device responses—such as specific vibration intervals triggered during native pranayama breathing exercises—are managed entirely by your mobile device’s local hardware controller and are never tracked across remote data networks.'),

              const _PolicyHeading('18. Strict Prohibition of Ad-Tracking SDKs'),
              const _PolicyBody('This application does not contain advertising networks or third-party behavioral tracking kits (such as Facebook Audience Network or Google AdMob). There are no tracking scripts designed to build behavioral commercial profiles.'),

              const _PolicyHeading('19. Transport Layer Security (TLS 1.3) Network Protection'),
              const _PolicyBody('All data traveling between your mobile interface and our cloud endpoints is wrapped inside end-to-end encrypted Transport Layer Security (TLS 1.3) pipelines, eliminating the threat of data interception on public networks.'),

              const _PolicyHeading('20. Advanced Encryption Standards (AES-256) at Rest'),
              const _PolicyBody('All community data stored within our multi-cloud environment is secured at rest using military-grade Advanced Encryption Standard (AES-256) cryptographic keys managed via cloud hardware security modules.'),

              const _PolicyHeading('21. Automated Diagnostic Logging Policies'),
              const _PolicyBody('We only gather aggregated, non-identifiable technical metrics (such as stack traces via Firebase Crashlytics) to debug runtime exceptions. We maintain a zero-log policy regarding your personal search parameters or textual interactions.'),

              const _PolicyHeading('22. Absolute User Right to Permanent Deletion'),
              const _PolicyBody('You retain complete ownership of your digital profile. The application settings module provides an explicit, accessible mechanism to permanently terminate your profile and clear all associated cloud records from Satvik Technologies systems.'),

              const _PolicyHeading('23. Cascading Server-Side Data Erasure'),
              const _PolicyBody('Upon receiving an automated account termination request, our servers trigger a cascading wipe across all active database systems, permanently purging your email mappings, bookmarks, and streaks within 72 hours.'),

              const _PolicyHeading('24. Protection of Minor Endpoints'),
              const _PolicyBody('Geeta Nexus is designed for spiritual exploration and intellectual enhancement. Satvik Technologies does not intentionally collect, categorize, or track any personal information or telemetry from individuals under the age of 13.'),

              const _PolicyHeading('25. Periodic Security Assessments & Vulnerability Scans'),
              const _PolicyBody('The application source build undergoes automated dependency audits and vulnerability screening to ensure malicious exploits are prevented and the client container remains resilient against code injection.'),

              const _PolicyHeading('26. Security Breach Notification Protocol'),
              const _PolicyBody('In the unlikely event of an infrastructure anomaly or unauthorized data access, Satvik Technologies will instantly patch the vulnerability and directly notify affected community nodes via in-app alerts within 72 hours of discovery.'),

              const _PolicyHeading('27. Pure Satvik Lifestyle Alignment'),
              const _PolicyBody('Our development ethos is completely centered around personal purity. Our computational resources and server environments are maintained strictly independent of commercial networks that run counter to clean lifestyle ideals.'),

              const _PolicyHeading('28. Platform Compliance (Google Play & Apple App Store)'),
              const _PolicyBody('This policy is meticulously structured to fulfill the exact specifications of the Google Play Developer Program Policies and the Apple App Store Review Guidelines regarding data transparency, developer identity mapping, and OAuth authentication.'),

              const _PolicyHeading('29. Future Amendments & Legal Updates'),
              const _PolicyBody('As global privacy regulations evolve, this policy document may be updated by Satvik Technologies. Continued engagement with the community services following an update constitutes structural acknowledgement of the active policy revision.'),

              const _PolicyHeading('30. Governing Law & Dispute Channels'),
              const _PolicyBody('This privacy instrument is governed by and construed in accordance with the laws of the Republic of India. Any structural legal inquiries or disputes shall be processed under local administrative channels in Chhattisgarh, India.'),

              const _PolicyHeading('31. Developer Contact & Data Inquiry Administration'),
              const _PolicyBody('For questions regarding this privacy document, verified requests to extract your personal data index, or data erasure tracking, contact Satvik Technologies directly at our official operational base:'),
              const SizedBox(height: 12),
              
              _buildCorporateContactBox(theme),
              const SizedBox(height: 25),

              const _PolicyHeading('32. Statutory Declaration of Structural Agreement'),
              const _PolicyBody('By interacting with the user interface, installing the application binaries, or accessing the open-source code repositories of Geeta Nexus, you confirm full understanding and structural acceptance of all privacy bounds detailed herein by Satvik Technologies.'),
              
              const SizedBox(height: 60),
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

class _PolicyHeading extends StatelessWidget {
  final String text;
  const _PolicyHeading(this.text);

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

class _PolicyBody extends StatelessWidget {
  final String text;
  const _PolicyBody(this.text);

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
