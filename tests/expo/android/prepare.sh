#!/bin/sh
# Builds an isolated Expo consumer from the current unpublished package.
# This leaves Debug as a real development client; it needs Metro on port 8085.
set -eu
HERE="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
ROOT="$(CDPATH= cd -- "$HERE/../../.." && pwd)"
WORK="${1:?Usage: prepare.sh NEW_CONSUMER_DIRECTORY}"
if [ -L "$WORK" ] || { [ -e "$WORK" ] && { [ ! -d "$WORK" ] || [ -n "$(find "$WORK" -mindepth 1 -maxdepth 1 -print -quit)" ]; }; }; then
  printf 'Refusing nonempty or non-directory target: %s\n' "$WORK" >&2
  exit 1
fi
mkdir -p "$WORK"
WORK="$(CDPATH= cd -- "$WORK" && pwd)"
cp "$HERE/package.json" "$HERE/package-lock.json" "$HERE/app.json" "$HERE/index.js" "$WORK/"
cp "$ROOT/tests/android/App.tsx" "$WORK/App.tsx"
npm pack "$ROOT" --ignore-scripts --pack-destination "$WORK" --json > "$WORK/pack.json"
ARCHIVE="$(node -e 'process.stdout.write(require(process.argv[1])[0].filename)' "$WORK/pack.json")"
(cd "$WORK" && npm ci --ignore-scripts --no-audit --no-fund && npm install "$WORK/$ARCHIVE" --save-exact --ignore-scripts --no-audit --no-fund && npx expo prebuild --platform android --clean --no-install)
if [ -n "${ANDROID_HOME:-}" ]; then printf 'sdk.dir=%s\n' "$ANDROID_HOME" > "$WORK/android/local.properties"; fi
(cd "$WORK/android" && ./gradlew :app:assembleDebug :app:assembleRelease -PreactNativeArchitectures="${ANDROID_TEST_ABI:-arm64-v8a}" --max-workers=4)
printf 'APK directory: %s/android/app/build/outputs/apk\n' "$WORK"
