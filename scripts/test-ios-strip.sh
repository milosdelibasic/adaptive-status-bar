#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
DEVICE="${1:?Pass an already booted iOS simulator UDID}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
ARCH="$(uname -m)"
xcrun swiftc -sdk "$SDK" -target "$ARCH-apple-ios15.1-simulator" \
  "$ROOT/ios/StripRenderer.swift" "$ROOT/tests/ios-strip/main.swift" -o "$WORK/checks"
xcrun simctl spawn "$DEVICE" "$WORK/checks"
