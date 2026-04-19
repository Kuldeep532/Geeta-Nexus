import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  final List<Map<String, String>> _mantras = const [
    {
      'name': 'Hare Krishna Mahamantra',
      'mantra':
          'Hare Krishna Hare Krishna\nKrishna Krishna Hare Hare\nHare Rama Hare Rama\nRama Rama Hare Hare',
      'meaning':
          'A call to the divine energies of Vishnu. Purifies the mind and awakens devotion.',
    },
    {
      'name': 'Om Namah Shivaya',
      'mantra': 'Om Namah Shivaya',
      'meaning':
          'I bow to the inner self. Invokes universal consciousness.',
    },
    {
      'name': 'Gayatri Mantra',
      'mantra':
          'Om Bhur Bhuvah Svah\nTat Savitur Varenyam\nBhargo Devasya Dhimahi\nDhiyo Yo Nah Prachodayat',
      'meaning':
          'Meditating on the divine light to illuminate our intellect.',
    },
    {
      'name': 'So Ham',
      'mantra': 'So Ham',
      'meaning':
          '"I am That" — identifying the individual breath with the cosmic soul.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final japa = context.select<AppState, int>((s) => s.japaCount);
    final rounds = japa ~/ kMalaBeads;
    final inRound = japa % kMalaBeads;
    final mantra = _mantras[_selectedMantraIndex];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Japa & Chants'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight( // ✅ FIXED: layout ambiguity
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSelector(),
                      const SizedBox(height: 20),
                      _buildMantraCard(mantra),
                      const SizedBox(height: 24),
                      _buildCounter(japa, rounds),
                      const SizedBox(height: 24),
                      _buildProgress(inRound),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------- SELECTOR ----------------

  Widget _buildSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_mantras.length, (i) {
        final selected = i == _selectedMantraIndex;

        return ChoiceChip(
          label: Text(
            _mantras[i]['name']!,
            overflow: TextOverflow.ellipsis,
          ),
          selected: selected,
          onSelected: (_) {
            setState(() => _selectedMantraIndex = i);

            SemanticsService.announce(
              '${_mantras[i]['name']} selected',
              Directionality.of(context),
            );
          },
        );
      }),
    );
  }

  // ---------------- MANTRA CARD ----------------

  Widget _buildMantraCard(Map<String, String> m) {
    return Semantics(
      container: true,
      label: '${m['name']}. ${m['meaning']}',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              m['name']!,
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              m['mantra']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              m['meaning']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- COUNTER ----------------

  Widget _buildCounter(int japa, int rounds) {
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          label: 'Total chants $japa',
          child: Text(
            '$japa',
            style: GoogleFonts.cinzel(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: kGold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('$rounds malas completed'),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            _button(
              icon: Icons.add,
              label: 'Add chant',
              onTap: () {
                final state = context.read<AppState>(); // ✅ moved here
                HapticFeedback.mediumImpact();

                state.incrementJapa();

                final updated = state.japaCount; // ✅ FIXED state lag

                SemanticsService.announce(
                  'Chant added. Total $updated',
                  Directionality.of(context),
                );
              },
            ),
            _button(
              icon: Icons.refresh,
              label: 'Reset counter',
              onTap: () {
                final state = context.read<AppState>(); // ✅ moved here
                _resetDialog(state);
              },
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- BUTTON ----------------

  Widget _button({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 72,
      height: 72,
      child: ElevatedButton(
        onPressed: onTap,
        child: Icon(icon, semanticLabel: label),
      ),
    );
  }

  // ---------------- RESET ----------------

  void _resetDialog(AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Counter?'),
        content: const Text('This will clear your count.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              state.resetJapa();
              Navigator.pop(context);

              SemanticsService.announce(
                'Counter reset to zero',
                Directionality.of(context),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // ---------------- PROGRESS ----------------

  Widget _buildProgress(int inRound) {
    return Semantics(
      label: 'Progress $inRound of $kMalaBeads',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress: $inRound / $kMalaBeads'),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: inRound / kMalaBeads,
          ),
        ],
      ),
    );
  }
}
