#!/bin/bash
set -e

MY_FLUTTER_ROOT=$HOME/.local/flutter_sdk
DART38=/nix/store/6xjp9yn2lnm3hvr7l78n7v0z3a6g784i-dart-3.8.0
LINUX_X64_FS=$MY_FLUTTER_ROOT/bin/cache/artifacts/engine/linux-x64/frontend_server_aot.dart.snapshot
DART_SDK_FS=$MY_FLUTTER_ROOT/bin/cache/dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot
DEV_COMPILER_DST=$MY_FLUTTER_ROOT/bin/cache/dart-sdk/lib/dev_compiler

if [ ! -d "$DEV_COMPILER_DST" ]; then
  echo "Copying dev_compiler from dart 3.8.0..."
  cp -r $DART38/lib/dev_compiler $DEV_COMPILER_DST
fi

if [ -f "$LINUX_X64_FS" ]; then
  FS_SIZE=$(stat -c%s "$DART_SDK_FS" 2>/dev/null || echo 0)
  LINUX_SIZE=$(stat -c%s "$LINUX_X64_FS" 2>/dev/null || echo 1)
  if [ "$FS_SIZE" != "$LINUX_SIZE" ]; then
    echo "Patching frontend_server_aot.dart.snapshot..."
    cp $LINUX_X64_FS $DART_SDK_FS
  fi
fi

if [ ! -f "$HOME/.local/bin/flutter" ]; then
  mkdir -p $HOME/.local/bin
  cat > $HOME/.local/bin/flutter << 'WRAPPER'
#!/bin/bash
MY_FLUTTER_ROOT=$HOME/.local/flutter_sdk
FLUTTER_TOOLS=/nix/store/69pbq8q400x9na0m82cn4kc4jgzc3vfm-flutter-tools-3.32.0/share/flutter_tools.snapshot
DART=$MY_FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart
FLUTTER_TOOLS_PACKAGE_CONFIG=/nix/store/dc5v74pjzcr73y4c5pwynnibl58bp5fl-flutter-tools-3.32.0-pubcache/package_config.json

export FLUTTER_ROOT=$MY_FLUTTER_ROOT
export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
export PATH=/nix/store/smaydcvrcaz906653vbnps70y9j7w658-git-2.49.0/bin:/nix/store/qyjbgdpvyw0yzr3bcs83lnjdqgl4j4gw-which-2.23/bin:$PATH

exec "$DART" \
  --disable-dart-dev \
  --packages="$FLUTTER_TOOLS_PACKAGE_CONFIG" \
  "$FLUTTER_TOOLS" \
  --local-engine-host=host_release \
  "$@"
WRAPPER
  chmod +x $HOME/.local/bin/flutter
fi

export PATH=$HOME/.local/bin:$PATH

DART_DEFINES=""
if [ -n "$GEMINI_AI_API_KEY" ]; then
  DART_DEFINES="--dart-define=GEMINI_AI_API_KEY=$GEMINI_AI_API_KEY"
fi
if [ -n "$ADMIN_LOGIN_PASSWORD" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=ADMIN_LOGIN_PASSWORD=$ADMIN_LOGIN_PASSWORD"
fi

exec flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0 $DART_DEFINES
