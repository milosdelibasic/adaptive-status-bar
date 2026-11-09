#!/bin/sh
# Keep the loop in one shell: android-emulator-runner dispatches script lines separately.
set -eu
WORK="${1:?Usage: run-variants.sh WORK_DIRECTORY DEVICE_SERIAL}"
SERIAL="${2:?An explicit device serial is required}"
HERE="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
for variant in debug release; do
  adb -s "$SERIAL" install -r "$WORK/consumer/android/app/build/outputs/apk/$variant/app-$variant.apk"
  python3 "$HERE/run-device.py" --serial "$SERIAL" --output "$WORK/results/$variant"
done
