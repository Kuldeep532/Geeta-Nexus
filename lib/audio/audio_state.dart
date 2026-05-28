import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../services/chapter_audio_service.dart';

/// Centralized global audio state for chapter narration playback.
/// Single source of truth — prevents multiple simultaneous audio instances.
class AudioState extends ChangeNotifier {
  final ChapterAudioService _service = ChapterAudioService();

  int? _currentChapterNumber;
  AudioReciter? _currentReciter;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _initialized = false;

  int? get currentChapterNumber => _currentChapterNumber;
  AudioReciter? get currentReciter => _currentReciter;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasTrack => _currentChapterNumber != null && _currentReciter != null;

  double get progress => _duration.inMilliseconds > 0
      ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;

  String get currentTitle => _currentChapterNumber != null
      ? 'Chapter $_currentChapterNumber'
      : '';

  String get currentReciterName => _currentReciter?.name ?? '';

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    _service.initialize();
    _service.statusStream.listen((status) {
      _isPlaying = status.state == PlayerState.playing;
      _position = status.position;
      _duration = status.duration;
      notifyListeners();
    });
  }

  static String audioUrl(int chapter, AudioReciter reciter) {
    return 'https://www.everydaycodings.com/api/v1/audio/chapter/$chapter/${reciter.id}.mp3';
  }

  Future<void> play(int chapterNumber, AudioReciter reciter) async {
    _currentChapterNumber = chapterNumber;
    _currentReciter = reciter;
    notifyListeners();
    await _service.play(audioUrl(chapterNumber, reciter));
  }

  Future<void> pause() async => _service.pause();

  Future<void> resume() async => _service.resume();

  Future<void> stop() async {
    await _service.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await pause();
    } else if (hasTrack) {
      await resume();
    }
  }

  Future<void> seekTo(Duration pos) async => _service.seek(pos);

  Future<void> rewind() async => _service.rewind(10);

  Future<void> fastForward() async => _service.fastForward(10);

  Future<void> nextChapter() async {
    if (_currentChapterNumber == null || _currentChapterNumber! >= 18) return;
    final reciter = _currentReciter ?? kAvailableReciters.first;
    await play(_currentChapterNumber! + 1, reciter);
  }

  Future<void> prevChapter() async {
    if (_currentChapterNumber == null || _currentChapterNumber! <= 1) return;
    final reciter = _currentReciter ?? kAvailableReciters.first;
    await play(_currentChapterNumber! - 1, reciter);
  }

  bool get canGoNext =>
      _currentChapterNumber != null && _currentChapterNumber! < 18;
  bool get canGoPrev =>
      _currentChapterNumber != null && _currentChapterNumber! > 1;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
