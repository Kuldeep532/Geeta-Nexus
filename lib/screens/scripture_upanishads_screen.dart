import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/scripture_service.dart';
import '../theme.dart';
import 'scripture_verse_detail_screen.dart'; // Master Player import

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
          
          // Note: Yahan hum Upanishad verse ko ScriptureVerse model mein convert kar sakte hain 
          // ya phir Master Player mein Upanishad support add kar sakte hain.
          return Semantics(
            button: true,
            label: 'Verse ${index + 1}. Double tap to read in detail.',
            child: Card(
              color: theme.cardColor,
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  // Yahan aap Master Player call kar sakte hain. 
                  // Agar Master Player sirf ScriptureVerse leta hai, 
                  // toh aapko ek chhota mapper function banana hoga.
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verse ${index + 1}', style: GoogleFonts.cinzel(color: kSaffron)),
                      const SizedBox(height: 8),
                      Text(v.verseText, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
