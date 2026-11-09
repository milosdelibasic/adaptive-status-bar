# Expo iOS validation fixture

Use an isolated SDK 58 app with Expo 58.0.23, React Native 0.88.1,
React 19.3.0 and expo-dev-client 58.0.18. Install a tarball produced by
`npm pack` from this repository, not the prepared 0.1.6 release baseline, which does
not contain the unreleased Expo integration.

1. Copy this directory's `index.js` into the consumer and set its package
   `main` to `index.js`.
2. Add `@skyvist/adaptive-status-bar` to `expo.plugins` in app.json.
3. Set a distinct bundle identifier and app name, then run
   `npx expo prebuild --platform ios --no-install` and `cd ios && pod install`.
4. Build Debug and Release using the generated workspace/scheme and an isolated
   derived-data directory. Use a separately selected simulator; do not replace
   another application's running test session.
5. On the white screen, confirm dark icons. Tap Toggle background and confirm
   white icons over black. Verify Force light icons and Automatic icons.
6. Test background/resume, rotation, reload in the development client, and a
   modal that inherits the root appearance. Check stats and visually inspect
   icons, not only a successful JavaScript/module load.

No AppDelegate or SceneDelegate patch is expected. Confirm Info.plist has
`UIViewControllerBasedStatusBarAppearance=true`. A successful prebuild or build
is not runtime evidence; record exactly which checks were actually performed.

The fast native regression seam is `sh scripts/test-ios-appearance.sh`.
It executes the actual appearance-state implementation with minimal UIKit
stand-ins, covering notification correction and stale-owner teardown. It is
not a UIKit or device test.
