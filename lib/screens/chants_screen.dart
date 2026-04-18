import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../state/app_state.dart';

class ChantsScreen extends StatefulWidget {
  const ChantsScreen({super.key});

  @override
  State<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends State<ChantsScreen> {
  bool _isInitialized = false;
  int _selectedMantraIndex = 0;

  final List<Map<String, String>> _mantras = [
    {
      'name': 'Hare Krishna Mahamantra',
      'mantra': 'Hare Krishna Hare Krishna\nKrishna Krishna Hare Hare\nHare Rama Hare Rama\nRama Rama Hare Hare',
      'meaning': 'A call to the divine energies of Vishnu. Purifies the mind and awakens devotion.',
    },
    {
      'name': 'Om Namah Shivaya',
      'mantra': 'Om Namah Shivaya',
      'meaning': 'I bow to the inner self. Invokes universal consciousness.',
    },
    {
      'name': 'Gayatri Mantra',
      'mantra': 'Om Bhur Bhuvah Svah\nTat Savitur Varenyam\nBhargo Devasya Dhimahi\nDhiyo Yo Nah Prachodayat',
      'meaning': 'Meditating on the divine light to illuminate our intellect.',
    },
    {
      'name': 'So Ham',
      'mantra': 'So Ham',
      'meaning': '"I am That" — identifying the individual breath with the cosmic soul.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupJapa();
  }

  Future<void> _setupJapa() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCount = prefs.getInt('japaCount') ?? 0;
    if (mounted) {
      context.read<AppState>().setJapaCount(savedCount);
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _updateAndSave(AppState state) async {
    state.incrementJapa();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('japaCount', state.japaCount);
  }

  @override
  Widget build(BuildContext context) {
    // If data isn't loaded yet, show a loader to prevent logic errors
    if (!_isInitialized) {
      return const Scaffold(backgroundColor: kBg, body: Center(child: CircularProgressIndicator(color: kGold)));
    }

    final state = context.watch<AppState>();
    final japa = state.japaCount;
    final roundsComplete = japa ~/ 108;
    final inRound = japa % 108;
    final currentMantra = _mantras[_selectedMantraIndex];

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
            const SizedBox(height: 32),
            _buildCounterSection(state, japa, roundsComplete),
            const SizedBox(height: 32),
            _buildProgressBar(inRound),
          ],
        ),
      ),
    );
  }

  Widget _buildMantraSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mantras.length,
        itemBuilder: (context, i) {
          final selected = _selectedMantraIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_mantras[i]['name']!),
              selected: selected,
              onSelected: (val) => setState(() => _selectedMantraIndex = i),
              selectedColor: kGold.withOpacity(0.2),
              backgroundColor: kCard,
              labelStyle: TextStyle(color: selected ? kGold : kTextDim, fontSize: 12),
              shape: StadiumBorder(side: BorderSide(color: selected ? kGold : kDivider)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMantraCard(Map<String, String> mantra) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kCard, const Color(0xFF1A1500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGoldDim.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(mantra['name']!.toUpperCase(),
              style: GoogleFonts.cinzel(color: kGold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Text(mantra['mantra']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(color: kGoldLight, fontSize: 18, height: 1.6, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Text(mantra['meaning']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(color: kTextDim, fontSize: 14, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildCounterSection(AppState state, int japa, int rounds) {
    return Column(
      children: [
        Semantics(
          label: "Total count $japa",
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: kCard,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: kGold.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)],
              border: Border.all(color: kGoldDim, width: 1),
            ),
            child: Column(
              children: [
                Text('$japa', style: GoogleFonts.cinzel(color: kGold, fontSize: 54, fontWeight: FontWeight.bold)),
                Text('CHANTS', style: GoogleFonts.cinzel(color: kTextDim, fontSize: 12, letterSpacing: 2)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('$rounds Malas Completed', style: const TextStyle(color: kGoldDim, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              icon: Icons.add,
              onTap: () {
                HapticFeedback.vibrate();
                _updateAndSave(state);
              },
              label: "Add chant",
            ),
            const SizedBox(width: 40),
            _buildCircleButton(
              icon: Icons.refresh,
              onTap: () => _confirmReset(state),
              label: "Reset counter",
              isSmall: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap, required String label, bool isSmall = false}) {
    double size = isSmall ? 60 : 90;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSmall ? Colors.transparent : kGold,
            border: isSmall ? Border.all(color: kDivider) : null,
            gradient: isSmall ? null : RadialGradient(colors: [kGold, kGoldDim]),
          ),
          child: Icon(icon, color: isSmall ? kTextDim : Colors.black, size: isSmall ? 24 : 40),
        ),
      ),
    );
  }

  void _confirmReset(AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title: Text('Reset Counter?', style: GoogleFonts.cinzel(color: kGold)),
        content: const Text('This will set your session and total count to zero.', style: TextStyle(color: kTextDim)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              state.resetJapa();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('japaCount', 0);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('RESET', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int inRound) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('MALA PROGRESS', style: TextStyle(color: kTextDim, fontSize: 10, letterSpacing: 1)),
            Text('$inRound / 108', style: const TextStyle(color: kGold, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: inRound / 108,
            backgroundColor: kDivider,
            color: kGold,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
