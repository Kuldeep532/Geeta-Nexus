import 'dart:async';

enum SherpaTtsStatus { initializing, ready, speaking, error }

class SherpaTtsService {
  SherpaTtsService();

  final StreamController<SherpaTtsStatus> _statusController =
      StreamController<SherpaTtsStatus>.broadcast();

  bool _initialized = false;

  Stream<SherpaTtsStatus> get statusStream => _statusController.stream;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _initialized = true;
    _statusController.add(SherpaTtsStatus.ready);
  }

  Future<void> speak(String text) async {
  }

  Future<void> stop() async {
    if (_initialized) {
      _statusController.add(SherpaTtsStatus.ready);
    }
  }

  Future<void> dispose() async {
    await _statusController.close();
  }
}
