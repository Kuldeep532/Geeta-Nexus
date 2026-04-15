import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/gita_data.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _query = '';
  String? _expanded;

  @override
  Widget build(BuildContext context) {
    final filtered = kGlossary.where((g) {
      if (_query.isEmpty) return true;
      return g['term']!.toLowerCase().contains(_query.toLowerCase()) ||
          g['meaning']!.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Sanskrit Glossary'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: kText),
              decoration: const InputDecoration(
                hintText: 'Search terms...',
                prefixIcon: Icon(Icons.search, color: kTextDim),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final g = filtered[i];
                final isExpanded = _expanded == g['term'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _expanded = isExpanded ? null : g['term']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isExpanded ? kGoldDim : kDivider,
                          width: isExpanded ? 1.5 : 1),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: kGold.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kGoldDim),
                                ),
                                child: Center(
                                  child: Text(
                                    g['term']![0],
                                    style: GoogleFonts.cinzel(
                                        color: kGold,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(g['term']!,
                                        style: GoogleFonts.cinzel(
                                            color: kGold,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                    if (!isExpanded)
                                      Text(
                                        g['meaning']!,
                                        style: const TextStyle(
                                            color: kTextDim, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: kTextDim,
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded)
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Text(
                              g['meaning']!,
                              style: GoogleFonts.crimsonText(
                                  color: kText, fontSize: 15, height: 1.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
