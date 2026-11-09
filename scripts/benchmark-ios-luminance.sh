#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
xcrun swiftc -O "$ROOT/ios/Core/LuminanceAnalyzer.swift" \
  "$ROOT/tests/performance/ios-luminance/WeightedCandidate.swift" \
  "$ROOT/tests/performance/ios-luminance/main.swift" -o "$WORK/benchmark"
"$WORK/benchmark"
