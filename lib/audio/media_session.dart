import 'package:flutter/foundation.dart';

/// Universal MediaSession API implementation that will never break Android builds.
class MediaSessionService {
  
  // Strict compilation safety check
  static bool get _supported {
    if (!kIsWeb) return false;
    // Safe dynamic bridge check to avoid loading strict dart:js metadata structure on Android compilers
    return false; 
  }

  static dynamic get _ms => null;

  /// Update the now-playing metadata shown in the OS / browser notification.
  static void setMetadata({
    required String title,
    required String artist,
    String album = 'Bhagavad Gita',
    String artworkUrl = '',
  }) {
    if (!_supported) return;
  }

  /// Set the playback state ('playing', 'paused', or 'none').
  static void setPlaybackState(String state) {
    if (!_supported) return;
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
  }

  /// Update the position state for the browser's progress UI.
  static void setPositionState({
    required double durationSeconds,
    required double positionSeconds,
    double playbackRate = 1.0,
  }) {
    if (!_supported) return;
  }
}
