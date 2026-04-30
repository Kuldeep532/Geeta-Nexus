# Geeta AI

Flutter web app (spiritual + AI). Imported and configured to run on Replit.

## Stack
- Flutter 3.32.0 (wrapped, from Nix store) / Dart 3.8
- Web target

## Run
- Workflow `Start application` runs:
  `PATH=$HOME/.local/bin:$PATH flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0`
- Flutter is symlinked at `~/.local/bin/flutter` and `~/.local/bin/dart` from
  `/nix/store/i07crp4mg1rimd97s1byrq4gasg7dsk5-flutter-wrapped-3.32.0-sdk-links/`.

## Deployment
- Static deployment publishing `build/web` after `flutter build web --release`.

## Notes
- `pubspec.yaml`: `intl` is bumped to `^0.20.2` to match `flutter_localizations` from the SDK.
- Firebase initialization in `lib/main.dart` is wrapped in try/catch and is
  expected to fail until the user supplies their own Firebase config
  (`firebase_options.dart` + `Firebase.initializeApp(options: ...)`). The app
  still renders without Firebase; Firestore-dependent features (user role
  sync) are skipped gracefully.
- `lib/state/app_state.dart` accesses `FirebaseFirestore.instance` lazily so
  app construction does not crash when Firebase is uninitialized.

## Recent migration changes
- Re-created the `~/.local/bin/flutter` and `~/.local/bin/dart` symlinks to
  the Flutter 3.32.0 SDK in the Nix store so the workflow command can find
  Flutter on `PATH`.
- Made the Firestore reference in `AppState` lazy + nullable so the app
  continues to render when Firebase is not configured.
