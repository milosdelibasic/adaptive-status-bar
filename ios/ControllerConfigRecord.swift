import Foundation

struct ConfigRecord: Decodable {
  var strategy: String
  var performance: String
  var samplingInterval: Double?
  var maxInterval: Double?
  var quietInterval: Double?
  var idleInterval: Double?
  var hysteresis: Bool
  var darkThreshold: Double?
  var lightThreshold: Double?
  var confirmSamples: Int?
  var minTransitionInterval: Double?
  var animation: Bool
  var fallbackStyle: String?
  var iosCaptureMethod: String?

  func config() throws -> ControllerConfig {
    var c = ControllerConfig()
    c.strategy = Strategy(rawValue: strategy) ?? .hybrid
    let preset = SamplingConfig.preset(performance)
    let minInterval = samplingInterval.map { $0 / 1000 } ?? preset.minInterval
    let maxI = maxInterval.map { $0 / 1000 } ?? max(preset.maxInterval, minInterval)
    c.sampling = SamplingConfig(
      minInterval: minInterval,
      maxInterval: maxI,
      quietInterval: quietInterval.map { $0 / 1000 } ?? max(preset.quietInterval, maxI),
      idleInterval: idleInterval.map { $0 / 1000 } ?? preset.idleInterval)
    var d = hysteresis ? DeciderConfig() : DeciderConfig.noHysteresis
    if let v = darkThreshold { d.darkThreshold = Float(v) }
    if let v = lightThreshold { d.lightThreshold = Float(v) }
    if let v = confirmSamples { d.confirmSamples = v }
    if let v = minTransitionInterval { d.minTransition = v / 1000 }
    c.decider = d
    c.fallback = fallbackStyle.flatMap(IconStyle.init(rawValue:))
    c.animated = animation
    c.captureMethod = iosCaptureMethod.flatMap(CaptureMethod.init(rawValue:)) ?? .layer
    try c.sampling.validate()
    try d.validate()
    return c
  }
}

