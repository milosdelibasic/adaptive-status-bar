// swift-tools-version: 6.0
import PackageDescription

// React Native resolves this manifest through ios/build/generated/autolinking/libs/<name>.
// Its setup command creates both app-local packages on a fresh checkout.
let package = Package(
    name: "SkyvistAdaptiveStatusBar",
    platforms: [.iOS("15.1")],
    products: [
        .library(
            name: "SkyvistAdaptiveStatusBar",
            targets: ["SkyvistAdaptiveStatusBar", "SkyvistAdaptiveStatusBarReactNative"]
        ),
    ],
    dependencies: [
        .package(name: "ReactNative", path: "../../../../xcframeworks"),
        .package(name: "React-GeneratedCode", path: "../../../ios"),
    ],
    targets: [
        .target(
            name: "SkyvistAdaptiveStatusBar",
            path: "ios",
            exclude: ["Tests", "SPM", "SkyvistAdaptiveStatusBar.h", "SkyvistAdaptiveStatusBar.mm"],
            swiftSettings: [.define("RCT_NEW_ARCH_ENABLED")],
            linkerSettings: [.linkedFramework("UIKit"), .linkedFramework("QuartzCore")]
        ),
        .target(
            name: "SkyvistAdaptiveStatusBarReactNative",
            dependencies: [
                "SkyvistAdaptiveStatusBar",
                .product(name: "ReactHeaders", package: "ReactNative"),
                .product(name: "ReactNativeHeaders", package: "ReactNative"),
                .product(name: "ReactNativeDependenciesHeaders", package: "ReactNative"),
                .product(name: "ReactAppHeaders", package: "React-GeneratedCode"),
            ],
            path: "ios",
            exclude: ["Core", "Tests", "AdaptiveStatusBarBridge.swift", "AdaptiveStatusBarController.swift",
                      "AdaptiveStatusBarViewController.swift", "ControllerConfigRecord.swift",
                      "StatusBarSampler.swift", "StripRenderer.swift"],
            sources: ["SkyvistAdaptiveStatusBar.mm", "SPM/SkyvistAdaptiveStatusBarImplementation.m"],
            publicHeadersPath: "SPM/include",
            cSettings: [.define("RCT_NEW_ARCH_ENABLED", to: "1"), .define("SKYVIST_SPM", to: "1")],
            cxxSettings: [
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                .define("SKYVIST_SPM", to: "1"),
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release)),
            ],
            linkerSettings: [.linkedFramework("Foundation")]
        ),
    ],
    swiftLanguageModes: [.v5],
    cxxLanguageStandard: .cxx20
)
