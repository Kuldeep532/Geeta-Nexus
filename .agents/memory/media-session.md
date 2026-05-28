---
name: Web Media Session API via dart:js
description: How browser notification / OS lock screen audio controls are wired up.
---

## Rule
MediaSessionService in lib/audio/media_session.dart uses `dart:js` to call `navigator.mediaSession`. It no-ops on unsupported browsers. AudioState calls it on every `play()` and inside the status stream listener.

**Why:** Flutter web has no native notification system. The Web Media Session API is the only cross-browser way to expose transport controls to the OS (lock screen, headset keys, notification panel on Android Chrome/Firefox).

**How to apply:** Call `MediaSessionService.setMetadata(...)` after `play()`, `setPlaybackState(...)` on every status update, and `setActionHandlers(...)` after every `play()` to re-register callbacks pointing to the new chapter's prev/next availability.
