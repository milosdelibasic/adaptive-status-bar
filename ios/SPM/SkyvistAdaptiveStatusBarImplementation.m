#import "SkyvistAdaptiveStatusBarImplementation.h"

@import SkyvistAdaptiveStatusBar;

id<SkyvistAdaptiveStatusBarImplementation> SkyvistCreateStatusBarImplementation(void) {
  // Import Swift from Objective-C: RN's Objective-C++ target disables C++ modules.
  return (id<SkyvistAdaptiveStatusBarImplementation>)[AdaptiveStatusBarBridge new];
}
