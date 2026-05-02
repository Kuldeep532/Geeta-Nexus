import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../data/gita_data.dart';
import '../models/models.dart';

class GeetaNexusMediaScreen extends StatefulWidget {
  const GeetaNexusMediaScreen({super.key});

  @override
  State<GeetaNexusMediaScreen> createState() => _GeetaNexusMediaScreenState();
}

class _GeetaNexusMediaScreenState extends State<GeetaNexusMediaScreen> with SingleTickerProviderStateMixin {
  static const _defaultIdentifier = 'shrimad-bhagavad-gita-hindi-audiobook';

  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _audioSearchController = TextEditingController();
  final TextEditingController _verseSearchController = TextEditingController();

  late final TabController _tabController;

  List<_ArchiveTrack> _tracks = const [];
  _ArchiveTrack? _selectedTrack;
  String _activeIdentifier = _defaultIdentifier;
  List<Verse> _verseResults = const [];

  String _shloka = "धृतराष्ट्र उवाच |\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |";
  String _translation = "Loading scripture media...";
  String? _audioError;
  bool _isLoading = true;
  bool _isSearchingAudio = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMediaNexus();
  }

  Future<void> _initializeMediaNexus() async {
    try {
      await _fetchVerseData(1, 1);
      await _loadAudioLibrary(_defaultIdentifier);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchVerseData(int ch, int v) async {
    final url = Uri.parse('https://bhagavadgitaapi.in/slok/$ch/$v/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _shloka = (data['slok'] as String?) ?? _shloka;
          _translation = (data['hindi'] as String?) ?? "Translation not available";
        });
      }
    } catch (e) {
      debugPrint("Verse Data Fetch Error: $e");
    }
  }

  Future<void> _loadAudioLibrary(String identifier) async {
    identifier = identifier.trim();
    if (identifier.isEmpty) {
      if (!mounted) return;
      setState(() => _audioError = 'Please enter a valid audio identifier.');
      return;
    }

    final metadataUrl = Uri.parse('https://archive.org/metadata/$identifier');
    if (mounted) {
      setState(() {
        _audioError = null;
        _tracks = const [];
        _selectedTrack = null;
      });
    }

    try {
      final response = await http.get(metadataUrl);
      if (response.statusCode != 200) {
        throw Exception('Metadata not found (${response.statusCode})');
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final files = (body['files'] as List<dynamic>? ?? const []);
      final tracks = files.whereType<Map<String, dynamic>>().map((file) {
        final name = file['name'] as String?;
        if (name == null) return null;
        final lowerName = name.toLowerCase();
        final format = (file['format'] as String?)?.toLowerCase() ?? '';
        if (!(lowerName.endsWith('.mp3') || format.contains('mp3'))) return null;
        final title = (file['title'] as String?)?.trim();
        return _ArchiveTrack(
          title: (title == null || title.isEmpty) ? name : title,
          url: 'https://archive.org/download/$identifier/$name',
        );
      }).whereType<_ArchiveTrack>().toList();

      if (tracks.isEmpty) {
        throw Exception('No MP3 files found');
      }

      if (!mounted) return;
      setState(() {
        _activeIdentifier = identifier;
        _tracks = tracks;
        _selectedTrack = tracks.first;
      });
      await _setTrack(tracks.first, autoPlay: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _audioError = 'Unable to load playable audio. Try another search.';
      });
      debugPrint('Audio Library Load Error: $e');
    }
  }

  Future<void> _setTrack(_ArchiveTrack track, {required bool autoPlay}) async {
    try {
      await _player.setUrl(track.url);
      if (!mounted) return;
      setState(() {
        _selectedTrack = track;
        _audioError = null;
      });
      if (autoPlay) await _player.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _audioError = 'Track failed to play. Choose another track.');
    }
  }

  Future<void> _searchAndLoadAudio() async {
    final query = _audioSearchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearchingAudio = true);
    final searchUrl = Uri.parse(
      'https://archive.org/advancedsearch.php?q=${Uri.encodeQueryComponent(query)}+AND+mediatype%3Aaudio&fl%5B%5D=identifier&rows=10&page=1&output=json',
    );

    try {
      final response = await http.get(searchUrl);
      if (response.statusCode != 200) throw Exception('Search failed');

      final data = json.decode(response.body) as Map<String, dynamic>;
      final docs = ((data['response'] as Map<String, dynamic>?)?['docs'] as List<dynamic>? ?? const []);
      final identifiers = docs
          .whereType<Map<String, dynamic>>()
          .map((doc) => doc['identifier'] as String?)
          .whereType<String>();

      var loaded = false;
      for (final id in identifiers) {
        await _loadAudioLibrary(id);
        if (_tracks.isNotEmpty) {
          loaded = true;
          break;
        }
      }

      if (!loaded && mounted) {
        setState(() => _audioError = 'No playable audio found for "$query".');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _audioError = 'Audio search failed. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isSearchingAudio = false);
    }
  }

  void _searchVerses(String query) {
    if (query.trim().isEmpty) {
      setState(() => _verseResults = const []);
      return;
    }
    setState(() => _verseResults = searchVerses(query));
  }

  void _selectVerse(Verse verse) {
    setState(() {
      _shloka = verse.sanskrit;
      _translation = verse.translation;
      _tabController.index = 0;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioSearchController.dispose();
    _verseSearchController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXUS MEDIA PLAYER'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.play_circle), text: 'Player'),
            Tab(icon: Icon(Icons.library_music), text: 'Audio'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPlayerTab(theme),
                _buildAudioSelectorTab(theme),
                _buildSearchTab(theme),
              ],
            ),
    );
  }

  Widget _buildPlayerTab(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(_shloka, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                  const Divider(height: 28),
                  Text(_translation, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ),
        _buildCommonPlayerControls(theme),
      ],
    );
  }

  Widget _buildAudioSelectorTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _audioSearchController,
                  decoration: const InputDecoration(
                    hintText: 'Search audio collection',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _searchAndLoadAudio(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSearchingAudio ? null : _searchAndLoadAudio,
                child: _isSearchingAudio ? const Text('...') : const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_tracks.isNotEmpty)
            DropdownButtonFormField<_ArchiveTrack>(
              value: _selectedTrack,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Tracks ($_activeIdentifier)',
              ),
              items: _tracks
                  .map((track) => DropdownMenuItem(value: track, child: Text(track.title, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (track) {
                if (track != null) _setTrack(track, autoPlay: true);
              },
            ),
          if (_audioError != null) ...[
            const SizedBox(height: 12),
            Text(_audioError!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          _buildCommonPlayerControls(theme),
        ],
      ),
    );
  }

  Widget _buildSearchTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _verseSearchController,
            onChanged: _searchVerses,
            decoration: InputDecoration(
              hintText: 'Search Gita text and tap to load in player',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _verseSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _verseSearchController.clear();
                        _searchVerses('');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: _verseResults.isEmpty
              ? const Center(child: Text('No verse selected. Search to load verse in player.'))
              : ListView.builder(
                  itemCount: _verseResults.length,
                  itemBuilder: (context, i) {
                    final verse = _verseResults[i];
                    return ListTile(
                      title: Text('Chapter ${verse.chapter}, Verse ${verse.verse}'),
                      subtitle: Text(verse.translation, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => _selectVerse(verse),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCommonPlayerControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        children: [
          StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, durationSnapshot) {
              final duration = durationSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  final clamped = position > duration && duration > Duration.zero ? duration : position;
                  return ProgressBar(
                    progress: clamped,
                    total: duration,
                    onSeek: _player.seek,
                    progressBarColor: theme.colorScheme.primary,
                    baseBarColor: theme.colorScheme.onSurface.withOpacity(0.1),
                    thumbColor: theme.colorScheme.primary,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: () => _player.seek(_safeRewind(_player.position)), icon: const Icon(Icons.replay_10)),
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return IconButton(
                    iconSize: 64,
                    onPressed: () => playing ? _player.pause() : _player.play(),
                    icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  );
                },
              ),
              IconButton(
                onPressed: () => _player.seek(_safeForward(_player.position, _player.duration ?? Duration.zero)),
                icon: const Icon(Icons.forward_10),
              ),
            ],
          )
        ],
      ),
    );
  }

  Duration _safeRewind(Duration current) {
    final target = current - const Duration(seconds: 10);
    return target.isNegative ? Duration.zero : target;
  }

  Duration _safeForward(Duration current, Duration total) {
    final target = current + const Duration(seconds: 10);
    if (total == Duration.zero) return target;
    return target > total ? total : target;
  }
}

class _ArchiveTrack {
  const _ArchiveTrack({required this.title, required this.url});

  final String title;
  final String url;
}
