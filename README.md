# @skyvist/adaptive-status-bar

Autolinked React Native TurboModule (RN 0.86 / New Architecture). No Expo runtime, config plugin, or Expo Modules dependency.

Adapted from [rbayuokt/expo-adaptive-status-bar](https://github.com/rbayuokt/expo-adaptive-status-bar), commit `151fdc6b8c9ff172a95fab6ece65c6814c19d9bd` (0.1.2). The upstream MIT copyright and license are retained in LICENSE. Native contrast analysis, scheduling, hysteresis and their tests are retained. Platform adapters and the React Native integration are maintained here. See NOTICE for the changes.

## Installation

Download a tagged release or install this repository at a full commit SHA. For reproducible CI builds, use an HTTPS commit archive in package.json and commit package-lock.json:

```json
{
  "dependencies": {
    "@skyvist/adaptive-status-bar": "https://codeload.github.com/milosdelibasic/adaptive-status-bar/tar.gz/<FULL_COMMIT_SHA>"
  }
}
```

Run `npm install`, then `cd ios && pod install`, and rebuild your native apps. The package ships TypeScript source for Metro and native source for React Native autolinking/codegen. It has no install/prepare script and does not need its development dependencies when used by an app.

### Xcode Cloud

A public HTTPS archive requires no GitHub token, SSH key or Git submodule. Use `npm ci` in `ci_post_clone.sh` before `pod install`. The full commit SHA and lockfile integrity pin the dependency; a new commit in this repository does not automatically change consuming builds. Verify updates in an app build before changing the pinned SHA.

## Usage

Enable the controller once in your root component and disable it on unmount. Remove competing React Native StatusBar components and navigator style overrides.

Use automatic detection with the responsive preset and no idle polling so that a single native controller owns the icon style. Theme changes, image loads, scrolls and animations are measured natively; React does no per-frame work.

```tsx
import { AdaptiveStatusBar, useStatusBarOverride } from '@skyvist/adaptive-status-bar';

AdaptiveStatusBar.enable({ strategy: 'automatic', performance: 'responsive', idleInterval: 0 });
const stats = await AdaptiveStatusBar.getStats();
// In screens with non-capturable content, pass null while unfocused:
useStatusBarOverride(isFocused ? 'light' : null);
```

`light` means white icons; `dark` means dark icons. Hooks remove their entries on cleanup. `disable()` stops sampling and releases resources; `configure()` merges settings; `setOverride()`/`clearOverride()` temporarily bypass detection. Diagnostics are asynchronous, optional, and never polled in normal app use. `observedStyle` reports the actual active system appearance, separately from the sampled decision.

### iOS

Set `UIViewControllerBasedStatusBarAppearance` to `YES` in Info.plist. Import `SkyvistAdaptiveStatusBar` in your app delegate, and return its view controller from your factory delegate:

```swift
import SkyvistAdaptiveStatusBar

final class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
  override func createRootViewController() -> UIViewController {
    AdaptiveStatusBarViewController()
  }
}
```

The root controller owns the status bar for contained React Navigation screens. This uses `preferredStatusBarStyle` and `setNeedsStatusBarAppearanceUpdate`, without UIApplication's deprecated style setter or method swizzling. Contained React Navigation screens share that owner. Sampling renders a tiny strip using presentation layers, so it follows visual animation positions. Backgrounding pauses sampling; foregrounding resets it.

The standard transparent React Native modal is sampled in the same window. A separate full-screen native SDK controller controls its own status bar; it must implement/forward its own appearance. Video, Metal/Skia and camera layers cannot reliably be sampled by Core Animation; use a focused override for these. Blur approximation has the upstream limitations; `ios.captureMethod: 'hierarchy'` is available at a higher rendering cost.

### Android

PixelCopy reads the status-bar strip and analyses it on a worker thread. Appearance uses WindowInsetsControllerCompat. The adapter tracks public ReactModalHostView dialog windows as well as the activity window, attaching draw/focus observers to the active window. Closing a modal resumes sampling the activity. Native SDK windows outside the React view tree are owned by that SDK.

Only one GPU copy may be in flight, including across pauses/restarts. A stale callback cannot apply a decision from the previous window/configuration. Backgrounding pauses work and module invalidation releases listeners and the worker. PixelCopy requires API 26; on API 24–25 only hints/overrides/fallback style apply. SurfaceView video is not capturable; TextureView can be sampled.

## Development and verification

```sh
npm ci
npm test
npm run typecheck
npm run test:ios      # macOS with Xcode
npm run test:android  # JDK 17; Gradle wrapper included
npm pack --dry-run
```

JavaScript tests cover configuration, API behavior and override stacks. Swift and Kotlin suites each cover 24 contrast, hysteresis and scheduling cases. The package has been integrated and tested in a React Native 0.86 app on iOS 27 and Android 14. See VALIDATION.md for the initial integration evidence. Other React Native versions have not been verified.

A test consumer should exercise dark/light image replacement, animated scrolling, repeated changes, React Native Modal windows and recovery after modal dismissal. `getStats()` reports both the sampled decision and the system-reported icon appearance.
