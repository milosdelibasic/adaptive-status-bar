package com.skyvist.asbexpoandroid

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.graphics.Color
import android.widget.TextView
import androidx.core.view.WindowCompat
import com.skyvist.adaptivestatusbar.AdaptiveStatusBarController
import com.skyvist.adaptivestatusbar.ControllerConfig
import com.skyvist.adaptivestatusbar.Strategy
import com.skyvist.adaptivestatusbar.core.IconStyle

/** Fixture-only native regression. Never included in the library's npm payload. */
class HintLifecycleProbeActivity : Activity() {
  private val main = Handler(Looper.getMainLooper())
  private val controller = AdaptiveStatusBarController()
  private lateinit var result: TextView
  private var count = 0
  private fun field(name: String): Any? = controller.javaClass.getDeclaredField(name).let {
    it.isAccessible = true; it.get(controller)
  }
  private fun verify(condition: Boolean, message: String) {
    check(condition) { message }; count++
  }
  private fun safely(block: () -> Unit) {
    try { block() } catch (error: Throwable) {
      controller.disable()
      result.text = "HINT_PROBE_FAIL:$count:${error.message}"
    }
  }
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    WindowCompat.setDecorFitsSystemWindows(window, false)
    result = TextView(this).apply {
      setBackgroundColor(Color.BLACK); setTextColor(Color.WHITE)
      textSize = 16f; setPadding(24, 140, 24, 24); text = "HINT_PROBE_RUNNING"
    }
    setContentView(result)
    main.postDelayed({ safely {
      controller.attach(this)
      controller.enable(ControllerConfig(strategy = Strategy.AUTOMATIC))
      // Force a real request synchronously, while its completion is still queued.
      controller.javaClass.getDeclaredMethod("sample").apply { isAccessible = true }.invoke(controller)
      verify(field("copyInFlight") == true, "real PixelCopy was not in flight")
      val generation = field("generation")
      val worker = field("worker")
      val views = (field("observedViews") as List<*>).toList()
      verify(field("listening") == true && views.isNotEmpty(), "not observing draws")
      controller.setHint(IconStyle.DARK)
      verify(field("generation") == generation, "ignored hint invalidated in-flight generation")
      verify(field("copyInFlight") == true, "ignored hint interrupted capture")
      verify(field("worker") === worker && field("listening") == true && field("observedViews") == views,
        "ignored hint changed worker/listener state")
      verify(controller.hint == IconStyle.DARK, "ignored hint was not stored")
      // Clearing/changing ignored hints must also retain the same generation.
      controller.setHint(null); controller.setHint(IconStyle.DARK)
      verify(field("generation") == generation, "ignored hint clear/change restarted")
      pollForSample(0)
    } }, 750)
  }
  private fun pollForSample(attempt: Int) {
    main.postDelayed({ safely {
      if (controller.stats.samples == 0L && attempt < 30) { pollForSample(attempt + 1); return@safely }
      verify(controller.stats.samples > 0 && controller.stats.failures == 0L, "in-flight sample was not accepted")
      controller.configure(ControllerConfig(strategy = Strategy.HYBRID))
      verify(controller.snapshot()["source"] == "hint" && controller.snapshot()["style"] == "dark",
        "stored hint not applied after strategy change")
      verify(controller.snapshot()["sampling"] == false, "hybrid hint should stop sampling")
      controller.setOverride(IconStyle.LIGHT)
      verify(controller.snapshot()["source"] == "override" && controller.snapshot()["style"] == "light",
        "override no longer wins")
      val overrideGeneration = field("generation")
      controller.setHint(IconStyle.LIGHT)
      verify(field("generation") == overrideGeneration, "hint under override restarted")
      verify(controller.hint == IconStyle.LIGHT && controller.snapshot()["source"] == "override",
        "masked hint was not retained or displaced override")
      controller.setOverride(null)
      verify(controller.snapshot()["source"] == "hint" && controller.snapshot()["style"] == "light",
        "clearing override failed to restore latest hint")
      controller.disable()
      result.text = "HINT_PROBE_PASS:$count"
    } }, 50)
  }
  override fun onDestroy() {
    main.removeCallbacksAndMessages(null); controller.disable(); controller.detach()
    super.onDestroy()
  }
}
