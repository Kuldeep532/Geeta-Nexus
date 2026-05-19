import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme.dart';
import 'social_links.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _appVersion = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _appVersion = '2.4.0';
        _buildNumber = '2026.1';
      });
    }
  }

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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [HTML h1 Equivalent] APP IDENTITY
              Center(
                child: Column(
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.surfaceContainerHigh,
                          border: Border.all(
                            color: cs.primary, 
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text('🕉️', style: TextStyle(fontSize: 56)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      label: 'Main Heading: Geeta Nexus Application',
                      child: Text(
                        'Geeta Nexus',
                        style: GoogleFonts.cinzel(
                          color: cs.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Spiritual AI Ecosystem',
                      style: GoogleFonts.crimsonText(
                        color: cs.onSurfaceVariant,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // [HTML h2] CORPORATE MISSION
              _buildHeading2(context, '01. Executive Mission'),
              _buildContentContainer(
                context,
                child: Text(
                  'Synthesizing timeless Vedic wisdom with cutting-edge Large Language Models (LLMs). '
                  'Geeta Nexus provides an immersive, personalized spiritual ecosystem designed to '
                  'foster self-realization, inner peace, and cognitive clarity in the modern age.',
                  style: GoogleFonts.crimsonText(
                    color: cs.onSurface,
                    fontSize: 16.5,
                    height: 1.6,
                  ),
                ),
              ),

              // [HTML h2] ECOSYSTEM CAPABILITIES
              _buildHeading2(context, '02. Core Capabilities'),
              _buildContentContainer(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeading3(context, 'Spiritual Intelligence Platform'),
                    _buildFeatureParagraph(context, 
                      'An advanced suite encompassing high-fidelity translations of all 700 Shlokas, '
                      'context-aware AI philosophical guidance built on authentic Vedic commentaries, '
                      'and personalized self-realization matrices.'
                    ),
                    const SizedBox(height: 16),
                    _buildHeading3(context, 'Holistic & Behavioral Modules'),
                    _buildFeatureParagraph(context, 
                      'Integrated deep-tech systems for tracking Japa and Prāṇāyāma meditation, '
                      'gamified cognitive flashcards for Vedic absorption, and predictive behavioral analytics '
                      'powering user spiritual streaks and growth milestones.'
                    ),
                  ],
                ),
              ),

              // [HTML h2] OWNERSHIP & LEADERSHIP
              _buildHeading2(context, '03. Leadership & Governance'),
              _buildContentContainer(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeading3(context, 'Satvik Technologies'),
                    Text(
                      'An independent digital entity dedicated to preserving and propagating Vedic heritage through modern software engineering.',
                      style: GoogleFonts.crimsonText(color: cs.onSurfaceVariant, fontSize: 15.5, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    _buildHeading3(context, 'Principal Architecture'),
                    Text(
                      'Kuldeep Kumar Yadav',
                      style: GoogleFonts.cinzel(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _buildHeading4(context, 'Founder, Lead Developer & Visionary'),
                  ],
                ),
              ),

              // [HTML h2] AUTO DETECTED APPLICATION INFO
              _buildHeading2(context, '04. Technical Metrics'),
              _buildContentContainer(
                context,
                child: Column(
                  children: [
                    _buildMetricRow('App Version', _appVersion, cs),
                    _buildMetricRow('Build Reference', _buildNumber.isEmpty ? 'Release' : _buildNumber, cs),
                    _buildMetricRow('Architecture', 'Flutter Engine Core', cs),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Center(child: SocialLinksRow()),
              const SizedBox(height: 48),

              // FOOTER BRANDING
              Center(
                child: Semantics(
                  label: 'Made with gratitude for seekers everywhere',
                  child: Text(
                    'Made with 🙏 for seekers everywhere',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.crimsonText(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // HTML STRUCTURAL HEADINGS GENERATORS
  Widget _buildHeading2(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 2),
        child: Row(
          children: [
            Container(
              width: 3.5,
              height: 16,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: cs.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading3(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHeading4(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.crimsonText(
        color: cs.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildContentContainer(BuildContext context, {required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildFeatureParagraph(BuildContext context, String text) {
    return Text(
      text,
      style: GoogleFonts.crimsonText(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15.5,
        height: 1.5,
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: GoogleFonts.crimsonText(color: cs.onSurfaceVariant, fontSize: 16)),
          Text(value, style: GoogleFonts.crimsonText(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
