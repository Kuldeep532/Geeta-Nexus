import 'package:flutter/foundation.dart';

/// Universal MediaSession API Mock that works perfectly everywhere.
/// No imports of dart:js, package:js, or web libraries.
/// Zero compilation errors on Android, safe structure for Web testing.
class MediaSessionService {
  static bool get _supported => false;

  static void setMetadata({
    required String title,
    required String artist,
    String album = 'Bhagavad Gita',
    String artworkUrl = '',
  }) {
    // No-op: Safely ignored on all platforms during compile
  }

  static void setPlaybackState(String state) {
    // No-op
  }

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
    // No-op
  }

  static void setPositionState({
    required double durationSeconds,
    required double positionSeconds,
    double playbackRate = 1.0,
  }) {
    // No-op
  }
}
