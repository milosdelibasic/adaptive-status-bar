package com.skyvist.adaptivestatusbar.core

/** A deterministic icon style when Window PixelCopy is unavailable; never a sampled decision. */
internal fun resolveUnsupportedFallback(explicit: IconStyle?, nightMode: Boolean): IconStyle =
  explicit ?: if (nightMode) IconStyle.LIGHT else IconStyle.DARK
