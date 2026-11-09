# Expo Android validation: 2026-11-09

## Tested stack

- Expo 58.0.23, expo-dev-client 58.0.18, React Native 0.88.1, React 19.3.0.
- Local unpublished @skyvist/adaptive-status-bar 0.1.6 feature archive.
- Java 17, Gradle 9.4.1, ARM64 Android emulators API 35 and API 36.
- Expo-generated native project, new architecture, Hermes and edge-to-edge enabled.
- Debug retained Expo development launcher and Metro. Release used its bundled
  production JavaScript and Expo template's R8 minification.

## Results

| OS | Variant | Native assertion suite | Rotation + resume |
| --- | --- | --- | --- |
| API 35 | Debug development client | PASS:16 | PASS |
| API 35 | Release | PASS:16 | PASS |
| API 36 | Debug development client | PASS:16 | PASS |
| API 36 | Release | PASS:16 | PASS |

All four results were verified as exact visible test result text through Mobile
Dev's device tools. The fixture checks sampled image contrast, changing images,
scrolling, overrides, React Native modals and restoration after modals. Lifecycle
PASS requires landscape, return to portrait, background, resume and a fresh check
of native observed icon style. No network-loaded test images are used.

The orientation tool reported its dispatch as unconfirmed; the fixture itself
confirmed the geometry changes. In API 35 Release, the intermediate wait for
portrait JSON timed out; the subsequent final lifecycle PASS was separately
verified and requires the portrait event. The transient JSON text is not treated
as proof on its own.

Expo's first-run development-menu onboarding was dismissed normally on both
Debug runs. The unrelated API 34 emulator and user Skyvist app were not touched.
No physical device or Expo Go runtime was tested.

## Build and provenance

Clean Expo Android prebuild and Expo autolinking succeeded. The generated package
list includes SkyvistAdaptiveStatusBarPackage and the new-architecture codegen
CMake path. Both variants compiled successfully: 1032 tasks, 5m 11s on this host.
Initial dependency-resolution failures came from stale Gradle/network-proxy
configuration and were resolved with a fresh authorized Gradle process; no native
library change was needed.

Debug APK SHA-256:
`b78f76c7f77e77f747ef9939aff282b6bf61ef599cdec651f512c36b04089969`

Release APK SHA-256:
`76ff7ee38670a0957812491dd815b0db6be902d576f07e8289eb6a69a8219783`

The final refreshed feature archive changed iOS/plugin/documentation files. Its
Android and TypeScript source trees were compared against the tested installation
and are identical (ignoring generated Android build output). The refreshed archive
was then installed and `expo config --type introspect --json` succeeded with the
plugin registered for SDK 58.

Local evidence, not committed build artifacts:

- `/tmp/asb-expo-android/build.log`
- `/tmp/asb-expo-android/prebuild.log`
- `/tmp/asb-expo-android/android-autolinking.json`
- `/tmp/asb-expo-android/metro.log` (per-check native statistics for Debug)
- `/tmp/asb-expo-android/debug35-snapshot.json`
- `/tmp/asb-expo-android/release35-snapshot.json`
- `/tmp/asb-expo-android/debug36-snapshot.json`
- `/tmp/asb-expo-android/release36-snapshot.json`
- `/tmp/asb-expo-android/android/app/build/outputs/apk/`

The fixture reuses `tests/android/App.tsx`; see the adjacent README for reproduction.
