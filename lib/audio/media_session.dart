// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/foundation.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;

class MediaSessionService {
  static bool get _supported {
    if (!kIsWeb) return false;
    try {
      final window = js_util.globalThis;
      final navigator = js_util.getProperty(window, 'navigator');
      return navigator != null && js_util.hasProperty(navigator, 'mediaSession');
    } catch (_) { return false; }
  }

  static dynamic get _ms {
    try {
      final window = js_util.globalThis;
      final navigator = js_util.getProperty(window, 'navigator');
      return js_util.getProperty(navigator, 'mediaSession');
    } catch (_) { return null; }
  }

  static void setMetadata({required String title, required String artist, String album = 'Bhagavad Gita', String artworkUrl = ''}) {
    if (!_supported) return;
    try {
      final ms = _ms;
      if (ms == null) return;
      final window = js_util.globalThis;
      final mediaMetadataConstructor = js_util.getProperty(window, 'MediaMetadata');
      final artworkList = artworkUrl.isNotEmpty ? [js_util.jsify({'src': artworkUrl, 'sizes': '512x512', 'type': 'image/png'})] : [];
      final metadata = js_util.callConstructor(mediaMetadataConstructor, [js_util.jsify({'title': title, 'artist': artist, 'album': album, 'artwork': artworkList})]);
      js_util.setProperty(ms, 'metadata', metadata);
    } catch (e) { debugPrint('MediaSession.setMetadata error: $e'); }
  }

  static void setPlaybackState(String state) {
    if (!_supported) return;
    try { js_util.setProperty(_ms, 'playbackState', state); } catch (_) {}
  }

  static void setActionHandlers({VoidCallback? onPlay, VoidCallback? onPause, VoidCallback? onStop, VoidCallback? onPreviousTrack, VoidCallback? onNextTrack, void Function(double)? onSeekTo, VoidCallback? onSeekBackward, VoidCallback? onSeekForward}) {
    if (!_supported) return;
    try {
      final ms = _ms;
      if (ms == null) return;
      _setHandler(ms, 'play', onPlay);
      _setHandler(ms, 'pause', onPause);
      _setHandler(ms, 'stop', onStop);
      _setHandler(ms, 'previoustrack', onPreviousTrack);
      _setHandler(ms, 'nexttrack', onNextTrack);
      if (onSeekTo != null) {
        js_util.callMethod(ms, 'setActionHandler', ['seekto', js.allowInterop((dynamic details) {
          final seekTime = (js_util.getProperty(details, 'seekTime') as num?)?.toDouble() ?? 0.0;
          onSeekTo(seekTime);
        })]);
      }
    } catch (e) { debugPrint('MediaSession.setActionHandlers error: $e'); }
  }

  static void setPositionState({required double durationSeconds, required double positionSeconds, double playbackRate = 1.0}) {
    if (!_supported) return;
    try {
      js_util.callMethod(_ms, 'setPositionState', [js_util.jsify({'duration': durationSeconds, 'position': positionSeconds.clamp(0.0, durationSeconds), 'playbackRate': playbackRate})]);
    } catch (_) {}
  }

  static void _setHandler(dynamic ms, String action, VoidCallback? handler) {
    if (ms == null) return;
    js_util.callMethod(ms, 'setActionHandler', [action, handler != null ? js.allowInterop(handler) : null]);
  }
}
