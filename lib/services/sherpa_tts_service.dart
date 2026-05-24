import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

enum SherpaTtsStatus { initializing, ready, speaking, error }

class SherpaTtsService {
  SherpaTtsService();

  final AudioPlayer _player = AudioPlayer();
  final StreamController<SherpaTtsStatus> _statusController =
      StreamController<SherpaTtsStatus>.broadcast();

  sherpa.OfflineTts? _enTts;
  sherpa.OfflineTts? _hiTts;
  bool _initialized = false;

  Stream<SherpaTtsStatus> get statusStream => _statusController.stream;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _statusController.add(SherpaTtsStatus.initializing);
    try {
      _enTts = await _buildEnglishModel();
      _hiTts = await _buildHindiModel();

      _player.onPlayerComplete.listen((_) {
        _statusController.add(SherpaTtsStatus.ready);
      });

      _initialized = true;
      _statusController.add(SherpaTtsStatus.ready);
    } catch (_) {
      _statusController.add(SherpaTtsStatus.error);
      rethrow;
    }
  }

  Future<void> speak(String text) async {
    if (!_initialized || text.trim().isEmpty) return;
    await stop();

    final language = _detectLanguage(text);
    final tts = language == 'hi' ? _hiTts : _enTts;
    if (tts == null) throw StateError('TTS model not loaded for $language');

    _statusController.add(SherpaTtsStatus.speaking);

    final pcmPath = await compute(_synthesizeToWavInIsolate, {
      'text': text,
      'lang': language,
      'sampleRate': tts.sampleRate,
      'audio': base64Encode(tts.generate(text).samples.buffer.asUint8List()),
    });

    await _player.play(DeviceFileSource(pcmPath));
  }

  Future<void> stop() async {
    await _player.stop();
    if (_initialized) {
      _statusController.add(SherpaTtsStatus.ready);
    }
  }

  String _detectLanguage(String text) {
    final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(text);
    return hasDevanagari ? 'hi' : 'en';
  }

  Future<sherpa.OfflineTts> _buildEnglishModel() async {
    final config = sherpa.OfflineTtsConfig(
      model: sherpa.OfflineTtsModelConfig(
        vits: sherpa.OfflineTtsVitsModelConfig(
          model: 'assets/tts/en/vits-en.onnx',
          lexicon: 'assets/tts/en/lexicon.txt',
          tokens: 'assets/tts/en/tokens.txt',
        ),
      ),
    );
    return sherpa.OfflineTts(config);
  }

  Future<sherpa.OfflineTts> _buildHindiModel() async {
    final config = sherpa.OfflineTtsConfig(
      model: sherpa.OfflineTtsModelConfig(
        vits: sherpa.OfflineTtsVitsModelConfig(
          model: 'assets/tts/hi/vits-hi.onnx',
          lexicon: 'assets/tts/hi/lexicon.txt',
          tokens: 'assets/tts/hi/tokens.txt',
        ),
      ),
    );
    return sherpa.OfflineTts(config);
  }

  Future<void> dispose() async {
    await _player.dispose();
    _enTts?.free();
    _hiTts?.free();
    await _statusController.close();
  }
}

Future<String> _synthesizeToWavInIsolate(Map<String, dynamic> args) async {
  final bytes = base64Decode(args['audio'] as String);
  final sampleRate = args['sampleRate'] as int;
  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/sherpa_${DateTime.now().microsecondsSinceEpoch}.wav',
  );
  await file.writeAsBytes(_encodeWav(bytes, sampleRate));
  return file.path;
}

List<int> _encodeWav(List<int> pcm16leBytes, int sampleRate) {
  final dataLength = pcm16leBytes.length;
  final totalLength = 44 + dataLength;
  final header = BytesBuilder();
  void writeString(String s) => header.add(ascii.encode(s));
  void write32(int v) => header.add([
        v & 0xff,
        (v >> 8) & 0xff,
        (v >> 16) & 0xff,
        (v >> 24) & 0xff,
      ]);
  void write16(int v) => header.add([v & 0xff, (v >> 8) & 0xff]);

  writeString('RIFF');
  write32(totalLength - 8);
  writeString('WAVEfmt ');
  write32(16);
  write16(1);
  write16(1);
  write32(sampleRate);
  write32(sampleRate * 2);
  write16(2);
  write16(16);
  writeString('data');
  write32(dataLength);

  return [...header.toBytes(), ...pcm16leBytes];
}
