---
name: Flutter web audio architecture
description: How audio playback is structured in Gita Nexus — single source of truth, service separation.
---

## Rule
AudioState (ChangeNotifier) is the single source of truth for all chapter audio. ChapterAudioService is the low-level audioplayers wrapper. Never create a second AudioPlayer or ChapterAudioService instance outside AudioState.

**Why:** Multiple AudioPlayer instances cause silent audio conflicts on Flutter web (browser allows only one active AudioContext per origin in some browsers). All play/pause/seek calls must go through AudioState.

**How to apply:** Any widget that needs audio control must use `context.read<AudioState>()` or `Consumer<AudioState>`. The ChantsScreen/JustAudio player is separate because it plays looping mantra chants (unrelated to chapter narration).
