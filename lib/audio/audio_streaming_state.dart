import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/audio_source.dart';
import 'media_session.dart';

/// Replit-optimized streaming audio state for Bhagavad Gita chapter narrations.
/// Designed for cloud IDE deployment with efficient memory management and
/// aggressive disposal of audio resources to prevent Replit container leaks.
///
/// Uses a single AudioPlayer instance (no pooling) to minimize memory footprint.
/// Stream subscriptions are cancelled on disposal; all listeners are weakly held.
class AudioStreamingState extends ChangeNotifier {
  // Single player instance — kept lightweight for Replit
  final AudioPlayer _player = AudioPlayer();

  // ── State fields ──
  int? _currentChapterNumber;
  AudioSource? _currentSource;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _initialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Public getters ──
  int? get currentChapterNumber => _currentChapterNumber;
  AudioSource? get currentSource => _currentSource;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasTrack => _currentChapterNumber != null && _currentSource != null;

  double get progress => _duration.inMilliseconds > 0
      ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;

  String get currentTitle =>
      _currentChapterNumber != null ? 'Chapter $_currentChapterNumber' : '';

  String get currentSourceName => _currentSource?.name ?? '';
  String get currentLanguage => _currentSource?.language.shortName ?? '';

  // ── Internal subscriptions (cancelled on dispose) ──
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completionSub;

  // ── Lifecycle ──

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Subscribe to player events — store subscriptions for cancellation
    _playerStateSub = _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _syncMediaSession();
      notifyListeners();
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      _duration = d;
      _syncMediaSession();
      notifyListeners();
    });

    _positionSub = _player.onPositionChanged.listen((p) {
      _position = p;
      _syncMediaSession();
      notifyListeners();
    });

    _completionSub = _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      MediaSessionService.setPlaybackState('none');
      notifyListeners();
    });
  }

  /// Stream a chapter from the given audio source.
  /// Tries primary URL first, then fallback if available.
  Future<void> play(int chapterNumber, AudioSource source) async {
    _currentChapterNumber = chapterNumber;
    _currentSource = source;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Update Media Session metadata
    MediaSessionService.setMetadata(
      title: 'Chapter $chapterNumber',
      artist: source.name,
      album: 'Bhagavad Gita • ${source.language.shortName}',
    );
    _registerMediaSessionHandlers();

    // Try primary URL
    final primaryUrl = source.urlForChapter(chapterNumber);
    try {
      await _player.play(UrlSource(primaryUrl));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('AudioStreamingState: primary failed \u2014 $e');

      // Try fallback URL
      final fallback = source.fallbackUrlForChapter(chapterNumber);
      if (fallback != null) {
        try {
          await _player.play(UrlSource(fallback));
          _isLoading = false;
          notifyListeners();
          return;
        } catch (fallbackError) {
          debugPrint('AudioStreamingState: fallback also failed \u2014 $fallbackError');
        }
      }

      _isLoading = false;
      _errorMessage = 'Audio stream failed. Please check your connection.';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('AudioStreamingState pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.resume();
    } catch (e) {
      debugPrint('AudioStreamingState resume error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('AudioStreamingState stop error: $e');
    }
    _position = Duration.zero;
    MediaSessionService.setPlaybackState('none');
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await pause();
    } else if (hasTrack) {
      await resume();
    }
  }

  Future<void> seekTo(Duration pos) async {
    try {
      await _player.seek(pos);
    } catch (e) {
      debugPrint('AudioStreamingState seek error: $e');
    }
  }

  Future<void> rewind() async {
    final target = _position - const Duration(seconds: 10);
    await seekTo(target.isNegative ? Duration.zero : target);
  }

  Future<void> fastForward() async {
    final target = _position + const Duration(seconds: 10);
    await seekTo(target > _duration ? _duration : target);
  }

  Future<void> nextChapter() async {
    if (_currentChapterNumber == null || _currentChapterNumber! >= 18) return;
    final source = _currentSource ?? kAudioSources.first;
    await play(_currentChapterNumber! + 1, source);
  }

  Future<void> prevChapter() async {
    if (_currentChapterNumber == null || _currentChapterNumber! <= 1) return;
    final source = _currentSource ?? kAudioSources.first;
    await play(_currentChapterNumber! - 1, source);
  }

  bool get canGoNext =>
      _currentChapterNumber != null && _currentChapterNumber! < 18;
  bool get canGoPrev =>
      _currentChapterNumber != null && _currentChapterNumber! > 1;

  // ── Media Session helpers ──

  void _syncMediaSession() {
    if (_duration.inSeconds > 0) {
      MediaSessionService.setPositionState(
        durationSeconds: _duration.inSeconds.toDouble(),
        positionSeconds: _position.inSeconds.toDouble(),
      );
    }
    MediaSessionService.setPlaybackState(
      _isPlaying ? 'playing' : 'paused',
    );
  }

  void _registerMediaSessionHandlers() {
    MediaSessionService.setActionHandlers(
      onPlay: () => resume(),
      onPause: () => pause(),
      onStop: () => stop(),
      onPreviousTrack: canGoPrev ? () => prevChapter() : null,
      onNextTrack: canGoNext ? () => nextChapter() : null,
      onSeekBackward: () => rewind(),
      onSeekForward: () => fastForward(),
      onSeekTo: (seconds) => seekTo(Duration(seconds: seconds.round())),
    );
  }

  // ── Replit-optimized disposal ──
  /// Aggressively dispose all resources to prevent Replit container leaks.
  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completionSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
