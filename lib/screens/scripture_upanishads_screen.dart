import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/scripture_service.dart';
import '../theme.dart';

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
        title: Semantics(
          header: true,
          child: Text(
            name,
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Semantics(
        label: '$name Upanishad, ${verses.length} verses',
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final v = verses[index];
            final hasText = v.verseText.trim().isNotEmpty;
            final hasTrans = v.translation.trim().isNotEmpty;

            return Semantics(
              container: true,
              label: 'Verse ${index + 1}.'
                  '${hasText ? " Sanskrit: ${v.verseText.replaceAll('\n', ' ')}." : ""}'
                  '${hasTrans ? " Translation: ${v.translation}." : ""}',
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kSaffron.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSaffron.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Verse ${index + 1}',
                          style: GoogleFonts.cinzel(fontSize: 11, color: kSaffron, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (hasText) ...[
                      const SizedBox(height: 10),
                      ExcludeSemantics(
                        child: Text(
                          v.verseText.trim(),
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            height: 1.8,
                            fontStyle: FontStyle.italic,
                            color: isDark ? kText : null,
                          ),
                        ),
                      ),
                    ],
                    if (hasTrans) ...[
                      const Divider(height: 20, color: kDivider),
                      ExcludeSemantics(
                        child: Text(
                          v.translation.trim(),
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            height: 1.6,
                            color: isDark ? kTextDim : null,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
