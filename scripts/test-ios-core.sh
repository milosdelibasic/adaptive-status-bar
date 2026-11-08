#!/bin/sh
set -eu
cd "$(dirname "$0")/../ios"
OUT="$(mktemp -d)/AdaptiveStatusBarCoreTests.xctest"
mkdir -p "$OUT/Contents/MacOS"
PLAT="$(xcrun --show-sdk-platform-path)"
xcrun swiftc -O -parse-as-library -emit-library -module-name AdaptiveStatusBarCoreTests \
  -o "$OUT/Contents/MacOS/AdaptiveStatusBarCoreTests" Core/*.swift Tests/*.swift \
  -F "$PLAT/Developer/Library/Frameworks" -I "$PLAT/Developer/usr/lib" -L "$PLAT/Developer/usr/lib" \
  -framework XCTest -Xlinker -rpath -Xlinker "$PLAT/Developer/Library/Frameworks" \
  -Xlinker -rpath -Xlinker "$PLAT/Developer/usr/lib"
xcrun xctest "$OUT"
