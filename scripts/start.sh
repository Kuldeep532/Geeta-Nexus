#!/bin/bash
set -e

FLUTTER=/nix/store/i07crp4mg1rimd97s1byrq4gasg7dsk5-flutter-wrapped-3.32.0-sdk-links/bin/flutter

DART_DEFINES=""
if [ -n "$GEMINI_AI_API_KEY" ]; then
  DART_DEFINES="--dart-define=GEMINI_AI_API_KEY=$GEMINI_AI_API_KEY"
fi
if [ -n "$ADMIN_LOGIN_PASSWORD" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=ADMIN_LOGIN_PASSWORD=$ADMIN_LOGIN_PASSWORD"
fi

exec "$FLUTTER" run -d web-server --web-port 5000 --web-hostname 0.0.0.0 $DART_DEFINES
