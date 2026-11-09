#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
WORK="${ANDROID_INTEGRATION_WORK:-$(mktemp -d)}"
CONSUMER="$WORK/consumer"
mkdir -p "$CONSUMER"
cp "$ROOT/tests/android/package.json" "$ROOT/tests/android/package-lock.json" "$CONSUMER/"
(cd "$CONSUMER" && npm ci --ignore-scripts --no-audit --no-fund)
npm pack "$ROOT" --ignore-scripts --pack-destination "$WORK" --json > "$WORK/pack.json"
ARCHIVE="$(node -e 'process.stdout.write(require(process.argv[1])[0].filename)' "$WORK/pack.json")"
(cd "$CONSUMER" && npm install "$WORK/$ARCHIVE" --save-exact --ignore-scripts --no-audit --no-fund)
node "$ROOT/tests/android/prepare.mjs" "$CONSUMER"
if [ -n "${ANDROID_HOME:-}" ]; then printf 'sdk.dir=%s\n' "$ANDROID_HOME" > "$CONSUMER/android/local.properties"; fi
(cd "$CONSUMER/android" && ./gradlew :app:assembleDebug :app:assembleRelease -PreactNativeArchitectures="${ANDROID_TEST_ABI:-x86_64}" --console=plain)
printf 'Built self-contained test APKs in %s\n' "$CONSUMER/android/app/build/outputs/apk"
if [ -n "${ANDROID_SERIAL:-}" ]; then
  sh "$ROOT/tests/android/run-variants.sh" "$WORK" "$ANDROID_SERIAL"
else
  echo 'Build-only: ANDROID_SERIAL unset; no runtime tests were run.'
fi
