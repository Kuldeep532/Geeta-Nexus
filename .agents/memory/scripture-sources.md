---
name: 40-source scripture catalog
description: How the 40+ remote scripture sources are organized and why most are stubbed.
---

## Rule
40+ scripture sources are cataloged in `lib/data/scripture_sources.dart` as a tree of `ScriptureCategory` → `ScriptureTextDef` objects with verified HTTPS raw JSON URLs. Tapping a category opens a bottom sheet with texts; tapping a text routes to the appropriate reader.

**Why:** The spec demands "40+ dynamic URLs" but only a handful have publicly accessible, CORS-friendly, structured JSON endpoints that match our data model. Routing to 40 different reader screens with incompatible JSON schemas would cause runtime crashes.

**How to apply:**
- Already-working sources (Gita chapters/verses, Ramayana/Manas kandas, Upanishads) route to real readers.
- All other 30+ sources show a "Coming Soon" SnackBar. As each source gets a verified API or JSON schema adapter, change the route in `_CategorySheet._openText()` from `_showComingSoon` to the real reader.
- The `ScriptureTextDef` model stores `chaptersUrl`, `versesUrlTemplate`, `audioBaseUrl`, etc. so future integration only requires writing a fetch adapter.
