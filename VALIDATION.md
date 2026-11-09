# Verification

## Android changes in 0.1.6, 2026-11-09

Tested the modified library as an **npm-packed dependency** of the standalone React Native 0.88.1 consumer in `tests/android`. React 19.3.0, New Architecture, arm64-v8a, compile SDK 37 and target SDK 36. Both Debug and Release embed the JS bundle and run without Metro. Release uses the fixture's disposable debug signing key, not production signing.

### Local results

| Android | API | Debug | Release | Coverage |
| --- | --- | --- | --- | --- |
| 7.0 | 24 | Passed | Passed | 14 fallback checks + rotation/resume |
| 7.1 | 25 | Passed | Passed | 14 fallback checks + rotation/resume |
| 14 | 34 | Passed | Passed | 16 sampling checks + rotation/resume |
| 15 | 35 | Passed | Passed | 16 sampling checks + rotation/resume |
| 16 | 36 | Passed | Passed | 16 sampling checks + rotation/resume |

- API 24/25/35/36 ran in isolated ARM64 AVDs with Android Emulator 37.2.13. API 34 used the existing Pixel 3a ARM64 emulator.
- API 35/36 exercised the edge-to-edge layout with target SDK 36. The fixture draws image content behind the status bar.
- Supported-platform checks cover dark/light image replacement, animated scrolling, six repeated image changes, override recovery, modal images/scrolling and recovery after dismissal. The sampled decision and OS-reported style must agree, with successful samples and zero capture failures.
- API 24–25 checks cover the system-theme default, explicit dark/light fallback, override precedence and recovery, disable/re-enable, modal dark/light fallback and recovery, hybrid/manual hints and automatic hint exclusion. They require zero samples, `supported=false` and `sampling=false`.
- Each run then verifies app-observed landscape, portrait and background/foreground transitions, with correct native icon appearance after each. The driver restores the previous rotation settings.
- Screenshots were inspected for icon contrast and landscape geometry. Automated contrast assertions read the native OS appearance flag; they are not screenshot recognition.
- 27 JavaScript tests passed. TypeScript validation passed. 28 Kotlin core tests passed, including four new fallback tests.
- Debug and Release native consumer builds passed with the final fallback and paused-configuration changes.

### Scope and remaining checks

- **Physical Android device: not run.** No physical Android phone was connected. OEM-specific behavior and real-device performance remain unverified.
- **Hosted GitHub Actions: validation in progress.** The first run stopped during SDK setup because an action requested the removed legacy `tools` package. The workflow now explicitly installs `platform-tools`; consult the hosted run for the final release commit. Local ARM64 success does not establish the hosted x86_64 runner result.
- **Production signing/store bundle: not run.** This is a release-mode test consumer, not a signed Skyvist production release.
- **Current Skyvist integration:** the published 0.1.5 library passed its existing 16 checks in a freshly built RN 0.88.1 Skyvist Debug app on API 34 before these changes. The new changes were tested in the isolated consumer; Skyvist source, dependencies and iOS work were left unchanged.
- **iOS/SwiftPM/Expo:** not revalidated in this Android task. Historical iOS evidence is retained below; no Expo compatibility claim is made.
- This is functional emulator validation, not certification of camera/SurfaceView, native SDK windows, battery usage or production frame-time performance.

The driver saves screenshots, accessibility XML, logcat and `result.json` per run. See [the fixture guide](tests/android/README.md) to reproduce the checks and [the workflow](.github/workflows/android-integration.yml) for the proposed hosted matrix.

### Harness fixes during validation

- Closed an existing Mobile Dev accessibility session before running the separate UIAutomator-based driver.
- Fixed an intermittent rotation-driver issue by re-locking automatic rotation immediately before each requested orientation. Final reruns passed.
- Used the already-installed Gradle 9.3.1 for offline Kotlin core tests after the wrapper's network download failed. This did not change the test sources or Gradle version.

---

## Initial integration validation — 2026-11-08

React Native 0.86 / New Architecture, without Expo runtime.

- 27 JavaScript tests passed.
- 24 Swift core tests passed.
- 24 Kotlin core tests passed.
- iOS Debug simulator build passed (iPhone 17, iOS 27).
- Android Debug arm64 build passed (Pixel 3a emulator, Android 14/API 34).
- 16 integration checks passed on each platform: dark/light WebP replacement, animated scrolling, repeated image changes, override recovery, React Native Modal images/scrolling and recovery after dismissal.
- Integration checks compared sampled style, system-reported style, pixel lightness and capture failures. Screenshots confirmed the displayed icon contrast.

This is functional validation on simulators/emulators, not physical-device or release performance certification. The integration harness belongs to the consuming application and is not required to install this library. Refer to README for limitations around native SDK windows, Android API 24–25, SurfaceView video and iOS camera/Metal/Skia layers.
