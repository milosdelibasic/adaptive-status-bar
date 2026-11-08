#import "SkyvistAdaptiveStatusBar.h"
#import "SkyvistAdaptiveStatusBar-Swift.h"

@implementation SkyvistAdaptiveStatusBar {
  AdaptiveStatusBarBridge *_implementation;
}
RCT_EXPORT_MODULE(SkyvistAdaptiveStatusBar)

- (instancetype)init {
  if (self = [super init]) { _implementation = [AdaptiveStatusBarBridge new]; }
  return self;
}
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
- (void)invalidate { [_implementation invalidate]; }
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeSkyvistAdaptiveStatusBarSpecJSI>(params);
}
@end
