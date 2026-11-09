package com.skyvist.adaptivestatusbar.core

import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Test
import kotlin.random.Random

class LuminanceParityTest {
  @Test fun everyRgbValueMatchesReferenceExactly() {
    for (rgb in 0..0xFFFFFF) {
      val expected = BaselineLuminanceAnalyzer.luminance(rgb).toRawBits()
      val actual = LuminanceAnalyzer.luminance(rgb).toRawBits()
      if (expected != actual) throw AssertionError("RGB $rgb: $expected != $actual")
    }
  }

  @Test fun completeMeasurementsMatchReferenceAndReuseOutput() {
    val random = Random(20261109)
    val actual = Measurement()
    val expected = Measurement()
    for (width in listOf(1, 2, 3, 5, 95, 96, 97)) {
      for (height in listOf(1, 2, 8, 13)) {
        repeat(64) {
          val pixels = IntArray(width * height) { random.nextInt() }
          BaselineLuminanceAnalyzer.analyze(pixels, width, height, expected)
          assertSame(actual, LuminanceAnalyzer.analyze(pixels, width, height, actual))
          assertEquals(expected.lightness.toRawBits(), actual.lightness.toRawBits())
          assertEquals(expected.left.toRawBits(), actual.left.toRawBits())
          assertEquals(expected.right.toRawBits(), actual.right.toRawBits())
        }
      }
    }
  }
}
