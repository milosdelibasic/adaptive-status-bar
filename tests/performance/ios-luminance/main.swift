import Foundation
// 64 deterministic RGBX strips with padded rows, alternating paired order.
let width = 96, height = 8, rowStride = 96 * 4 + 16
var seed: UInt64 = 0x123456789abcdef
let corpus = (0..<64).map { _ in (0..<(rowStride * height)).map { _ -> UInt8 in
  seed = seed &* 6364136223846793005 &+ 1
  return UInt8(truncatingIfNeeded: seed >> 32)
} }
for bytes in corpus {
  let a = LuminanceAnalyzer.analyze(bytes, width: width, height: height, bytesPerRow: rowStride)
  let b = WeightedCandidate.analyze(bytes, width: width, height: height, bytesPerRow: rowStride)
  precondition(a == b, "candidate changed numerical output")
}
@inline(never) func run(_ baseline: Bool, _ iterations: Int) -> (Double, Float) {
  var sink: Float = 0
  let start = DispatchTime.now().uptimeNanoseconds
  for i in 0..<iterations {
    let bytes = corpus[i % corpus.count]
    sink += baseline
      ? LuminanceAnalyzer.analyze(bytes, width: width, height: height, bytesPerRow: rowStride).lightness
      : WeightedCandidate.analyze(bytes, width: width, height: height, bytesPerRow: rowStride).lightness
  }
  return (Double(DispatchTime.now().uptimeNanoseconds - start) / Double(iterations) / 1000, sink)
}
_ = run(true, 10000); _ = run(false, 10000)
for round in 0..<10 {
  let first = run(round % 2 == 0, 50000), second = run(round % 2 != 0, 50000)
  let baseline = round % 2 == 0 ? first : second, candidate = round % 2 == 0 ? second : first
  print("round=\(round) baseline_us=\(baseline.0) candidate_us=\(candidate.0) sink=\(baseline.1 + candidate.1)")
}
