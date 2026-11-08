package com.skyvist.adaptivestatusbar

import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.view.Window
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.views.modal.ReactModalHostView
import com.skyvist.adaptivestatusbar.core.IconStyle
import org.json.JSONObject

@ReactModule(name = SkyvistAdaptiveStatusBarModule.NAME)
class SkyvistAdaptiveStatusBarModule(context: ReactApplicationContext) :
  NativeSkyvistAdaptiveStatusBarSpec(context), LifecycleEventListener {
  private val main = Handler(Looper.getMainLooper())
  private val controller = AdaptiveStatusBarController(windowForActivity = { activity ->
    // RN Modal uses a Dialog window. Read its public host view, without private WindowManager APIs.
    if (activity.window.decorView.hasWindowFocus()) activity.window
    else findModalWindow(activity.window.decorView) ?: activity.window
  })

  private fun findModalWindow(view: View): Window? {
    if (view is ReactModalHostView) {
      view.dialog?.let { if (it.isShowing) return it.window }
    }
    if (view is ViewGroup) {
      for (index in view.childCount - 1 downTo 0) {
        view.getChildAt(index)?.let { child -> findModalWindow(child)?.let { return it } }
      }
    }
    return null
  }

  init { context.addLifecycleEventListener(this) }
  override fun getName() = NAME
  override fun enable(config: String) {
    val next = ConfigRecord(JSONObject(config)).toConfig()
    main.post {
      reactApplicationContext.currentActivity?.let(controller::attach)
      controller.enable(next)
    }
  }
  override fun configure(config: String) {
    val next = ConfigRecord(JSONObject(config)).toConfig()
    main.post { controller.configure(next) }
  }
  override fun disable() { main.post { controller.disable() } }
  override fun setOverride(style: String?) { main.post { controller.setOverride(IconStyle.of(style)) } }
  override fun setHint(style: String?) { main.post { controller.setHint(IconStyle.of(style)) } }
  override fun getStats(promise: Promise) {
    main.post { promise.resolve(JSONObject(controller.snapshot()).toString()) }
  }
  override fun resetStats() { main.post { controller.resetStats() } }
  override fun onHostResume() {
    reactApplicationContext.currentActivity?.let(controller::attach)
    controller.resume()
  }
  override fun onHostPause() { controller.pause() }
  override fun onHostDestroy() { controller.pause(); controller.detach() }
  override fun invalidate() {
    reactApplicationContext.removeLifecycleEventListener(this)
    main.post { controller.disable(); controller.detach() }
    super.invalidate()
  }
  companion object { const val NAME = "SkyvistAdaptiveStatusBar" }
}
