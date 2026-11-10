import Foundation
import CoreFoundation
func CACurrentMediaTime() -> TimeInterval { ProcessInfo.processInfo.systemUptime }
enum UIStatusBarStyle { case `default`, lightContent, darkContent }
final class Window {
 static var attachments=0
 func addGestureRecognizer(_ g: TouchObserver) { Self.attachments += 1; g.view = self }
 func removeGestureRecognizer(_ g: TouchObserver) { g.view = nil }
}
final class Manager { var statusBarStyle: UIStatusBarStyle = .default }
final class Scene { let keyWindow: Window? = Window(); let statusBarManager: Manager? = Manager() }
final class TouchObserver { var view: Window?; init(_ f: @escaping () -> Void) {} }
enum SampleResult { case measured(Measurement, captureTime: TimeInterval, analysisTime: TimeInterval), skipped }
final class StatusBarSampler {
 static var captures=0
 static let scene = Scene()
 static func activeScene() -> Scene? { scene }
 func release() {}
 var lastCaptureMethod: CaptureMethod? = .layer
 func capture(method: CaptureMethod) -> SampleResult { Self.captures += 1; return .measured(Measurement(lightness: 1,left:1,right:1),captureTime:0,analysisTime:0) }
}
enum AdaptiveStatusBarAppearance {
 static var writes=0
 static var owner: UUID?
 static func claim(_ id: UUID) { owner=id }
 static func clear(owner id: UUID) { if owner == id { owner=nil; writes += 1 } }
 static func apply(_ style: UIStatusBarStyle, animated: Bool, owner id: UUID) { if owner == id { writes += 1 } }
 static func isExplicitMismatch(_ observed: UIStatusBarStyle?, target: UIStatusBarStyle) -> Bool { observed != nil && observed != .default && observed != target }
}
