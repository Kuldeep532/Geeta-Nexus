import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; // FIX 1: Required for SemanticsService
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// FIX 2: Ensure these files only export what is needed. 
// If kGold/kBg are defined in theme.dart, do not import other screens here.
import '../theme.dart'; 
import '../state/app_state.dart';

const int kMalaBeads = 108;

class ChantsScreen extends StatefulWidget {
  const ChantsScreen({super.key});

  @override
  State<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends State<ChantsScreen> {
  int _selectedMantraIndex = 0;
  late Future<List<Map<String, String>>> _mantraFuture;

  final List<Map<String, String>> _localMantras = const [
    {
      'name': 'Mahamantra',
      'mantra': 'Hare Krishna Hare Krishna Krishna Krishna Hare Hare, Hare Rama Hare Rama Rama Rama Hare Hare',
      'meaning': 'A prayer to the Divine Energy for universal peace and consciousness.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _mantraFuture = _fetchOnlineMantras();
  }

  Future<List<Map<String, String>>> _fetchOnlineMantras() async {
    final url = Uri.parse('https://havyaka-rest-api-gaonkarbhai.vercel.app/api/v1/mantras?limit=100');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['mantras'];
        return list.map((m) => {
          'name': m['name']?.toString() ?? 'Unknown',
          'mantra': m['shloka']?.toString() ?? '',
          'meaning': (m['purpose'] ?? m['benefits'] ?? 'Sacred Chant').toString(),
        }).toList();
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return _localMantras;
  }

  void _incrementChant(AppState state) {
    HapticFeedback.mediumImpact();
    state.incrementJapa();
  }

  void _resetChant(AppState state) {
    HapticFeedback.heavyImpact();
    state.resetJapa();
    // This now works because of the rendering.dart import
    SemanticsService.announce("Counter reset to zero", Directionality.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final japa = appState.japaCount;
    final rounds = japa ~/ kMalaBeads;
    final inRound = japa % kMalaBeads;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Japa & Chants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Japa",
            onPressed: () => _resetChant(appState),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _mantraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kGold));
          }

          final mantras = snapshot.data ?? _localMantras;
          if (_selectedMantraIndex >= mantras.length) _selectedMantraIndex = 0;
          final mantra = mantras[_selectedMantraIndex];

          return SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  // Ensure the screen is scrollable but handles space well
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSelector(mantras),
                          const SizedBox(height: 20),
                          _buildMantraCard(mantra),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          _buildCounterDisplay(japa, rounds),
                          const SizedBox(height: 24),
                          _buildProgress(inRound),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _incrementChant(appState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGold,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('ADD CHANT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildSelector(List<Map<String, String>> mantras) {
    return Wrap(
      spacing: 8,
      children: List.generate(mantras.length, (i) {
        return ChoiceChip(
          label: Text(mantras[i]['name']!),
          selected: _selectedMantraIndex == i,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedMantraIndex = i);
              SemanticsService.announce("Selected ${mantras[i]['name']}", Directionality.of(context));
            }
          },
        );
      }),
    );
  }

  Widget _buildMantraCard(Map<String, String> m) {
    return Semantics(
      container: true,
      label: "Current Mantra: ${m['name']}",
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(m['name']!, style: GoogleFonts.cinzel(color: kGold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(m['mantra']!, textAlign: TextAlign.center, style: GoogleFonts.notoSans(fontSize: 20)),
            const SizedBox(height: 15),
            Text(m['meaning']!, textAlign: TextAlign.center, style: GoogleFonts.crimsonText(fontSize: 16, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterDisplay(int total, int rounds) {
    return Semantics(
      label: "Total count $total, Rounds finished $rounds",
      child: Column(
        children: [
          Text('$total', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kGold)),
          Text('Total Chants', style: TextStyle(color: kGold.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text('Rounds: $rounds', style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildProgress(int count) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: count / kMalaBeads,
          backgroundColor: kCard,
          color: kGold,
          minHeight: 12,
        ),
        const SizedBox(height: 8),
        Text('$count / $kMalaBeads Beads', style: const TextStyle(fontWeight: FontWeight.bold, color: kGold)),
      ],
    );
  }
}
