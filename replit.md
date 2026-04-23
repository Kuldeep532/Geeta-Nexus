# Geeta AI

Flutter web app (spiritual + AI). Imported and configured to run on Replit.

## Stack
- Flutter 3.32.0 (wrapped, from Nix store) / Dart 3.8
- Web target

## Run
- Workflow `Start application` runs:
  `flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0`
- Flutter is symlinked at `~/.local/bin/flutter` and `~/.local/bin/dart`.

## Deployment
- Static deployment publishing `build/web` after `flutter build web --release`.

## Notes
- `pubspec.yaml`: bumped `intl` to `^0.20.2` to match `flutter_localizations` from the SDK.
