# @skyvist/adaptive-status-bar

Keep status-bar icons readable as images, screens and scroll positions change. A native controller measures the content behind the status bar and chooses white or dark icons, without per-frame JavaScript work.

Built for React Native's **New Architecture**. No Expo runtime or Expo Modules dependency.

> **Prepared for 0.2.0:** Expo SDK 58 native support, theme-based Android 7 fallback and Android integration CI. Publication is pending. See [release notes](CHANGELOG.md#020---unreleased) and [verification results](VALIDATION.md).

## Contents

- [Requirements](#requirements)
- [Install](#install)
- [Expo SDK 58](#expo-sdk-58)
- [Enable once at the root](#enable-once-at-the-root)
- [Screen overrides and hints](#screen-overrides-and-hints)
- [Android 7 fallback](#android-7-fallback)
- [Configuration](#configuration)
- [API and diagnostics](#api-and-diagnostics)
- [Platform behavior and limits](#platform-behavior-and-limits)
- [Testing and CI](#testing-and-ci)
- [Swift Package Manager](#swift-package-manager)

## Requirements

| Target | Support |
| --- | --- |
| React Native | `>=0.86`, New Architecture; integration tested with RN 0.88.1 |
| Android 8+ / API 26+ | Automatic sampling with PixelCopy |
| Android 7 / API 24–25 | Fallback, hints and overrides; no pixel sampling |
| iOS | iOS 15.1+; Xcode 26+ for the typed Liquid Glass sampler |
| Expo Go | Unsupported: the native module is not included in Expo Go |
| Expo development builds | SDK 58 / RN 0.88 native integration verified; unreleased, see limits below |
| Web | Unsupported; importing the package requires its native TurboModule |

Your application's React Native version and build tools may impose higher platform requirements. A compatible peer dependency is not a promise that every future RN release has been tested.

## Install

After 0.2.0 is published, install the package and commit your lockfile. Until then, use a local npm-packed archive from this branch:

```sh
npm install --save-exact @skyvist/adaptive-status-bar@0.2.0
```

### Android

React Native autolinking handles the native module. Rebuild the app after installing or updating it:

```sh
npx react-native run-android
```

The library controls **icon appearance**, not your layout. Configure edge-to-edge and safe-area handling in your app so the intended content is actually behind the status bar.

### iOS with CocoaPods

```sh
cd ios && pod install
```

Set `UIViewControllerBasedStatusBarAppearance` to `YES` in `Info.plist`:

```xml
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>
```

In your existing app delegate, import the module and return its root view controller from the React Native factory delegate:

```swift
import SkyvistAdaptiveStatusBar

final class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
  override func createRootViewController() -> UIViewController {
    AdaptiveStatusBarViewController()
  }
}
```

Keep your delegate's other methods and app setup. Rebuild the native app. Hot reload alone cannot install the module or change the root controller.

The npm package includes TypeScript source for Metro and native source for autolinking/codegen. It has no install/prepare hook and does not need its own development dependencies in a consuming app.

## Expo SDK 58

Expo support is currently **unreleased**, targeting SDK 58 and React Native 0.88.
Use a local tarball built from this branch until a release includes these changes.
SDK 57 and older are not supported by this integration. Expo Go is not supported.

Install the package and `expo-dev-client`, then add the config plugin:

```json
{
  "expo": {
    "plugins": ["@skyvist/adaptive-status-bar"]
  }
}
```

Generate/rebuild your native application:

```sh
npx expo prebuild
npx expo run:ios
# or:
npx expo run:android
```

Commit or back up existing native edits before running prebuild. Existing native
projects can run the plugin through their normal prebuild workflow; do not use
`--clean` unless you intend to regenerate those native directories.

**Do not apply the bare React Native root-controller replacement above to Expo.**
The plugin enables controller-based appearance in Info.plist. The native adapter
uses React Native 0.88's public appearance state, which Expo's own root controller
already reads. AppDelegate, SceneDelegate, Expo handlers, hidden status-bar state
and development-client mounting are left intact. Android uses normal Expo native
autolinking and requires no library-specific MainActivity edits.

Use the same root enable/disable API below. Remove competing `expo-status-bar`,
React Native `StatusBar` components and navigator style overrides. A custom root
controller or modal that owns its own status-bar style may need app-specific
integration. Web imports remain unsupported, so isolate this module from web entry
points rather than importing it unconditionally.

With Expo's floating development-menu button visible, UIKit can report the
symbolic default style instead of an explicit light/dark style. In that case
`observedStyle` may be absent; this is not counted as a confirmed external write.
The app window is still sampled. The development menu itself owns its overlay
while open, so assess app colors after closing it.

Validation is tracked in [VALIDATION.md](VALIDATION.md). Prebuild/autolinking
success alone does not prove simulator, device or release-build behavior.

## Enable once at the root

Mount one owner for the controller. Remove competing React Native `StatusBar` components and navigator status-bar style overrides.

```tsx
import { useEffect, type PropsWithChildren } from 'react';
import { AdaptiveStatusBar } from '@skyvist/adaptive-status-bar';

export function StatusBarRoot({ children }: PropsWithChildren) {
  useEffect(() => {
    AdaptiveStatusBar.enable({
      strategy: 'automatic',
      performance: 'responsive',
      idleInterval: 0,
    });
    return () => AdaptiveStatusBar.disable();
  }, []);

  return children;
}
```

Wrap your navigator or application tree in `StatusBarRoot`. Native draw/lifecycle events drive sampling; do not call diagnostics on every frame.

- `light` means **white icons**, suitable for dark content.
- `dark` means **dark icons**, suitable for light content.

## Screen overrides and hints

Use an override for camera, video or other content that cannot be sampled reliably. Only focused screens should own an entry:

```tsx
import { useIsFocused } from '@react-navigation/native';
import { useStatusBarOverride } from '@skyvist/adaptive-status-bar';

function PhotoScreenStatusBar() {
  const isFocused = useIsFocused();
  useStatusBarOverride(isFocused ? 'light' : null);
  return null;
}
```

Render `<PhotoScreenStatusBar />` inside the screen that needs white icons.

Hooks release their entries on cleanup. Pass `null` when a mounted screen loses focus. Entries are stacked, so removing the current one reveals the previous one.

| Strategy | Decision order |
| --- | --- |
| `automatic` | Override → sampled content → fallback; hints are ignored |
| `hybrid` (default) | Override → hint → sampled content → fallback |
| `manual` | Override → hint → fallback; sampling is off |

Use `useStatusBarHint(styleOrNull)` when a screen knows its background and the controller uses `hybrid` or `manual` mode. An imperative override is also available:

```ts
AdaptiveStatusBar.setOverride('light');
// Later, release only the imperative override:
AdaptiveStatusBar.clearOverride();
```

## Android 7 fallback

**New in 0.2.0:** on API 24–25, the controller uses an explicit `fallbackStyle`, or derives an initial/default style from the Android window's UI mode:

- Light UI mode → dark icons.
- Night UI mode → white icons.
- Overrides and eligible hints still take priority.

This does **not** inspect the image or infer a custom JavaScript theme. For a custom theme, pass the matching fallback when enabling the controller and update it when your theme changes:

```ts
AdaptiveStatusBar.configure({
  fallbackStyle: isDarkTheme ? 'light' : 'dark',
});
```

Window draw/focus and app lifecycle events refresh the fallback, including React Native modal transitions. There is no PixelCopy request, sampling worker or periodic polling on API 24–25. Diagnostics report `supported: false`, `sampling: false`, zero samples and `source: 'fallback'` unless a hint or override owns the style.

Published `0.1.5` already accepts explicit fallbacks/hints/overrides on these APIs, but leaves the style alone when none is supplied.

## Configuration

`enable(options)` starts with a fresh configuration. `configure(partialOptions)` merges into the current configuration, including nested `ios` options.

### Sampling presets

Intervals are milliseconds. They are scheduling targets, not guaranteed frame rates.

| `performance` | Active | Back-off | Quiet | Idle fallback |
| --- | ---: | ---: | ---: | ---: |
| `battery` | 250 | 1000 | 3000 | 0 |
| `balanced` (default) | 100 | 300 | 900 | 0 |
| `responsive` | 50 | 150 | 300 | 2000 |

Set `idleInterval: 0` to disable idle polling, including with `responsive`.

### Options

| Option | Default | Purpose |
| --- | --- | --- |
| `strategy` | `hybrid` | Choose automatic, hint-assisted or manual behavior |
| `performance` | `balanced` | Select the interval preset above |
| `samplingInterval` | Preset | Fastest sampling interval, 16–10000 ms |
| `maxInterval` | Preset | Back-off interval; at least `samplingInterval` |
| `quietInterval` | Preset | Quiet-content interval; at least `maxInterval` |
| `idleInterval` | Preset | `0` disables it; otherwise at least 100 ms |
| `hysteresis` | `true` | Reduce switching near ambiguous contrast; also accepts custom thresholds |
| `confirmSamples` | `2` | Consecutive confirming samples, integer 1–10 |
| `minTransitionInterval` | `250` | Minimum interval between switches, ms |
| `animation` | `true` | iOS appearance animation; Android switches immediately |
| `fallbackStyle` | See below | Used when no higher-priority decision exists |
| `ios.captureMethod` | `layer` | `hierarchy` captures UIKit effects at higher cost |

Default hysteresis thresholds are `darkThreshold: 0.42` and `lightThreshold: 0.58` on the normalized CIE lightness scale. Use `false` to switch at the midpoint or pass both custom thresholds.

On iOS and Android API 26+, an omitted fallback leaves appearance unchanged until another source decides. The API 24–25 behavior is described above. Full types and validation bounds are in [types.ts](src/types.ts) and [config.ts](src/config.ts).

## API and diagnostics

| API | Purpose |
| --- | --- |
| `enable(config?)` | Enable the shared native controller |
| `configure(partialConfig)` | Merge configuration; paused Android controllers apply it on resume |
| `disable()` | Stop work and release resources; this is not a request to restore a previous icon style |
| `setOverride(style)` / `clearOverride()` | Set or clear the imperative override |
| `setHint(styleOrNull)` | Set or clear the imperative hint |
| `getStats()` | Read asynchronous native diagnostics |
| `resetStats()` | Clear diagnostic counters |
| `isEnabled` / `config` | Read JavaScript-side state |

```ts
const stats = await AdaptiveStatusBar.getStats();
console.log({
  decision: stats.style,
  actualAppearance: stats.observedStyle,
  source: stats.source,
  samples: stats.samples,
  failures: stats.failures,
});
```

`observedStyle` reads the active system appearance, separately from the sampled decision. `externalWrites` can reveal another status-bar owner. Capture/main-thread timing is useful for investigation, but a short debug-emulator run is not a production performance benchmark.

If the module is missing, rebuild the native app and check autolinking. If iOS appearance never changes, check the root-controller and Info.plist setup. If the icons keep switching back, remove competing owners before increasing sampling frequency.

## Platform behavior and limits

### Android

PixelCopy reads a small status-bar strip; analysis runs on a worker. Only one copy can be in flight. Generation/window checks prevent stale callbacks from applying to an old window. Appearance uses `WindowInsetsControllerCompat`.

The adapter follows activity and public React Native modal dialog windows. Backgrounding pauses work; foregrounding resumes it. Closing a React Native modal returns control to the activity window.

- Native SDK windows outside the React view tree own their own appearance.
- SurfaceView video is not reliably capturable; use an override. TextureView content can be sampled.
- API 24–25 uses fallback behavior, never simulated pixel measurements.

### iOS

The root controller implements `preferredStatusBarStyle` and requests appearance updates without deprecated UIApplication setters or method swizzling. Contained navigation screens share that owner. Presentation-layer sampling follows animation positions.

- Standard transparent React Native modals are sampled in the same window.
- Full-screen native SDK controllers must manage or forward their own status-bar appearance.
- Camera, Metal/Skia and video layers cannot be reliably sampled with Core Animation; use an override.
- Blur approximation has limits. `ios.captureMethod: 'hierarchy'` may improve results at a higher rendering cost.

## Testing and CI

Run these commands from a checkout of this repository:

```sh
npm ci
npm test
npm run typecheck
npm run test:android
npm run test:ios       # macOS + Xcode
npm run test:spm       # separate RN 0.88.1 SwiftPM consumer
npm pack --dry-run
```

The [Android integration consumer](tests/android/README.md) installs an npm-packed copy of the library into an isolated RN 0.88.1 app. It bundles JavaScript in both Debug and Release, needs no Metro/backend/account, and carries the original 16 Skyvist image/scroll/modal checks plus lifecycle assertions. API 24–25 instead runs 14 fallback checks.

```sh
# An explicitly selected emulator/device; use x86_64 for Linux emulators.
ANDROID_HOME="$HOME/Library/Android/sdk" \
ANDROID_TEST_ABI=arm64-v8a ANDROID_SERIAL=emulator-5554 \
npm run test:android:integration
```

Without `ANDROID_SERIAL`, this command builds both APKs only. The fixture uses the package ID `com.helloworld`; do not install it over an unrelated app with that ID. Release test APKs use a disposable debug key, not production signing credentials.

The new CI workflow targets API 24, 25, 35 and 36, tests both build variants, and retains screenshots, accessibility XML, logs and result JSON. Local emulator results and remaining physical-device/hosted-CI gaps are recorded in [VALIDATION.md](VALIDATION.md). A configured matrix is not evidence of a completed hosted run.

## Swift Package Manager

CocoaPods is the default. The package also supports React Native's **SwiftPM preview**, verified separately with RN 0.88.1.

For an app already configured for that preview:

```sh
cd ios
npx react-native spm
```

Run RN's SwiftPM setup on fresh CI checkouts too. It generates app-local React headers/codegen and autolinks the hand-authored `Package.swift`, which separates the Swift implementation from the Objective-C++ adapter.

Installing this dependency does not convert an app to SwiftPM. Do not manage React Native with CocoaPods and SwiftPM simultaneously. A remote GitHub Swift package URL alone is insufficient: the npm package and app-specific React Native codegen are still required. See [RN's setup guide](https://github.com/react/react-native/blob/v0.88.1/packages/react-native/scripts/spm/__docs__/spm-scripts.md) and [manifest contract](https://github.com/react/react-native/blob/main/packages/react-native/scripts/spm/__docs__/spm-header-paths-contract.md).

### Xcode Cloud

Pin the npm version and commit the lockfile. For CocoaPods, run `npm ci` before `pod install` in `ci_post_clone.sh` and commit `Podfile.lock`. For SwiftPM preview, run RN's SwiftPM setup instead of RN's CocoaPods installation. Public npm installation needs no npm login or GitHub token. A new release does not change an app pinned to an earlier version.

## Credits and license

Adapted from [rbayuokt/expo-adaptive-status-bar](https://github.com/rbayuokt/expo-adaptive-status-bar), commit `151fdc6b8c9ff172a95fab6ece65c6814c19d9bd` (0.1.2). The upstream MIT copyright/license, contrast analysis, scheduling and hysteresis are retained. This project maintains the platform adapters and React Native integration. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
