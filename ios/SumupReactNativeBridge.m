#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SumupReactNativeBridge, NSObject)

RCT_EXTERN_METHOD(
                  setupAPIKey: (NSString *) apikey
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject
                  )

RCT_EXTERN_METHOD(
                  logout: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject
                  )

RCT_EXTERN_METHOD(
                  login: (NSString *) token
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject
                  )

RCT_EXTERN_METHOD(
                  isLoggedIn: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject
                  )

RCT_EXTERN_METHOD(
                  payment: (NSDictionary *) request
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject
                  )

RCT_EXTERN_METHOD(
                  preferences: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject
                  )

@end
