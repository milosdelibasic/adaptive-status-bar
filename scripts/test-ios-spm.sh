#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/consumer"
cp "$ROOT/tests/spm/package.json" "$ROOT/tests/spm/package-lock.json" "$WORK/consumer/"
(cd "$WORK/consumer" && npm ci --no-audit --no-fund --ignore-scripts)
npm pack "$ROOT" --ignore-scripts --pack-destination "$WORK" --json > "$WORK/pack.json"
ARCHIVE="$(node -e 'process.stdout.write(require(process.argv[1])[0].filename)' "$WORK/pack.json")"
(cd "$WORK/consumer" && npm install "$WORK/$ARCHIVE" --save-exact --no-audit --no-fund --ignore-scripts --prefer-offline)
node "$ROOT/tests/spm/prepare.mjs" "$WORK/consumer"
cd "$WORK/consumer/ios"
node ../node_modules/react-native/scripts/setup-apple-spm.js add --deintegrate --yes
for CONFIG in Debug Release; do
  if [ "$CONFIG" = Debug ]; then DEST='generic/platform=iOS Simulator'; else DEST='generic/platform=iOS'; fi
  if ! xcodebuild -quiet -project HelloWorld.xcodeproj -scheme HelloWorld \
    -configuration "$CONFIG" -destination "$DEST" -derivedDataPath "$WORK/derived" \
    CODE_SIGNING_ALLOWED=NO > "$WORK/$CONFIG.log" 2>&1; then
    tail -n 120 "$WORK/$CONFIG.log"
    exit 1
  fi
  echo "SPM consumer $CONFIG build passed (React Native 0.88.1)."
done
