#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SkyvistAdaptiveStatusBarImplementation <NSObject>
- (void)enable:(NSString *)config;
- (void)configure:(NSString *)config;
- (void)disable;
- (void)setOverride:(nullable NSString *)style;
- (void)setHint:(nullable NSString *)style;
- (NSString *)getStats;
- (void)resetStats;
- (void)invalidate;
@end

FOUNDATION_EXPORT id<SkyvistAdaptiveStatusBarImplementation> SkyvistCreateStatusBarImplementation(void);

NS_ASSUME_NONNULL_END
