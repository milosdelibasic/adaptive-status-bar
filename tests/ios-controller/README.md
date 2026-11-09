# iOS controller lifecycle regression seam

Run `sh scripts/test-ios-controller.sh` on macOS with Xcode. It compiles the actual
controller method bodies and Core sources, replacing only UIKit imports/capture,
appearance/window/gesture types and exposing the private timer callback for tests.
The main run loop is not pumped, so queued callbacks are invoked deterministically.
This is not a UIKit rendering or physical-device performance test.

Baseline f3d10de reproduced one appearance write from configure while paused,
one capture from an already-queued paused timer, and 100 observer reattachments
for 100 alternating hints in automatic mode. The fixed code produces zero for
all three while preserving resumed sampling, latest-hint storage, hybrid strategy
switching and recovery after clearing hints/overrides.

The final 0.2.0 controller was also installed as an npm-packed dependency in the
isolated Expo58/RN0.88.1 iOS27 consumer. Debug and Release simulator builds passed.
Release verified white/black adaptation with native style assertions, override
and recovery, background/foreground and modal open/close. Debug verified actual
Metro loading, black/white adaptation, JS reload and background/foreground; final
visible dark icons on white, failures0 and externalWrites0 were inspected.

These checks do not prove an app-wide speedup or battery improvement. The reduction
in automatic-hint restarts is an exact operation-count improvement. A weighted
Swift LUT candidate was rejected after inconsistent paired microbenchmarks; see
`tests/performance/ios-luminance`.
