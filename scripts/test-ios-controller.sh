#!/bin/sh
# Execute actual controller logic with UIKit capture/appearance stand-ins.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
# Only platform imports and sample() visibility change; method bodies are real.
sed '/^\/\/\/ Passive recognizer:/,$d; s/import UIKit/import Foundation\
import CoreFoundation/; s/private func sample()/func sample()/' \
  "$ROOT/ios/AdaptiveStatusBarController.swift" > "$WORK/Controller.swift"
cp "$ROOT/tests/ios-controller/main.swift" "$WORK/main.swift"
xcrun swiftc -O "$ROOT"/ios/Core/*.swift "$ROOT/tests/ios-controller/UIKitSeam.swift" \
  "$WORK/Controller.swift" "$WORK/main.swift" -o "$WORK/checks"
"$WORK/checks"
