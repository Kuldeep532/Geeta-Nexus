import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

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
          icon: FontAwesomeIcons.instagram,
          color: const Color(0xFFE1306C),
          tooltip: 'Instagram',
          onTap: () => openUrl(kInstagramUrl),
        ),
        const SizedBox(width: 16),
        _IconBtn(
          icon: FontAwesomeIcons.facebook,
          color: const Color(0xFF1877F2),
          tooltip: 'Facebook',
          onTap: () => openUrl(kFacebookUrl),
        ),
        const SizedBox(width: 16),
        _IconBtn(
          icon: FontAwesomeIcons.linkedin,
          color: const Color(0xFF0A66C2),
          tooltip: 'LinkedIn',
          onTap: () => openUrl(kLinkedInUrl),
        ),
        const SizedBox(width: 16),
        _IconBtn(
          icon: FontAwesomeIcons.envelope,
          color: kGold,
          tooltip: 'Email',
          onTap: () => openUrl('mailto:$kContactEmail'),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
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
          child: FaIcon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
