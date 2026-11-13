#import "SkyvistAdaptiveStatusBar.h"
#if __has_include(<React/RCTStatusBarAppearance.h>)
#import <React/RCTStatusBarAppearance.h>
#define SKYVIST_RN_APPEARANCE 1
#endif
#if SKYVIST_SPM
#import "SPM/SkyvistAdaptiveStatusBarImplementation.h"
#elif __has_include(<SkyvistAdaptiveStatusBar/SkyvistAdaptiveStatusBar-Swift.h>)
#import <SkyvistAdaptiveStatusBar/SkyvistAdaptiveStatusBar-Swift.h>
#else
#import "SkyvistAdaptiveStatusBar-Swift.h"
#endif

@implementation SkyvistAdaptiveStatusBar {
#if SKYVIST_SPM
  id<SkyvistAdaptiveStatusBarImplementation> _implementation;
#else
  AdaptiveStatusBarBridge *_implementation;
#endif
}
RCT_EXPORT_MODULE(SkyvistAdaptiveStatusBar)

- (instancetype)init {
  if (self = [super init]) {
#if SKYVIST_SPM
    _implementation = SkyvistCreateStatusBarImplementation();
#else
    _implementation = [AdaptiveStatusBarBridge new];
#endif
  }
#if SKYVIST_RN_APPEARANCE
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(adaptiveAppearanceDidChange:)
      name:@"SkyvistAdaptiveStatusBarAppearanceDidChange" object:nil];
  }
#endif
  return self;
}
#if SKYVIST_RN_APPEARANCE
- (void)adaptiveAppearanceDidChange:(NSNotification *)notification {
  // Swift appearance updates run on the main thread. Do not replace Expo's
  // root controller: it already reads this public React Native state.
  UIStatusBarStyle style = (UIStatusBarStyle)[notification.userInfo[@"style"] integerValue];
  if (RCTStatusBarAppearance.style != style) {
    [RCTStatusBarAppearance setStyle:style animated:[notification.userInfo[@"animated"] boolValue]];
  }
}
#endif
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
+ (BOOL)requiresMainQueueSetup { return NO; }
- (void)enable:(NSString *)config { [_implementation enable:config]; }
- (void)configure:(NSString *)config { [_implementation configure:config]; }
- (void)disable { [_implementation disable]; }
- (void)setOverride:(NSString *)style { [_implementation setOverride:style]; }
- (void)setHint:(NSString *)style { [_implementation setHint:style]; }
- (void)resetStats { [_implementation resetStats]; }
- (void)getStats:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  resolve([_implementation getStats]);
}
- (void)invalidate {
  [_implementation invalidate];
  // Swift queues its final disable/clear on main. Keep the observer until that
  // reset has propagated, then detach. Swift owner IDs protect a newer bridge.
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  });
}
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeSkyvistAdaptiveStatusBarSpecJSI>(params);
}
@end
