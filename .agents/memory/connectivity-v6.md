---
name: connectivity_plus v6 API change
description: Breaking change in connectivity_plus 6.x — returns List not a single value.
---

## Rule
`connectivity_plus` v6+ has `checkConnectivity()` return a `List<ConnectivityResult>`. Old code checking `result == ConnectivityResult.none` will always be false (comparing a List to an enum).

**Why:** The package changed the API in v6 to support multi-network devices (e.g., WiFi + cellular simultaneously).

**How to apply:**
```dart
final results = await Connectivity().checkConnectivity();
final isOffline = results is List
    ? results.every((r) => r == ConnectivityResult.none)
    : results == ConnectivityResult.none;
```
