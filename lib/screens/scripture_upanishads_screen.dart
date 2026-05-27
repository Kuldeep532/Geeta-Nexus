import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/scripture_service.dart';
import '../theme.dart';
// Note: Upanishad verses shown as read-only cards without audio narration per directive.

class ScriptureUpanishadsScreen extends StatelessWidget {
  final String name;
  final List<UpanishadVerseData> verses;

  const ScriptureUpanishadsScreen({
    super.key,
    required this.name,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        title: Text(name, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final v = verses[index];
          return Card(
            color: theme.cardColor,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verse ${index + 1}', style: GoogleFonts.cinzel(color: kSaffron)),
                  const SizedBox(height: 8),
                  Text(v.verseText, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 6),
                  Text(v.translation, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
