import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

const String kDefaultUpdateFeedUrl =
    'https://raw.githubusercontent.com/kuldeepkumar-yadav/geeta-ai-updates/main/updates.json';

const List<String> kNewFeatures = [
  'Adaptive reading mode with cleaner verse typography',
  'Google profile summary now visible in account section',
  'Time-aware greeting with spiritual context on Home',
  'Improved screen-reader labels for key Home and Profile areas',
  'Live app version display sourced from installed build metadata',
  'Notification stream with admin-only sender controls',
  'Automatic admin rights for kuldeepky538@gmail.com after Google sign-in',
  'Astrology section with local kundli and horoscope generator',
  'AI section accessibility upgrades for clearer persona and input controls',
<<<<<<< codex/add-google-login-option-fx4gi5
  'Daily Dharma audio player to listen to the day\'s sloka translation',
=======
>>>>>>> main
  'Update feed configuration remains available for instant release notes',
];

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _info;
  String _feedUrl = kDefaultUpdateFeedUrl;
  String _currentAppVersion = '3.5.0';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _feedUrl = prefs.getString('update_feed_url') ?? kDefaultUpdateFeedUrl;
      _currentAppVersion = packageInfo.version;
    });
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http
          .get(Uri.parse(_feedUrl))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw 'Server returned ${res.statusCode}';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      setState(() => _info = data);
    } catch (e) {
      setState(() => _error = 'Could not fetch updates: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
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

  Future<void> _editFeedUrl() async {
    final controller = TextEditingController(text: _feedUrl);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Update Feed URL', style: TextStyle(color: kGold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: kText),
          decoration: const InputDecoration(
            hintText: 'https://example.com/updates.json',
            hintStyle: TextStyle(color: kTextDim),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (newUrl != null && newUrl.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('update_feed_url', newUrl);
      setState(() => _feedUrl = newUrl);
      _check();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('App Updates'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Update feed URL',
            icon: const Icon(Icons.settings, color: kGold),
            onPressed: _editFeedUrl,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: kGold),
            onPressed: _check,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _versionCard(),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                      child: CircularProgressIndicator(color: kGold)),
                )
              else if (_error != null)
                _errorCard(_error!)
              else if (_info != null)
                _infoCard(_info!)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 20),
              _newFeaturesCard(),
              const SizedBox(height: 12),
              _howItWorksCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _versionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT VERSION',
              style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Text('v$_currentAppVersion',
              style: const TextStyle(
                  color: kText, fontSize: 22, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style:
                      const TextStyle(color: kTextDim, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _infoCard(Map<String, dynamic> info) {
    final latest = (info['version'] ?? '').toString();
    final notes = (info['notes'] ?? info['message'] ?? '').toString();
    final url = (info['url'] ?? info['downloadUrl'] ?? '').toString();
    final isNewer = latest.isNotEmpty && _isNewer(latest, _currentAppVersion);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNewer
              ? const [Color(0xFF2A2000), Color(0xFF1A1500)]
              : [kCard, kCard],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color:
                isNewer ? kGoldDim : kDivider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  isNewer
                      ? Icons.system_update
                      : Icons.check_circle_outline,
                  color: isNewer ? kGold : Colors.greenAccent),
              const SizedBox(width: 8),
              Text(
                isNewer ? 'Update available' : 'You are up to date',
                style: GoogleFonts.cinzel(
                    color: isNewer ? kGold : Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (latest.isNotEmpty)
            Text('Latest version: v$latest',
                style: const TextStyle(color: kText, fontSize: 14)),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('What\'s new',
                style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(notes,
                style: GoogleFonts.crimsonText(
                    color: kText, fontSize: 15, height: 1.5)),
          ],
          if (isNewer && url.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                onPressed: () => launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication),
                label: const Text('Download Update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  foregroundColor: kBg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _newFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEW FEATURES',
              style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1)),
          const SizedBox(height: 10),
          ...kNewFeatures.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle, color: kGoldDim, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(color: kText, fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _howItWorksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HOW UPDATES WORK',
              style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1)),
          const SizedBox(height: 8),
          const Text(
            'The app checks a small JSON file you host online (the "update feed"). '
            'Whenever you change that JSON to announce a new version or message, '
            'every user sees it instantly — no APK rebuild needed.\n\n'
            'Expected JSON shape:\n'
            '{ "version": "1.1.0", "notes": "What\'s new…", "url": "https://your-host/app.apk" }',
            style: TextStyle(color: kTextDim, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }
}
