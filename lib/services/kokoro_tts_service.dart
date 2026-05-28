import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Production Kokoro-82M TTS Service via Hugging Face Inference API.
/// Requires --dart-define HF_API_TOKEN=<your_token>
class KokoroTTSService {
  static const String _hfToken = String.fromEnvironment('HF_API_TOKEN');

  static const String _inferenceUrl =
      'https://api-inference.huggingface.co/models/hexgrad/Kokoro-82M';

  final AudioPlayer _player = AudioPlayer();

  final StreamController<bool> _speakingController =
      StreamController<bool>.broadcast();
  Stream<bool> get speakingStream => _speakingController.stream;

  bool get isSpeaking => _player.state == PlayerState.playing;

  Future<void> initialize() async {
    _player.onPlayerStateChanged.listen((state) {
      _speakingController.add(state == PlayerState.playing);
    });
  }

  /// Synthesize text with Kokoro-82M and play immediately.
  /// Returns true on success, false otherwise.
  Future<bool> speak(String text) async {
    if (text.trim().isEmpty) return false;
    if (_hfToken.isEmpty) {
      debugPrint('KokoroTTSService: HF_API_TOKEN not set');
      return false;
    }

    try {
      final bytes = await _synthesize(text);
      if (bytes == null || bytes.isEmpty) return false;

      await _player.stop();
      await _player.play(BytesSource(bytes));
      return true;
    } catch (e) {
      debugPrint('KokoroTTSService speak error: \$e');
      return false;
    }
  }

  /// Synthesize text to audio bytes.
  Future<Uint8List?> _synthesize(String text) async {
    final response = await http
        .post(
          Uri.parse(_inferenceUrl),
          headers: {
            'Authorization': 'Bearer \$_hfToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'inputs': text,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    debugPrint('Kokoro TTS error: \${response.statusCode} \${response.body}');
    return null;
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _speakingController.close();
  }
}
