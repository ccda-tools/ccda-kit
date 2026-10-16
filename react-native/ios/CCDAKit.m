#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(CCDAKit, NSObject)

RCT_EXTERN_METHOD(openMedia:(NSDictionary *)media
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(parseXml:(NSString *)xml
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(parseFile:(NSString *)path
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
