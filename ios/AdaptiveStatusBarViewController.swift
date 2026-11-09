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
  private static var owner: UUID?

  // UIKit may report .default while another window (for example Expo's
  // development overlay) is present. That is not proof of an external write.
  static func isExplicitMismatch(_ observed: UIStatusBarStyle?, target: UIStatusBarStyle) -> Bool {
    guard let observed, observed == .lightContent || observed == .darkContent else { return false }
    return observed != target
  }

  static func claim(_ identifier: UUID) { owner = identifier }

  static func apply(_ next: UIStatusBarStyle, animated: Bool, owner identifier: UUID) {
    guard owner == identifier else { return }
    let changed = style != next
    style = next
    update(animated: animated, invalidateRoot: changed)
  }

  static func clear(owner identifier: UUID) {
    guard owner == identifier else { return }
    owner = nil
    style = nil
    update(animated: false)
  }

  private static func update(animated: Bool, invalidateRoot: Bool = true) {
    // The RN adapter mirrors this into RN 0.88's shared appearance state.
    // Keep the UIKit core independent of React and Expo modules.
    NotificationCenter.default.post(
      name: Notification.Name("SkyvistAdaptiveStatusBarAppearanceDidChange"),
      object: nil,
      userInfo: ["style": (style ?? .default).rawValue, "animated": animated]
    )
    guard invalidateRoot, let root = StatusBarSampler.activeScene()?.keyWindow?.rootViewController else { return }
    let changes = { root.setNeedsStatusBarAppearanceUpdate() }
    if animated { UIView.animate(withDuration: 0.2, animations: changes) } else { changes() }
  }
}
