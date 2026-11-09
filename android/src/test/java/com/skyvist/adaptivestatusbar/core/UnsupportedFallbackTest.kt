package com.skyvist.adaptivestatusbar.core

import org.junit.Assert.assertEquals
import org.junit.Test

class UnsupportedFallbackTest {
  @Test fun lightThemeUsesDarkIcons() {
    assertEquals(IconStyle.DARK, resolveUnsupportedFallback(null, false))
  }

  @Test fun darkThemeUsesLightIcons() {
    assertEquals(IconStyle.LIGHT, resolveUnsupportedFallback(null, true))
  }

  @Test fun explicitStyleWinsOverEitherTheme() {
    for (night in listOf(false, true)) {
      for (style in IconStyle.entries) {
        assertEquals(style, resolveUnsupportedFallback(style, night))
      }
    }
  }

  @Test fun themeChangeRecomputesTheDefault() {
    val themes = listOf(false, true, false)
    assertEquals(
      listOf(IconStyle.DARK, IconStyle.LIGHT, IconStyle.DARK),
      themes.map { resolveUnsupportedFallback(null, it) },
    )
  }
}
