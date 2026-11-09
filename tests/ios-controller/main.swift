import Foundation

var config = ControllerConfig()
config.strategy = .manual
config.fallback = .dark
let controller = AdaptiveStatusBarController()
controller.enable(config)
controller.pause()
let pausedWrites = AdaptiveStatusBarAppearance.writes
config.fallback = .light
controller.configure(config)
precondition(AdaptiveStatusBarAppearance.writes == pausedWrites, "configure must not write while paused")
precondition(controller.config.fallback == .light, "paused configure must retain settings")
controller.resume()
precondition(AdaptiveStatusBarAppearance.writes > pausedWrites, "resume must apply retained settings")

let before = StatusBarSampler.captures
controller.pause()
controller.sample()
precondition(StatusBarSampler.captures == before, "queued paused tick must not capture")
controller.disable()
controller.sample()
precondition(StatusBarSampler.captures == before, "queued disabled tick must not capture")
controller.resume()
config.strategy = .automatic
controller.enable(config)
controller.setOverride(.light)
controller.sample()
precondition(StatusBarSampler.captures == before, "queued overridden tick must not capture")
controller.setOverride(nil)
controller.sample()
precondition(StatusBarSampler.captures == before + 1, "active sampling must still capture")
let attachments = Window.attachments
for i in 0..<100 { controller.setHint(i % 2 == 0 ? .light : .dark) }
precondition(Window.attachments == attachments, "ignored automatic hints must not restart sampling")
precondition(controller.hint == .dark, "ignored hint must remain available for future strategy changes")
config.strategy = .hybrid
controller.configure(config)
precondition(controller.snapshot()["sampling"] as? Bool == false, "hybrid must honor saved hint")
controller.setHint(nil)
precondition(controller.snapshot()["sampling"] as? Bool == true, "removing hybrid hint must resume sampling")
controller.setOverride(.light)
controller.setHint(.dark)
controller.setOverride(nil)
precondition(controller.snapshot()["source"] as? String == "hint", "clearing override must use stored hint")
precondition(controller.snapshot()["style"] as? String == "dark", "latest stored hint must apply")
controller.disable()
print("Controller checks passed: paused configure, resume, stale timer guards, 100 ignored hints without restarts, hybrid hint recovery.")
