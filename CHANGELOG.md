# Changelog

## 0.2.0 - 2026-11-09

### Expo support

- Add Expo SDK 58 / React Native 0.88 native development-build and prebuild support, with a packaged config plugin and installed-SDK validation.
- Integrate with React Native's public iOS appearance state without replacing Expo root controllers, scene delegates, hidden-state APIs or development-client lifecycle.
- Keep Expo optional for bare React Native users. Expo Go and web remain unsupported.

### Android improvements

- Add deterministic API 24–25 fallback using the window's Android UI mode, while preserving explicit fallback, override and hint precedence.
- Refresh fallback on draw, focus, modal and lifecycle changes without unsupported pixel sampling or periodic polling.
- Preserve honest unsupported-platform diagnostics and defer configuration appearance changes while paused.
- Cache RGB channel weights in the luminance analyzer with bit-identical output. Paired Android ART microbenchmarks show lower analyzer-only time; this is not an application FPS or battery-life claim.

### iOS reliability

- Restore shared appearance after a competing React Native style write without redundant root invalidations.
- Protect replacement controllers from delayed cleanup by an older bridge.
- Avoid false external-write counts when UIKit reports an ambiguous default style around Expo development overlays.
- Keep paused configuration changes inactive until resume and ignore already-queued sampling callbacks after sampling stops.

### Configuration and unnecessary work

- Reject malformed JavaScript configuration before native dispatch, using consistent RangeError errors and preserving current configuration on failed updates.
- Preserve stored hints without restarting sampling when automatic mode ignores them or an override takes priority.
- Retain the existing Swift luminance implementation after measurements showed no benefit from the proposed weighted-table optimization.

### Tests and CI

- Add exhaustive Android RGB parity checks, reproducible paired benchmarks and targeted native lifecycle regressions.
- Add config-plugin, appearance-state and controller regression checks to CI.
- Add an API 24/25/35/36 Android Debug/Release integration matrix with screenshots, accessibility XML, logcat and JSON artifacts.
- Add isolated Expo Android and iOS fixtures covering sampling, overrides, modals, rotation, resume and development-client reloads.

### Documentation

- Rewrite README around installation, root ownership, Expo setup, overrides, fallback, configuration and troubleshooting.
- Record measurements and test scope separately from untested physical-device, EAS and production-signing behavior.
- Keep release notes grouped by feature and provide reproducible validation evidence.

Physical-device testing remains pending.

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
