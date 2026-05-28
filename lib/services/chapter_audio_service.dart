import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Pre-recorded chapter narration audio service with multiple reciters.
class ChapterAudioService {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  PlayerState _state = PlayerState.stopped;
  bool get isPlaying => _state == PlayerState.playing;
  bool get isPaused => _state == PlayerState.paused;
  bool get isStopped => _state == PlayerState.stopped;

  Duration get duration => _duration;
  Duration get position => _position;
  double get progress =>
      _duration.inMilliseconds > 0
          ? _position.inMilliseconds / _duration.inMilliseconds
          : 0.0;

  final StreamController<AudioStatus> _statusController =
      StreamController<AudioStatus>.broadcast();
  Stream<AudioStatus> get statusStream => _statusController.stream;

  void initialize() {
    _player.onPlayerStateChanged.listen((s) {
      _state = s;
      _statusController.add(AudioStatus(state: s, position: _position, duration: _duration));
    });
    _player.onDurationChanged.listen((d) {
      _duration = d;
      _statusController.add(AudioStatus(state: _state, position: _position, duration: d));
    });
    _player.onPositionChanged.listen((p) {
      _position = p;
      _statusController.add(AudioStatus(state: _state, position: p, duration: _duration));
    });
    _player.onPlayerComplete.listen((_) {
      _state = PlayerState.completed;
      _position = Duration.zero;
      _statusController.add(AudioStatus(state: PlayerState.completed, position: Duration.zero, duration: _duration));
    });
  }

  /// Play from a URL with haptic feedback.
  Future<void> play(String url) async {
    HapticFeedback.lightImpact();
    try {
      await _player.play(UrlSource(url));
    } catch (e) {
      debugPrint('ChapterAudioService play error: \$e');
    }
  }

  Future<void> pause() async {
    HapticFeedback.lightImpact();
    await _player.pause();
  }

  Future<void> resume() async {
    HapticFeedback.lightImpact();
    await _player.resume();
  }

  Future<void> stop() async {
    HapticFeedback.lightImpact();
    await _player.stop();
    _position = Duration.zero;
  }

  /// Seek to specific position.
  Future<void> seek(Duration position) async {
    HapticFeedback.lightImpact();
    await _player.seek(position);
  }

  /// Rewind by [seconds].
  Future<void> rewind(int seconds) async {
    HapticFeedback.lightImpact();
    final target = _position - Duration(seconds: seconds);
    await seek(target.isNegative ? Duration.zero : target);
  }

  /// Fast forward by [seconds].
  Future<void> fastForward(int seconds) async {
    HapticFeedback.lightImpact();
    final target = _position + Duration(seconds: seconds);
    await seek(target > _duration ? _duration : target);
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _statusController.close();
  }
}

class AudioStatus {
  final PlayerState state;
  final Duration position;
  final Duration duration;

  const AudioStatus({
    required this.state,
    required this.position,
    required this.duration,
  });
}

/// Available reciters/sources for chapter narration.
class AudioReciter {
  final String id;
  final String name;
  final String language;
  final String accent;

  const AudioReciter({
    required this.id,
    required this.name,
    required this.language,
    required this.accent,
  });
}

const List<AudioReciter> kAvailableReciters = [
  AudioReciter(
    id: 'sanskrit_original',
    name: 'Sanskrit Original',
    language: 'Sanskrit',
    accent: 'Classical',
  ),
  AudioReciter(
    id: 'hindi_narration',
    name: 'Hindi Narration',
    language: 'Hindi',
    accent: 'Standard',
  ),
  AudioReciter(
    id: 'english_translation',
    name: 'English Translation',
    language: 'English',
    accent: 'British',
  ),
  AudioReciter(
    id: 'commentary_dev',
    name: 'Devotional Commentary',
    language: 'Hindi',
    accent: 'Devotional',
  ),
];
