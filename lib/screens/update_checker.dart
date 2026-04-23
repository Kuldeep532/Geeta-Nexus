import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'updates_screen.dart' show kDefaultUpdateFeedUrl;

/// Silently checks the remote update feed and shows a dialog if a newer
/// version is available. Designed to be called on app start.
Future<void> autoCheckForUpdates(BuildContext context) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final prefs = await SharedPreferences.getInstance();
    final feedUrl = prefs.getString('update_feed_url') ?? kDefaultUpdateFeedUrl;
    final lastSkipped = prefs.getString('update_skipped_version') ?? '';

    final res = await http
        .get(Uri.parse(feedUrl))
        .timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) return;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final latest = (data['version'] ?? '').toString();
    final notes = (data['notes'] ?? data['message'] ?? '').toString();
    final url = (data['url'] ?? data['downloadUrl'] ?? '').toString();
    if (latest.isEmpty) return;
    if (latest == lastSkipped) return;
    if (!_isNewer(latest, currentVersion)) return;

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.system_update, color: kGold),
            const SizedBox(width: 8),
            Text('Update available',
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version v$latest is now available.'),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(notes,
                  style: GoogleFonts.crimsonText(fontSize: 14, height: 1.4)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await prefs.setString('update_skipped_version', latest);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Later'),
          ),
          if (url.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.download, size: 18),
              onPressed: () async {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              label: const Text('Update Now'),
            ),
        ],
      ),
    );
  } catch (_) {
    // Silent failure — never block app startup on a network issue.
  }
}

bool _isNewer(String latest, String current) {
  List<int> parse(String v) => v
      .split('.')
      .map((p) => int.tryParse(p.replaceAll(RegExp(r'\D'), '')) ?? 0)
      .toList();
  final a = parse(latest);
  final b = parse(current);
  final n = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < n; i++) {
    final av = i < a.length ? a[i] : 0;
    final bv = i < b.length ? b[i] : 0;
    if (av > bv) return true;
    if (av < bv) return false;
  }
  return false;
}
