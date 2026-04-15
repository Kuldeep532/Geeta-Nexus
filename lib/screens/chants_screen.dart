import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';

class ChantsScreen extends StatefulWidget {
  const ChantsScreen({super.key});

  @override
  State<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends State<ChantsScreen> {
  final List<Map<String, String>> _mantras = [
    {
      'name': 'Hare Krishna Mahamantra',
      'mantra': 'Hare Krishna Hare Krishna\nKrishna Krishna Hare Hare\nHare Rama Hare Rama\nRama Rama Hare Hare',
      'meaning': 'A call to the divine energies of Vishnu. Regular chanting of this mantra purifies the mind and awakens devotion.',
    },
    {
      'name': 'Om Namah Shivaya',
      'mantra': 'ॐ नमः शिवाय\nOm Namah Shivaya',
      'meaning': 'I bow to Shiva — the inner self. This mantra invokes the universal consciousness.',
    },
    {
      'name': 'Gayatri Mantra',
      'mantra': 'ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्॥',
      'meaning': 'We meditate upon the divine light of the sun. May it illuminate our intellect and inspire our understanding.',
    },
    {
      'name': 'So\'Ham',
      'mantra': 'सोऽहम्\nSo\'Ham',
      'meaning': '"I am That" — the breath mantra. Inhale with "So" and exhale with "Ham" to realize your identity with the Divine.',
    },
    {
      'name': 'Om Shanti',
      'mantra': 'ॐ शान्तिः शान्तिः शान्तिः\nOm Shanti Shanti Shanti',
      'meaning': 'Peace to the body, mind, and spirit. Three repetitions invoke peace at all levels of existence.',
    },
  ];

  int _selectedMantraIndex = 0;
  int get _japaCount => context.read<AppState>().japaCount;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final japa = state.japaCount;
    final currentMantra = _mantras[_selectedMantraIndex];
    final roundsComplete = japa ~/ 108;
    final inRound = japa % 108;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Japa & Chants'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMantraSelector(),
            const SizedBox(height: 20),
            _buildMantraCard(currentMantra),
            const SizedBox(height: 24),
            _buildJapaCounter(state, japa, inRound, roundsComplete),
            const SizedBox(height: 24),
            _buildMalaProgress(inRound),
          ],
        ),
      ),
    );
  }

  Widget _buildMantraSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_mantras.length, (i) {
          final selected = _selectedMantraIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedMantraIndex = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? kGold.withOpacity(0.2) : kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? kGold : kDivider),
              ),
              child: Text(
                _mantras[i]['name']!.split(' ').take(2).join(' '),
                style: TextStyle(
                    color: selected ? kGold : kTextDim,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMantraCard(Map<String, String> mantra) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGoldDim.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            mantra['name']!,
            style: GoogleFonts.cinzel(
                color: kGold, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Text(
            mantra['mantra']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansDevanagari(
                color: kGoldLight, fontSize: 16, height: 1.8),
          ),
          const SizedBox(height: 14),
          Text(
            mantra['meaning']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.crimsonText(
                color: kTextDim, fontSize: 13, fontStyle: FontStyle.italic, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildJapaCounter(AppState state, int japa, int inRound, int rounds) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kCard,
            shape: BoxShape.circle,
            border: Border.all(color: kGoldDim, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$japa',
                style: GoogleFonts.cinzel(
                    color: kGold, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Text('Total Japa',
                  style: const TextStyle(color: kTextDim, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('$rounds malas completed (108 per mala)',
            style: const TextStyle(color: kTextDim, fontSize: 12)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                state.incrementJapa();
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF3A2A00), Color(0xFF2A1F00)],
                  ),
                  border: Border.all(color: kGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: kGold.withOpacity(0.3),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: const Icon(Icons.add, color: kGold, size: 36),
              ),
            ),
            const SizedBox(width: 24),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reset Count?'),
                    content: const Text(
                        'This will reset your japa counter to zero.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            state.resetJapa();
                            Navigator.pop(context);
                          },
                          child: const Text('Reset',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kTextDim,
                side: const BorderSide(color: kDivider),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMalaProgress(int inRound) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Mala Progress',
                  style: GoogleFonts.cinzel(
                      color: kGold, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$inRound / 108',
                  style: const TextStyle(color: kGoldDim, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: inRound / 108,
            backgroundColor: kDivider,
            color: kGold,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            inRound == 0
                ? 'Tap the button to begin your japa'
                : '${108 - inRound} beads left to complete this mala',
            style: const TextStyle(color: kTextDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
