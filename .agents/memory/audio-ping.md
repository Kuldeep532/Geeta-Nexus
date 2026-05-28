---
name: Audio endpoint health ping
description: How GitaAudioChaptersScreen checks which chapter audio endpoints are alive.
---

## Rule
`GitaAudioChaptersScreen` is now a `StatefulWidget` that fires `http.head()` pings against all 18 chapter MP3 URLs in parallel on `initState()`. Each chapter that returns HTTP 200-399 is marked available; anything else (timeout, 404, 5xx) is marked unavailable.

**Why:** The spec demands "if audio is live, show the player; otherwise, hide the audio option." Pinging on init avoids a dead-end tap that loads an unplayable URL.

**How to apply:** The ping runs once per screen visit. Unavailable chapters show a muted grey badge with a `headset_off` icon and are non-tappable. The ping timeout is 4 seconds to keep the UI responsive.
