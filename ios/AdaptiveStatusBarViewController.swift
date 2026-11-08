import UIKit

// The root owns status-bar style for all contained React Navigation screens, without swizzling.
@objc public final class AdaptiveStatusBarViewController: UIViewController {
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    AdaptiveStatusBarAppearance.style ?? .default
  }

  public override var childForStatusBarStyle: UIViewController? { nil }
}

enum AdaptiveStatusBarAppearance {
  static var style: UIStatusBarStyle?

  static func apply(_ next: UIStatusBarStyle, animated: Bool) {
    let changed = style != next
    style = next
    guard changed else { return }
    update(animated: animated)
  }

  static func clear() {
    style = nil
    update(animated: false)
  }

  private static func update(animated: Bool) {
    guard let root = StatusBarSampler.activeScene()?.keyWindow?.rootViewController else { return }
    let changes = { root.setNeedsStatusBarAppearanceUpdate() }
    if animated { UIView.animate(withDuration: 0.2, animations: changes) } else { changes() }
  }
}
