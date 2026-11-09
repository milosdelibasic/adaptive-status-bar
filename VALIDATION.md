# Verification

## Unreleased Expo integration, 2026-11-09

Tested an npm-packed feature build with Expo 58.0.23, React Native 0.88.1,
React 19.3.0 and expo-dev-client 58.0.18. This is a native development/prebuild
integration, not Expo Go. The version field remains 0.1.6 during development;
the prepared 0.1.6 release baseline does not contain these Expo changes.

### Build and regression checks

- Clean bare-RN library development installation passed without installing Expo.
- 27 JavaScript tests, TypeScript validation and 5 config-plugin tests passed.
- 24 Swift core tests passed. The executable appearance-state regression seam
  passed correction of a competing RN style, redundant-invalidation avoidance,
  replacement-controller ownership and idempotent teardown. The seam executes
  the real Swift state implementation with UIKit stand-ins, not a device UI.
- SwiftPM RN 0.88.1 consumer passed Debug simulator and unsigned Release iOS
  builds with the changed Swift/ObjC++ source. RN 0.86 was not rebuilt in this
  Expo task; the older-header path remains compile-time guarded.
- Actual Expo prebuild and native autolinking passed on both platforms. Repeated
  iOS prebuild passed and plist introspection confirmed controller-based status
  bar appearance. No AppDelegate, SceneDelegate or root-controller replacement
  was applied.

### Android Expo runtime

| Android | Debug development client | Production-mode Release |
| --- | --- | --- |
| 15 / API 35 | 16 checks + lifecycle passed | 16 checks + lifecycle passed |
| 16 / API 36 | 16 checks + lifecycle passed | 16 checks + lifecycle passed |

- ARM64 emulators, Expo-generated project, Hermes/New Architecture and
  edge-to-edge. Debug retained the genuine Expo development launcher and Metro;
  Release used bundled JavaScript and R8 with the fixture's test signing key.
- Each run checked changing images, scrolling, repeated changes, overrides,
  modal content and recovery, then app-observed landscape/portrait and
  background/resume with native style assertions.
- Final packaged Android/TypeScript source was compared byte-for-byte with the
  tested installation. Final plugin introspection also passed.
- See [the Expo Android fixture and detailed results](tests/expo/android/RESULTS.md).

### iOS Expo runtime

- iPhone 17 Pro Max simulator, iOS 27, Xcode 27. Final Debug and Release
  simulator builds passed with the unchanged Expo root/scene integration.
- Release runtime verified white/black adaptation visually and via native style,
  override/reset and background/resume, with zero capture failures.
- Genuine Debug development client verified modal open/close, hidden-status-bar
  APIs, actual landscape/portrait geometry and three JavaScript reload cycles.
  iOS hides the status bar in landscape, so this is not a landscape icon-color
  verification.
- A temporary consumer-only probe confirmed Expo's floating dev button does not
  replace the application key window. UIKit can report ambiguous `.default`
  despite correct visible colors. This is no longer counted as a confirmed
  external style write; final Debug runtime retained correct icons, zero capture
  failures and zero false external writes. The probe was removed.
- The final diagnostics-only change was rebuilt in both variants and exercised
  in Debug. Earlier Release runtime results cover the same appearance behavior.
- See [the detailed iOS fixture results](tests/expo/ios/RESULTS.md).

### Limits

- No physical device, EAS cloud build, Expo Router-specific navigator fixture,
  Expo Go, web or other Expo SDK was tested.
- Expo changes have not been pushed or run in hosted CI. The local plugin and
  appearance tests are wired into Library checks for the next pushed commit.
- This is not a production-signed Skyvist release or a performance certification.

---

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
- **Hosted GitHub Actions: passed on `59c85a9`.** [Android integration run 42619669416](https://github.com/milosdelibasic/adaptive-status-bar/actions/runs/42619669416) passed Debug and Release on API 24/25 (14 checks plus lifecycle per variant) and API 35/36 (16 checks plus lifecycle per variant), using hosted x86_64 emulators. Evidence artifacts were uploaded for all four API jobs. [Library checks run 42619669320](https://github.com/milosdelibasic/adaptive-status-bar/actions/runs/42619669320) passed JavaScript, Kotlin, Swift core and the SwiftPM consumer. Initial SDK setup and shell-loop failures were fixed before this successful run. These results establish the Android release baseline, not subsequent Expo changes.
- **Production signing/store bundle: not run.** This is a release-mode test consumer, not a signed Skyvist production release.
- **Current Skyvist integration:** the published 0.1.5 library passed its existing 16 checks in a freshly built RN 0.88.1 Skyvist Debug app on API 34 before these changes. The new changes were tested in the isolated consumer; Skyvist source, dependencies and iOS work were left unchanged.
- **iOS/SwiftPM/Expo:** not revalidated in this Android task. Historical iOS evidence is retained below; no Expo compatibility claim is made.
- This is functional emulator validation, not certification of camera/SurfaceView, native SDK windows, battery usage or production frame-time performance.

The driver saves screenshots, accessibility XML, logcat and `result.json` per run. See [the fixture guide](tests/android/README.md) to reproduce the checks and [the workflow](.github/workflows/android-integration.yml) for the hosted matrix.

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
