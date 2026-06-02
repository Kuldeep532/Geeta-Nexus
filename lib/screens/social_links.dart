import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google fonts integrated for dynamic icons
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

// Font Awesome ka import completely removed taaki enterprise build fail na ho

const String kInstagramUrl =
    'https://www.instagram.com/_kuldeep_kumar_yadav';
const String kFacebookUrl = 'https://www.facebook.com/kuldeep849';
const String kLinkedInUrl =
    'https://www.linkedin.com/in/kuldeep-kumar-yadav-36042421b';
const String kContactEmail = 'kuldeepky538@gmail.com';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class SocialLinksRow extends StatelessWidget {
  const SocialLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _IconBtn(
          iconName: 'photo_camera', // Material Symbol name for Instagram alternative
          color: const Color(0xFFE1306C),
          tooltip: 'Instagram',
          onTap: () => openUrl(kInstagramUrl),
        ),
        const SizedBox(width: 16),
        _IconBtn(
          iconName: 'facebook', // Material Symbol name for Facebook
          color: const Color(0xFF1877F2),
          tooltip: 'Facebook',
          onTap: () => openUrl(kFacebookUrl),
        ),
        const SizedBox(width: 16),
        _IconBtn(
          iconName: 'business_center', // Material Symbol name for LinkedIn alternative
          color: const Color(0xFF0A66C2),
          tooltip: 'LinkedIn',
          onTap: () => openUrl(kLinkedInUrl),
        ),
        const SizedBox(width: 16),
        _IconBtn(
          iconName: 'mail', // Material Symbol name for Envelope/Email
          color: kGold,
          tooltip: 'Email',
          onTap: () => openUrl('mailto:$kContactEmail'),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final String iconName; // Changed from IconData to String to match Google Fonts lookup
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.iconName,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kCard,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          // Replaced FaIcon with dynamic Text-based Material Symbols using Google Fonts
          child: Text(
            iconName,
            textDirection: TextDirection.ltr,
            style: GoogleFonts.materialSymbolsOutlined(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
