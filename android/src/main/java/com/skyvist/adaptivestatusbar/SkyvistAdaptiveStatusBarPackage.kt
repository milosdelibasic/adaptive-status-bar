package com.skyvist.adaptivestatusbar

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class SkyvistAdaptiveStatusBarPackage : BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? =
    if (name == SkyvistAdaptiveStatusBarModule.NAME) SkyvistAdaptiveStatusBarModule(reactContext) else null

  override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
    mapOf(SkyvistAdaptiveStatusBarModule.NAME to ReactModuleInfo(
      SkyvistAdaptiveStatusBarModule.NAME, SkyvistAdaptiveStatusBarModule.NAME,
      false, false, false, true
    ))
  }
}
