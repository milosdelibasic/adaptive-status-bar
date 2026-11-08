# Initial integration validation — 2026-11-08

React Native 0.86 / New Architecture, without Expo runtime.

- 27 JavaScript tests passed.
- 24 Swift core tests passed.
- 24 Kotlin core tests passed.
- iOS Debug simulator build passed (iPhone 17, iOS 27).
- Android Debug arm64 build passed (Pixel 3a emulator, Android 14/API 34).
- 16 integration checks passed on each platform: dark/light WebP replacement, animated scrolling, repeated image changes, override recovery, React Native Modal images/scrolling and recovery after dismissal.
- Integration checks compared sampled style, system-reported style, pixel lightness and capture failures. Screenshots confirmed the displayed icon contrast.

This is functional validation on simulators/emulators, not physical-device or release performance certification. The integration harness belongs to the consuming application and is not required to install this library. Refer to README for limitations around native SDK windows, Android API 24–25, SurfaceView video and iOS camera/Metal/Skia layers.
