package com.skyvist.adaptivestatusbar.core

import kotlin.random.Random

@Volatile private var sink = 0f

fun main() {
  val rng = Random(20261109)
  val strips = Array(64) { IntArray(96 * 8) { rng.nextInt() } }
  val out = Measurement()
  for (strip in strips) {
    val old = BaselineLuminanceAnalyzer.analyze(strip, 96, 8)
    val current = LuminanceAnalyzer.analyze(strip, 96, 8)
    check(old.lightness.toRawBits() == current.lightness.toRawBits())
    check(old.left.toRawBits() == current.left.toRawBits())
    check(old.right.toRawBits() == current.right.toRawBits())
  }
  println("Exact output parity: 64 benchmark strips passed")
  fun run(baseline: Boolean, count: Int): Double {
    var sum = 0f
    val started = System.nanoTime()
    repeat(count) { i ->
      val result = if (baseline) BaselineLuminanceAnalyzer.analyze(strips[i and 63], 96, 8, out)
        else LuminanceAnalyzer.analyze(strips[i and 63], 96, 8, out)
      sum += result.lightness + result.left + result.right
    }
    sink = sum
    return (System.nanoTime() - started).toDouble() / count
  }
  repeat(8) { run(true, 20_000); run(false, 20_000) }
  val before = mutableListOf<Double>()
  val after = mutableListOf<Double>()
  repeat(9) { round ->
    // Alternate order to limit thermal/order effects.
    if (round % 2 == 0) { before += run(true, 100_000); after += run(false, 100_000) }
    else { after += run(false, 100_000); before += run(true, 100_000) }
  }
  fun median(values: List<Double>) = values.sorted()[values.size / 2]
  println("Runtime: ${System.getProperty("java.vm.name")} ${System.getProperty("java.version")}; ${System.getProperty("os.arch")}")
  println("64 seeded 96x8 strips; 160000 warmup + 9 x 100000 samples per implementation; output checksum=$sink")
  println("baseline ns/sample: $before")
  println("weighted tables ns/sample: $after")
  println("median baseline=${median(before)}, weighted=${median(after)}, ratio=${median(after) / median(before)}")
  println("Analyzer CPU microbenchmark only: excludes PixelCopy, scheduling and end-to-end frame time; results apply only to the runtime shown.")
}
