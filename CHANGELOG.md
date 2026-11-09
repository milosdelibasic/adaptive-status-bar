# Changelog

## 0.1.6 - 2026-11-09

### Android behavior

- Add a deterministic API 24–25 fallback: dark icons in light UI mode and white icons in night mode when no explicit fallback is configured.
- Preserve explicit fallback, override and eligible hint precedence without attempting unsupported PixelCopy sampling.
- Refresh fallback appearance on window draw/focus and lifecycle events, including React Native modal transitions, without a sampling worker or periodic polling.
- Report unsupported sampling honestly: `supported=false`, `sampling=false` and zero samples on API 24–25.
- Prevent `configure()` from changing Android appearance while paused; apply the saved configuration on resume.

### Tests and CI

- Add four Kotlin fallback tests, bringing the core suite to 28 tests.
- Add an isolated RN 0.88.1 Android consumer that installs the npm-packed library and embeds its JS in both Debug and Release.
- Port the 16 Skyvist image, scroll, modal and override-recovery checks into the consumer.
- Add 14 API 24–25 fallback checks, including default theme, explicit style, hints, overrides and modal recovery.
- Verify landscape, portrait and background/foreground recovery through app-observed events and native appearance checks.
- Add an API 24/25/35/36 GitHub Actions matrix with screenshots, XML, logcat and JSON artifacts. The hosted workflow has not run yet.

### Documentation

- Reorganize the README around installation, a complete root-owner example, overrides/hints, fallback behavior, configuration and troubleshooting.
- Document Expo Go, web, native-window and capture limitations without implying untested compatibility.
- Record local Debug/Release emulator results separately from physical-device and hosted-CI verification.

Physical Android hardware testing remains pending.

## 0.1.5

- Add Swift Package Manager support for React Native’s preview through separate Swift and Objective-C++ targets.
- Keep CocoaPods and Android integration compatible with the existing RN 0.86 app.
- Publish public npm distribution under `@skyvist/adaptive-status-bar` with exact semantic versions.

## 0.1.3

- Resolve standalone test tooling through Maven Central’s direct repository endpoint before its alternate host.
- Native runtime and JavaScript API remain unchanged.

## 0.1.2

- Use the official Gradle setup action and cache for standalone Android CI; avoid duplicate CI runs for release tags.
- Native runtime and JavaScript API remain unchanged.

## 0.1.1

- Download the standalone Kotlin test runner from Gradle’s direct distribution host, verify its SHA-256 checksum, and allow slower initial downloads.
- Native runtime and JavaScript API are unchanged from 0.1.0.

## 0.1.0

- Initial React Native TurboModule adaptation without Expo Modules, with iOS controller-based appearance and Android modal-window tracking.
