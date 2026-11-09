#!/bin/sh
# Execute the actual appearance-state implementation with a minimal UIKit seam.
# This verifies ownership/notifications; it does not replace simulator validation.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cat > "$WORK/main.swift" <<'SWIFT'
import Foundation
enum UIStatusBarStyle: Int { case `default`, lightContent, darkContent }
final class Root {
  var invalidations = 0
  func setNeedsStatusBarAppearanceUpdate() { invalidations += 1 }
}
final class Window { let rootViewController = Root() }
final class Scene { let keyWindow = Window() }
enum StatusBarSampler {
  static let scene = Scene()
  static func activeScene() -> Scene? { scene }
}
enum UIView {
  static func animate(withDuration: Double, animations: () -> Void) { animations() }
}
SWIFT
sed -n '/^enum AdaptiveStatusBarAppearance/,$p' "$ROOT/ios/AdaptiveStatusBarViewController.swift" >> "$WORK/main.swift"
cat >> "$WORK/main.swift" <<'SWIFT'
assert(!AdaptiveStatusBarAppearance.isExplicitMismatch(nil, target: .lightContent))
assert(!AdaptiveStatusBarAppearance.isExplicitMismatch(.default, target: .lightContent))
assert(!AdaptiveStatusBarAppearance.isExplicitMismatch(.lightContent, target: .lightContent))
assert(AdaptiveStatusBarAppearance.isExplicitMismatch(.darkContent, target: .lightContent))
let old = UUID(), replacement = UUID()
var mirrored = UIStatusBarStyle.default.rawValue
var notifications = 0
let observer = NotificationCenter.default.addObserver(
  forName: Notification.Name("SkyvistAdaptiveStatusBarAppearanceDidChange"), object: nil, queue: nil
) { note in
  mirrored = note.userInfo!["style"] as! Int
  notifications += 1
}
AdaptiveStatusBarAppearance.claim(old)
AdaptiveStatusBarAppearance.apply(.lightContent, animated: false, owner: old)
assert(mirrored == UIStatusBarStyle.lightContent.rawValue)
let invalidations = StatusBarSampler.scene.keyWindow.rootViewController.invalidations
mirrored = UIStatusBarStyle.darkContent.rawValue // Simulate another RN writer.
AdaptiveStatusBarAppearance.apply(.lightContent, animated: false, owner: old)
assert(mirrored == UIStatusBarStyle.lightContent.rawValue)
assert(StatusBarSampler.scene.keyWindow.rootViewController.invalidations == invalidations)
AdaptiveStatusBarAppearance.claim(replacement)
AdaptiveStatusBarAppearance.apply(.darkContent, animated: true, owner: replacement)
let before = notifications
AdaptiveStatusBarAppearance.clear(owner: old) // Delayed invalidate/deinit.
AdaptiveStatusBarAppearance.apply(.lightContent, animated: false, owner: old)
assert(notifications == before)
assert(mirrored == UIStatusBarStyle.darkContent.rawValue)
AdaptiveStatusBarAppearance.clear(owner: replacement)
assert(mirrored == UIStatusBarStyle.default.rawValue)
assert(AdaptiveStatusBarAppearance.style == nil)
let cleared = notifications
AdaptiveStatusBarAppearance.clear(owner: replacement)
assert(notifications == cleared)
NotificationCenter.default.removeObserver(observer)
print("Appearance regression checks passed: mirror correction, no redundant root invalidation, replacement ownership, idempotent clear.")
SWIFT
# The real scene/window API is optional; match its chaining in the minimal seam.
sed -i '' 's/let keyWindow = Window()/let keyWindow: Window? = Window()/; s/let rootViewController = Root()/let rootViewController: Root? = Root()/; s/scene.keyWindow.rootViewController/scene.keyWindow!.rootViewController!/g' "$WORK/main.swift"
xcrun swift -module-cache-path "$WORK/ModuleCache" "$WORK/main.swift"
