import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme.dart';
import '../state/app_state.dart';

const int kMalaBeads = 108;

/// Rich offline-first mantra list used when the remote API is unavailable.
const List<Map<String, String>> _kOfflineMantras = [
  {
    'name': 'Maha Mantra',
    'mantra':
        'Hare Krishna Hare Krishna\nKrishna Krishna Hare Hare\nHare Rama Hare Rama\nRama Rama Hare Hare',
    'meaning': 'Prayer for divine consciousness and liberation',
    'audio':
        'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
  },
  {
    'name': 'Gayatri Mantra',
    'mantra':
        'ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्',
    'meaning': 'Prayer to the Sun-God for divine intellect and spiritual light',
    'audio':
        'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
  },
  {
    'name': 'Om Namah Shivaya',
    'mantra': 'ॐ नमः शिवाय',
    'meaning': 'I bow to Lord Shiva — the auspicious one within all beings',
    'audio':
        'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
  },
  {
    'name': 'Om Namo Bhagavate',
    'mantra': 'ॐ नमो भगवते\nवासुदेवाय',
    'meaning': 'I bow to Lord Vasudeva — the all-pervading supreme person',
    'audio':
        'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
  },
  {
    'name': 'Shanti Mantra',
    'mantra':
        'ॐ सर्वे भवन्तु सुखिनः\nसर्वे सन्तु निरामयाः\nसर्वे भद्राणि पश्यन्तु\nमा कश्चिद् दुःखभाग्भवेत्',
    'meaning':
        'May all beings be happy, free from illness, and see auspiciousness',
    'audio':
        'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
  },
];

class ChantsScreen extends StatefulWidget {
  const ChantsScreen({super.key});

  @override
  State<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends State<ChantsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _isLoadingMantras = true;
  String? _mantraError;

  int _selectedIndex = 0;

  List<Map<String, dynamic>> _mantras = [];

