# Expo Android integration fixture

This fixture installs an unpublished `npm pack` archive into an isolated Expo 58
consumer. It exercises the same 16 native sampling/override/modal assertions as
`tests/android/App.tsx`, then verifies landscape, portrait and background/resume.
It does not use Expo Go or modify a user's existing application.

## Build

With Node 22+, Java 17 and Android SDK available:

```sh
ANDROID_HOME="$HOME/Library/Android/sdk" sh tests/expo/android/prepare.sh /tmp/asb-expo-android-new
```

The target must be new or an existing empty directory. Nonempty directories,
files and symlinks are refused before any writes to protect native edits.

The config plugin is included in `app.json`. Expo prebuild generates the native
project; do not copy a bare React Native template into it. Both APKs are ARM64 by
default (`ANDROID_TEST_ABI` overrides this). Release uses Expo's normal production
bundle and R8. Debug retains the real Expo development launcher and dev support.
The generated debug keystore is for isolated local testing only.

## Runtime verification

1. Select an API 35 or API 36 emulator with Mobile Dev, open its panel and boot it
   through Mobile Dev if necessary. Leave unrelated running applications alone.
2. Start Metro in the consumer: `npx expo start --dev-client --host localhost --port 8085`.
3. Install `android/app/build/outputs/apk/debug/app-debug.apk` using Mobile Dev.
4. Open `asb-expo-android://expo-development-client/?url=http%3A%2F%2F10.0.2.2%3A8085`
   on that emulator. Dismiss Expo's first-run development-menu onboarding if shown.
5. Use the device tools to wait for the exact visible text `PASS:16` in
   `integration-result`. A screenshot alone is not sufficient.
6. Rotate to landscape, wait for `lifecycle-result` to record `landscape:true`,
   rotate to portrait, and wait for `portrait:true`.
7. Go Home, foreground the same app without relaunching, and verify the exact
   lifecycle text `PASS`. These checks also re-read native observed icon style.
8. Capture evidence and restore portrait/automatic rotation as appropriate.
9. Close the test session, install the release APK, launch
   `com.skyvist.asbexpoandroid`, and repeat steps 5–8 without Metro.
10. Repeat on API 36. State actual OS/build combinations tested; never infer one
    variant's or OS version's result from another.

The original ADB runner in `tests/android/run-device.py` is for the self-contained
bare-RN fixture and hard-codes its package name. Do not run it unchanged against
this consumer or treat its results as Expo evidence.
