import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

enum VoiceStatus { idle, synthesizing, playing, listening, processing, error }

class HuggingFaceVoiceService {
  static const String _hfApiKey = String.fromEnvironment('HF_API_KEY');
  static const String _backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  final StreamController<VoiceStatus> _statusController =
      StreamController<VoiceStatus>.broadcast();

  Stream<VoiceStatus> get statusStream => _statusController.stream;

  /// Text-to-Speech via Hugging Face Inference API.
  /// Returns base64-encoded audio data.
  Future<String> synthesize(String text) async {
    if (text.trim().isEmpty) return '';
    _statusController.add(VoiceStatus.synthesizing);

    final endpoint = _backendUrl.isNotEmpty
        ? Uri.parse('$_backendUrl/tts')
        : null;

    if (endpoint == null || _hfApiKey.isEmpty) {
      _statusController.add(VoiceStatus.error);
      return '';
    }

    try {
      final response = await http
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _statusController.add(VoiceStatus.idle);
        return data['audio_base64'] ?? '';
      }
    } catch (_) {
      // pass
    }
    _statusController.add(VoiceStatus.error);
    return '';
  }

  /// Speech-to-Text via Hugging Face Inference API.
  /// Accepts base64-encoded audio data.
  Future<String> transcribe(String audioBase64) async {
    if (audioBase64.isEmpty) return '';
    _statusController.add(VoiceStatus.processing);

    final endpoint = _backendUrl.isNotEmpty
        ? Uri.parse('$_backendUrl/stt')
        : null;

    if (endpoint == null || _hfApiKey.isEmpty) {
      _statusController.add(VoiceStatus.error);
      return '';
    }

    try {
      final response = await http
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'audio_base64': audioBase64}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _statusController.add(VoiceStatus.idle);
        return data['text'] ?? '';
      }
    } catch (_) {
      // pass
    }
    _statusController.add(VoiceStatus.error);
    return '';
  }

  Future<void> dispose() async {
    await _statusController.close();
  }
}
