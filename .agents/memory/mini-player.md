---
name: Persistent mini audio player placement
description: Where and how the MiniAudioPlayer is mounted in the shell.
---

## Rule
MiniAudioPlayer is mounted inside `MainShell.bottomNavigationBar` as the first child of a `Column(mainAxisSize: MainAxisSize.min)`, with the `BottomNavigationBar` as the second child.

**Why:** This is the only approach that (a) persists across all tabs without re-creation, (b) doesn't interfere with page content via Stack/Overlay, (c) works correctly with SafeArea, and (d) animates in/out without layout jumps.

**How to apply:** Never move this to a Stack, Overlay, or persistent footer. The AnimatedSwitcher inside MiniAudioPlayer handles the slide-up/slide-down animation based on `AudioState.hasTrack`.
