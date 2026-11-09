# Android integration consumer

This fixture installs an **npm-packed** library into a minimal React Native 0.88.1 app. It does not use Skyvist, credentials, a backend, Metro, or any private dependency. Debug and Release both embed the same JS bundle. Release uses the disposable template debug signing key solely to install this test app; it is not production signing.

## Run

Install Node 24, JDK 17, Android SDK platform/build tools 37, NDK 27.1.12297006, and CMake 3.22.1. Boot/select an emulator, then:

```sh
ANDROID_HOME="$HOME/Library/Android/sdk" \
ANDROID_TEST_ABI=arm64-v8a ANDROID_SERIAL=emulator-5554 \
ANDROID_INTEGRATION_WORK=/tmp/asb-integration \
sh scripts/test-android-integration.sh
```

Use `x86_64` for Linux CI emulators. Without `ANDROID_SERIAL`, the script builds both APKs and explicitly reports that runtime checks were not run. The working directory and evidence are retained. Use a new working directory when changing dependency versions.

For an existing build installed on an explicitly selected device:

```sh
python3 tests/android/run-device.py --serial emulator-5554 --output /tmp/asb-results
```

The driver launches **com.helloworld**, not Skyvist. Do not use a device where an unrelated app has that identifier. It temporarily disables automatic rotation, exercises landscape/portrait and Home/foreground, then restores the original rotation settings. No account or network access is needed. Evidence includes screenshots, accessibility XML, logcat and result.json.

## Assertions

- API 26+: the 16 image/scroll/modal/override-recovery checks originally used in Skyvist. Each requires the sampled decision to agree with the OS-reported icon appearance, a successful sample, and zero capture failures.
- API 24–25: 14 checks: system-theme default, explicit light/dark fallbacks, override precedence, recovery, disable/re-enable, React Native Modal recovery, hybrid/manual hints, and automatic hint exclusion, with sampling=false and zero samples.
- Both: subsequent landscape, portrait and background/foreground events must be observed by the app, and icon contrast must recover afterward.

The app draws edge-to-edge and targets API 36. The CI matrix covers API 24, 25, 35 and 36, both Debug and Release. Screenshots are retained for visual review; automated icon checks read the OS flag, not screenshot recognition. The suite does not certify physical-device performance, OEM behavior, camera/SurfaceView content, or native SDK-owned windows. CI results are only proven after the workflow actually runs.
