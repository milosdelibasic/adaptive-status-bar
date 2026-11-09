# Expo iOS validation — 2026-11-09

Environment: Expo 58.0.23, React Native 0.88.1, React 19.3.0,
expo-dev-client 58.0.18, Xcode 27, iPhone 17 Pro Max simulator on iOS 27.

- SDK 58 prebuild succeeded twice; native autolinking found the library pod.
- Actual Expo plugin introspection set controller-based appearance to true.
- CocoaPods installation succeeded.
- Release and Debug simulator builds succeeded.
- Release: white background/dark icons and black background/light icons were
  verified visually and through native observedStyle, with zero capture failures.
- Release: explicit light override stopped sampling; clearing it restored
  automatic dark icons on white and resumed sampling.
- Release: Home/foreground resumed sampling in the same app process.
- Debug: the actual development client loaded the fixture from Metro.
- Debug: a full-screen dark React Native modal displayed white status-bar icons;
  dismissal restored dark icons on the white root.
- Debug: React Native StatusBar.setHidden(true/false) remained effective.
- Debug: actual application geometry changed from 440×956 to 956×440 and back.
  iOS hid the status bar in landscape; this is not a landscape icon-color claim.
- Debug: three explicit JavaScript reload cycles completed and returned to
  dark icons on the white root. Black/white adaptation also worked after opening
  the Expo development menu.

## Development overlay diagnostics

A temporary consumer-only native probe confirmed the normal app UIWindow remained
key (level 0), while Expo's floating-button window was non-key (level 999).
The scene's statusBarManager reported raw style 0 (`default`) despite correct
visible colors. The library therefore no longer counts that ambiguous value as
a confirmed external write. It does not infer a light/dark observedStyle from
`default`. Sampling still uses the application key window. Repeated unchanged
styles do not re-invalidate the root, and the RN adapter calls the shared-state
setter only when its value differs.

The probe is not part of the library or fixture. Assess application icon colors
after dismissing the development menu, whose own window controls its presentation.

## Limits

No physical iPhone, EAS cloud build, Expo Router-specific navigator fixture,
or Expo SDK 57 compatibility was tested. Expo Go remains unsupported.
Native reload ownership and unknown/default diagnostics are also covered by
the executable appearance regression seam, which is not a UIKit runtime test.
