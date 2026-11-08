import UIKit

@objc public final class AdaptiveStatusBarBridge: NSObject {
  private let controller = AdaptiveStatusBarController()
  private var observers: [NSObjectProtocol] = []

  public override init() {
    super.init()
    let center = NotificationCenter.default
    observers = [
      center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
        self?.controller.pause()
      },
      center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
        self?.controller.resume()
      },
    ]
  }

  @objc public func enable(_ json: String) { apply(json, enable: true) }
  @objc public func configure(_ json: String) { apply(json, enable: false) }

  private func apply(_ json: String, enable: Bool) {
    do {
      let record = try JSONDecoder().decode(ConfigRecord.self, from: Data(json.utf8))
      let config = try record.config()
      DispatchQueue.main.async { [controller] in
        if enable { controller.enable(config) } else { controller.configure(config) }
      }
    } catch {
      NSLog("[SkyvistAdaptiveStatusBar] Invalid configuration: %@", String(describing: error))
    }
  }

  @objc public func disable() { DispatchQueue.main.async { [controller] in controller.disable() } }
  @objc public func setOverride(_ style: String?) {
    DispatchQueue.main.async { [controller] in controller.setOverride(style.flatMap(IconStyle.init(rawValue:))) }
  }
  @objc public func setHint(_ style: String?) {
    DispatchQueue.main.async { [controller] in controller.setHint(style.flatMap(IconStyle.init(rawValue:))) }
  }
  @objc public func getStats() -> String {
    let values = controller.snapshot().mapValues { $0 ?? NSNull() }
    guard let data = try? JSONSerialization.data(withJSONObject: values),
      let json = String(data: data, encoding: .utf8) else { return "{}" }
    return json
  }
  @objc public func resetStats() { DispatchQueue.main.async { [controller] in controller.resetStats() } }
  @objc public func invalidate() {
    observers.forEach(NotificationCenter.default.removeObserver)
    observers = []
    disable()
  }
  deinit {
    observers.forEach(NotificationCenter.default.removeObserver)
    DispatchQueue.main.async { [controller] in controller.disable() }
  }
}
