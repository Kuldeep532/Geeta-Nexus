#!/bin/bash
set -e

FLUTTER=$(which flutter)
DHTTPD="$HOME/.pub-cache/bin/dhttpd"

echo "▶ Restoring packages..."
"$FLUTTER" pub get

# Kill any stale process on port 5000
fuser -k 5000/tcp 2>/dev/null || true

DART_DEFINES=""
if [ -n "$GEMINI_AI_API_KEY" ]; then
  DART_DEFINES="--dart-define=GEMINI_AI_API_KEY=$GEMINI_AI_API_KEY"
fi
if [ -n "$ADMIN_LOGIN_PASSWORD" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=ADMIN_LOGIN_PASSWORD=$ADMIN_LOGIN_PASSWORD"
fi

echo "▶ Building Flutter web app (release)..."
"$FLUTTER" build web --release $DART_DEFINES

echo "▶ Starting web server on port 5000..."
exec "$DHTTPD" --host 0.0.0.0 --port 5000 --path build/web
