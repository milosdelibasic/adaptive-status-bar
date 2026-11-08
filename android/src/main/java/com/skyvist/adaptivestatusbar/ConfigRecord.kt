package com.skyvist.adaptivestatusbar

import com.skyvist.adaptivestatusbar.core.DeciderConfig
import com.skyvist.adaptivestatusbar.core.IconStyle
import com.skyvist.adaptivestatusbar.core.SamplingConfig

class ConfigRecord(json: org.json.JSONObject) {
  val strategy: String = json.optString("strategy", "hybrid")
  val performance: String = json.optString("performance", "balanced")
  val samplingInterval: Double? = if (json.has("samplingInterval")) json.getDouble("samplingInterval") else null
  val maxInterval: Double? = if (json.has("maxInterval")) json.getDouble("maxInterval") else null
  val quietInterval: Double? = if (json.has("quietInterval")) json.getDouble("quietInterval") else null
  val idleInterval: Double? = if (json.has("idleInterval")) json.getDouble("idleInterval") else null
  val hysteresis: Boolean = json.optBoolean("hysteresis", true)
  val darkThreshold: Double? = if (json.has("darkThreshold")) json.getDouble("darkThreshold") else null
  val lightThreshold: Double? = if (json.has("lightThreshold")) json.getDouble("lightThreshold") else null
  val confirmSamples: Int? = if (json.has("confirmSamples")) json.getInt("confirmSamples") else null
  val minTransitionInterval: Double? = if (json.has("minTransitionInterval")) json.getDouble("minTransitionInterval") else null
  val fallbackStyle: String? = if (json.has("fallbackStyle")) json.getString("fallbackStyle") else null

  fun toConfig(): ControllerConfig {
    val preset = SamplingConfig.preset(performance)
    val min = samplingInterval?.toLong() ?: preset.minIntervalMs
    val max = maxInterval?.toLong() ?: maxOf(preset.maxIntervalMs, min)
    val sampling = SamplingConfig(
      minIntervalMs = min,
      maxIntervalMs = max,
      quietIntervalMs = quietInterval?.toLong() ?: maxOf(preset.quietIntervalMs, max),
      idleIntervalMs = idleInterval?.toLong() ?: preset.idleIntervalMs,
    )
    val base = if (hysteresis) DeciderConfig() else DeciderConfig.NO_HYSTERESIS
    val decider = base.copy(
      darkThreshold = darkThreshold?.toFloat() ?: base.darkThreshold,
      lightThreshold = lightThreshold?.toFloat() ?: base.lightThreshold,
      confirmSamples = confirmSamples ?: base.confirmSamples,
      minTransitionMs = minTransitionInterval?.toLong() ?: base.minTransitionMs,
    )
    val s = Strategy.entries.firstOrNull { it.name.equals(strategy, ignoreCase = true) } ?: Strategy.HYBRID
    return ControllerConfig(s, sampling, decider, IconStyle.of(fallbackStyle))
  }
}

