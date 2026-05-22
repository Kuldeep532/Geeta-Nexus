import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme.dart';
import '../state/app_state.dart';

const int kMalaBeads = 108;

class ChantsScreen extends StatefulWidget {
  const ChantsScreen({super.key});

  @override
  State<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends State<ChantsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isVoiceMode = false;
  bool _isPlaying = false;
  bool _isLoading = true;

  int _selectedIndex = 0;

  List<Map<String, dynamic>> _mantras = [];

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _loadMantras();
    WakelockPlus.enable();
  }

  Future<void> _initializeAudio() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'chants.audio.channel',
      androidNotificationChannelName: 'Chants Playback',
      androidNotificationOngoing: true,
    );
  }

  Future<void> _loadMantras() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();

      if (connectivity == ConnectivityResult.none) {
        _loadOfflineMantras();
        return;
      }

      final response = await http
          .get(
            Uri.parse(
              'https://havyaka-rest-api-gaonkarbhai.vercel.app/api/v1/mantras?limit=500',
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> list = data['mantras'];

        _mantras = list.map((m) {
          return {
            'name': m['name'] ?? 'Unknown',
            'mantra': m['shloka'] ?? '',
            'meaning': m['purpose'] ?? 'Sacred Mantra',
            'audio': m['audio'] ??
                'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
          };
        }).toList();
      } else {
        _loadOfflineMantras();
      }
    } catch (e) {
      _loadOfflineMantras();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadOfflineMantras() {
    _mantras = [
      {
        'name': 'Maha Mantra',
        'mantra':
            'Hare Krishna Hare Krishna Krishna Krishna Hare Hare Hare Rama Hare Rama Rama Rama Hare Hare',
        'meaning': 'Prayer for divine consciousness',
        'audio':
            'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
      },
    ];
  }

  Future<void> _playAudio() async {
    try {
      final mantra = _mantras[_selectedIndex];

      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: [
            AudioSource.uri(Uri.parse(mantra['audio'])),
          ],
        ),
      );

      await _audioPlayer.setLoopMode(LoopMode.all);

      await _audioPlayer.play();

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      _showError('Audio playback failed');
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();

    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _speakMeaning() async {
    final mantra = _mantras[_selectedIndex];

    await _tts.speak(
      mantra['meaning'] ?? 'No meaning available',
    );
  }

  Future<void> _toggleVoiceMode(AppState state) async {
    if (!_isVoiceMode) {
      bool available = await _speech.initialize();

      if (!available) {
        _showError('Speech recognition unavailable');
        return;
      }

      setState(() {
        _isVoiceMode = true;
      });

      _speech.listen(
        onResult: (result) {
          final spoken = result.recognizedWords.toLowerCase();

          final mantraName = _mantras[_selectedIndex]['name']
              .toString()
              .toLowerCase();

          final similarity =
              spoken.similarityTo(mantraName);

          if (similarity > 0.4) {
            _incrementChant(state);
          }
        },
      );
    } else {
      await _speech.stop();

      setState(() {
        _isVoiceMode = false;
      });
    }
  }

  void _incrementChant(AppState state) {
    HapticFeedback.mediumImpact();

    SystemSound.play(SystemSoundType.click);

    state.incrementJapa();

    if (state.japaCount % kMalaBeads == 0 &&
        state.japaCount > 0) {
      HapticFeedback.heavyImpact();

      _tts.speak('One round completed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _speech.stop();
    _tts.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final gold = kGold;

    final currentBead =
        appState.japaCount % kMalaBeads;

    final rounds =
        appState.japaCount ~/ kMalaBeads;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Semantics(
            label: 'Loading mantras',
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    final mantra = _mantras[_selectedIndex];

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Accessible Japa',
          style: GoogleFonts.cinzel(),
        ),

        actions: [
          Semantics(
            label: 'Reset counter',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                appState.resetJapa();
              },
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: FocusTraversalGroup(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount: _mantras.length,
                          itemBuilder: (context, index) {
                            final selected =
                                _selectedIndex ==
                                    index;

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                right: 8,
                              ),
                              child: Semantics(
                                label:
                                    _mantras[index]
                                        ['name'],
                                selected: selected,
                                child: ChoiceChip(
                                  label: Text(
                                    _mantras[index]
                                        ['name'],
                                  ),
                                  selected:
                                      selected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedIndex =
                                          index;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                          side: BorderSide(
                            color: gold,
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            20,
                          ),
                          child: Column(
                            children: [
                              Semantics(
                                label:
                                    'Current mantra',
                                child: Text(
                                  mantra['mantra'],
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style:
                                      GoogleFonts
                                          .notoSansDevanagari(
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              Text(
                                mantra['meaning'],
                                textAlign:
                                    TextAlign.center,
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons
                                              .pause
                                          : Icons
                                              .play_arrow,
                                    ),
                                    onPressed: () {
                                      if (_isPlaying) {
                                        _pauseAudio();
                                      } else {
                                        _playAudio();
                                      }
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.volume_up,
                                    ),
                                    onPressed:
                                        _speakMeaning,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Semantics(
                        label:
                            'Current bead count',
                        value:
                            '$currentBead completed',
                        child: Column(
                          children: [
                            Text(
                              'Rounds: $rounds',
                              style: TextStyle(
                                fontSize: 22,
                                color: gold,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            Container(
                              width: 180,
                              height: 180,
                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape.circle,
                                border:
                                    Border.all(
                                  color: gold,
                                  width: 5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$currentBead',
                                  style:
                                      const TextStyle(
                                    fontSize: 50,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Semantics(
                        label:
                            'Chant progress',
                        value:
                            '$currentBead out of $kMalaBeads',
                        child:
                            LinearProgressIndicator(
                          value:
                              currentBead /
                                  kMalaBeads,
                          minHeight: 12,
                          color: gold,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Semantics(
                        label:
                            'Manual chant button',
                        hint:
                            'Tap to increase chant count',
                        button: true,
                        child: SizedBox(
                          width: double.infinity,
                          height: 70,
                          child:
                              ElevatedButton.icon(
                            icon: const Icon(
                              Icons.add,
                            ),
                            label: const Text(
                              'CHANT',
                            ),
                            onPressed: () {
                              _incrementChant(
                                  appState);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _toggleVoiceMode(appState);
        },
        label: Text(
          _isVoiceMode
              ? 'Listening'
              : 'Voice Mode',
        ),
        icon: Icon(
          _isVoiceMode
              ? Icons.mic
              : Icons.mic_none,
        ),
      ),
    );
  }
}
