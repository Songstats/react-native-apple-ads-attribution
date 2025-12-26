#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <AppleAdsAttributionSpec/AppleAdsAttributionSpec.h>

@interface AppleAdsAttribution : NSObject <NativeAppleAdsAttributionSpec>
#else
@interface AppleAdsAttribution : NSObject <RCTBridgeModule>
#endif

@end