  @override
  void initState() {
    super.initState();
    _loadMantras();
    WakelockPlus.enable();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _isPlaying = false);
    });
  }

  Future<bool> _hasConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      // connectivity_plus v6+ returns a List<ConnectivityResult>
      if (results is List) {
        return results.isNotEmpty &&
            !results.every((r) => r == ConnectivityResult.none);
      }
      return results != ConnectivityResult.none;
    } catch (_) {
      return true; // assume online if we can't check
    }
  }

  Future<void> _loadMantras() async {
    setState(() {
      _isLoadingMantras = true;
      _mantraError = null;
    });

    final online = await _hasConnection();

    if (!online) {
      _applyOfflineMantras();
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://havyaka-rest-api-gaonkarbhai.vercel.app/api/v1/mantras?limit=500',
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = (data['mantras'] ?? []) as List<dynamic>;

        if (list.isEmpty) {
          _applyOfflineMantras();
          return;
        }

        final parsed = list
            .map<Map<String, dynamic>>((m) => {
                  'name': (m['name'] ?? 'Unknown').toString(),
                  'mantra': (m['shloka'] ?? '').toString(),
                  'meaning':
                      (m['purpose'] ?? 'Sacred Mantra').toString(),
                  'audio': (m['audio'] ?? '').toString(),
                })
            .where((m) => m['mantra']!.toString().isNotEmpty)
            .toList();

        if (parsed.isEmpty) {
          _applyOfflineMantras();
          return;
        }

        if (mounted) {
          setState(() {
            _mantras = parsed;
            _isLoadingMantras = false;
          });
        }
      } else {
        _applyOfflineMantras();
      }
    } catch (_) {
      _applyOfflineMantras();
    }
  }

  void _applyOfflineMantras() {
    if (!mounted) return;
    setState(() {
      _mantras = _kOfflineMantras.cast<Map<String, dynamic>>();
      _isLoadingMantras = false;
      _selectedIndex = 0;
    });
  }

  Future<void> _playAudio(String url) async {
    if (url.isEmpty) {
      _showSnack('No audio available for this mantra.');
      return;
    }
    setState(() => _isLoadingAudio = true);
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      _showSnack('Audio playback failed. Check your connection. $e');
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  void _toggleAudio() {
    HapticFeedback.lightImpact();
    final url = (_mantras[_selectedIndex]['audio'] as String?) ?? '';
    if (_isPlaying) {
      _pauseAudio();
    } else {
      _playAudio(url);
    }
  }

  void _selectMantra(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    if (_isPlaying) {
      _audioPlayer.stop().then((_) {
        final url = (_mantras[index]['audio'] as String?) ?? '';
        _playAudio(url);
      });
    }
  }

  void _incrementChant(AppState state) {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    state.incrementJapa();
    if (state.japaCount % kMalaBeads == 0 && state.japaCount > 0) {
      HapticFeedback.heavyImpact();
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentBead = appState.japaCount % kMalaBeads;
    final rounds = appState.japaCount ~/ kMalaBeads;

    if (_isLoadingMantras) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Sacred Chants', style: GoogleFonts.cinzel()),
        ),
        body: Center(
          child: Semantics(
            label: 'Loading mantras, please wait.',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: kGold),
                const SizedBox(height: 16),
                Text('Loading mantras…',
                    style: GoogleFonts.poppins(color: kGoldDim)),
              ],
            ),
          ),
        ),
      );
    }

    final mantra = _mantras[_selectedIndex];
    final audioUrl = (mantra['audio'] as String?) ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: 'Sacred Chants screen.',
          child: Text('Sacred Chants', style: GoogleFonts.cinzel(color: kGold)),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Reset japa counter.',
            child: IconButton(
              tooltip: 'Reset counter',
              icon: const Icon(Icons.refresh_rounded, color: kGold),
              onPressed: () {
                HapticFeedback.lightImpact();
                appState.resetJapa();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Counter reset to zero'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Mantra selector chips
                  SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mantras.length,
                      itemBuilder: (_, index) {
                        final selected = _selectedIndex == index;
                        final name = _mantras[index]['name'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Semantics(
                            selected: selected,
                            label: '$name mantra. ${selected ? "Currently selected." : "Tap to select."}',
                            button: true,
                            child: ChoiceChip(
                              label: Text(name,
                                  style: GoogleFonts.poppins(fontSize: 12)),
                              selected: selected,
                              selectedColor: kGold,
                              onSelected: (_) => _selectMantra(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mantra card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: kGold.withOpacity(0.4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Semantics(
                            label: 'Mantra text: ${mantra['mantra']}.',
                            child: Text(
                              mantra['mantra'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 22, height: 1.7, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Meaning: ${mantra['meaning']}.',
                            child: Text(
                              mantra['meaning'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.5,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.65),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Audio control
                          Semantics(
                            button: true,
                            label: _isPlaying
                                ? 'Pause mantra audio.'
                                : 'Play mantra audio.',
                            child: GestureDetector(
                              onTap: _toggleAudio,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kGold,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kGold.withOpacity(0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _isLoadingAudio
                                    ? const Padding(
                                        padding: EdgeInsets.all(18),
                                        child: CircularProgressIndicator(
                                            color: Colors.black, strokeWidth: 2.5),
                                      )
                                    : Icon(
                                        _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.black,
                                        size: 32,
                                      ),
                              ),
                            ),
                          ),

                          if (audioUrl.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Audio not available for this mantra',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Rounds counter
                  Semantics(
                    container: true,
                    label: 'Japa rounds completed: $rounds.',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rounds: ',
                          style: GoogleFonts.cinzel(
                              fontSize: 18, color: kGoldDim),
                        ),
                        Text(
                          '$rounds',
                          style: GoogleFonts.cinzel(
                              fontSize: 28,
                              color: kGold,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mala circle
                  Semantics(
                    container: true,
                    label:
                        'Japa bead counter: $currentBead of $kMalaBeads.',
                    child: Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kGold, width: 4),
                          color: kGold.withOpacity(0.06),
                        ),
                        child: Center(
                          child: Text(
                            '$currentBead',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: kGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress bar
                  Semantics(
                    label:
                        'Japa progress: $currentBead out of $kMalaBeads beads.',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: currentBead / kMalaBeads,
                        minHeight: 10,
                        backgroundColor: kGold.withOpacity(0.12),
                        color: kGold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Manual chant button
                  Semantics(
                    button: true,
                    label: 'Chant button. Tap to count one bead.',
                    hint: 'Tap to increment your japa count.',
                    child: SizedBox(
                      width: double.infinity,
                      height: 72,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 3,
                          shadowColor: kGold.withOpacity(0.4),
                        ),
                        onPressed: () => _incrementChant(appState),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_rounded, size: 26),
                            const SizedBox(width: 10),
                            Text(
                              'CHANT',
                              style: GoogleFonts.cinzel(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),

      // Floating chant button for one-thumb reach
      floatingActionButton: Semantics(
        button: true,
        label: 'Quick chant button.',
        child: FloatingActionButton(
          heroTag: 'chants_fab',
          backgroundColor: kGold,
          foregroundColor: Colors.black,
          tooltip: 'Chant',
          onPressed: () => _incrementChant(appState),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
      ),
    );
  }
}
