# Changelog

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
