// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/foundation.dart';

// Android build ko pass karwane ke liye compiler-level safe check
// Agar web hai toh hi 'dart:js' load hoga, nahi toh dummy placeholder chalega
import 'dart:js' if (dart.library.io) 'package:flutter/foundation.dart' as js;

/// Integrates with the Web Media Session API so the browser notification
/// panel and OS lock screen can display "now playing" metadata and expose
/// transport controls (play / pause / seek / previous / next).
///
/// No-ops gracefully on non-web platforms or unsupported browsers.
class MediaSessionService {
  static bool get _supported {
    if (!kIsWeb) return false;
    try {
      // kIsWeb true hone par hi yeh execute hoga
      final context = (js.context as dynamic);
      if (context == null) return false;
      final nav = context['navigator'];
      return nav != null && nav['mediaSession'] != null;
    } catch (_) {
      return false;
    }
  }

  static dynamic get _ms {
    try {
      return (js.context as dynamic)['navigator']['mediaSession'];
    } catch (_) {
      return null;
    }
  }

  /// Update the now-playing metadata shown in the OS / browser notification.
  static void setMetadata({
    required String title,
    required String artist,
    String album = 'Bhagavad Gita',
    String artworkUrl = '',
  }) {
    if (!_supported) return;
    try {
      final ms = _ms;
      if (ms == null) return;

      final context = (js.context as dynamic);
      
      final artwork = artworkUrl.isNotEmpty
          ? (js.context['JsArray'] as dynamic).from([
              (js.context['JsObject'] as dynamic).jsify({
                'src': artworkUrl,
                'sizes': '512x512',
                'type': 'image/png',
              })
            ])
          : [];

      final metadata = (js.context['JsObject'] as dynamic)(
        context['MediaMetadata'],
        [
          (js.context['JsObject'] as dynamic).jsify({
            'title': title,
            'artist': artist,
            'album': album,
            'artwork': artwork,
          })
        ],
      );
      ms['metadata'] = metadata;
    } catch (e) {
      debugPrint('MediaSession.setMetadata error: $e');
    }
  }

  /// Set the playback state ('playing', 'paused', or 'none').
  static void setPlaybackState(String state) {
    if (!_supported) return;
    try {
      _ms?['playbackState'] = state;
    } catch (_) {}
  }

  /// Register action handlers so hardware/software media keys work.
  static void setActionHandlers({
    VoidCallback? onPlay,
    VoidCallback? onPause,
    VoidCallback? onStop,
    VoidCallback? onPreviousTrack,
    VoidCallback? onNextTrack,
    void Function(double)? onSeekTo,
    VoidCallback? onSeekBackward,
    VoidCallback? onSeekForward,
  }) {
    if (!_supported) return;
    try {
      final ms = _ms;
      if (ms == null) return;

      _setHandler(ms, 'play', onPlay);
      _setHandler(ms, 'pause', onPause);
      _setHandler(ms, 'stop', onStop);
      _setHandler(ms, 'previoustrack', onPreviousTrack);
      _setHandler(ms, 'nexttrack', onNextTrack);
      _setHandler(ms, 'seekbackward', onSeekBackward);
      _setHandler(ms, 'seekforward', onSeekForward);

      if (onSeekTo != null) {
        ms.callMethod('setActionHandler', [
          'seekto',
          (js.context['allowInterop'] as dynamic)((dynamic details) {
            final seekTime =
                (details['seekTime'] as num?)?.toDouble() ?? 0.0;
            onSeekTo(seekTime);
          }),
        ]);
      }
    } catch (e) {
      debugPrint('MediaSession.setActionHandlers error: $e');
    }
  }

  /// Update the position state for the browser's progress UI.
  static void setPositionState({
    required double durationSeconds,
    required double positionSeconds,
    double playbackRate = 1.0,
  }) {
    if (!_supported) return;
    try {
      final ms = _ms;
      if (ms == null) return;
      ms.callMethod('setPositionState', [
        (js.context['JsObject'] as dynamic).jsify({
          'duration': durationSeconds,
          'position': positionSeconds.clamp(0.0, durationSeconds),
          'playbackRate': playbackRate,
        })
      ]);
    } catch (_) {}
  }

  static void _setHandler(
      dynamic ms, String action, VoidCallback? handler) {
    ms.callMethod('setActionHandler', [
      action,
      handler != null ? (js.context['allowInterop'] as dynamic)(handler) : null,
    ]);
  }
}
