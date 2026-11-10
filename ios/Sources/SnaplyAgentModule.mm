//
//  SnaplyAgentModule.mm
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

#import "SnaplyAgentModule.h"

#import <QuartzCore/QuartzCore.h>
#import <React/RCTConversions.h>
#import <React/RCTTouchableComponentViewProtocol.h>
#import <react/renderer/components/view/TouchEventEmitter.h>

#if __has_include(<SnaplyAgentReactNative/SnaplyAgentReactNative-Swift.h>)
#import <SnaplyAgentReactNative/SnaplyAgentReactNative-Swift.h>
#else
#import "SnaplyAgentReactNative-Swift.h"
#endif

using namespace facebook::react;

// React Native's own handler takes its identifiers from a pool of 17; the last one is the least likely to be
// in use by a finger at the same moment.
static const int SnaplyRelayedTouchIdentifier = 16;

/// One tap, as RCTSurfaceTouchHandler would report it: a touch start on the component under the point, then
/// its end. No UITouch is made up — the events go through React Native's own emitter.
static BOOL SnaplyRelayTap(UIView *surface, CGPoint point)
{
  UIView *view = [surface hitTest:point withEvent:nil];
  while (view != nil && ![view respondsToSelector:@selector(touchEventEmitterAtPoint:)]) {
    view = view.superview;
  }
  if (view == nil) {
    return NO;
  }
  CGPoint local = [surface convertPoint:point toView:view];
  SharedTouchEventEmitter emitter = [(id<RCTTouchableComponentViewProtocol>)view touchEventEmitterAtPoint:local];
  if (!emitter) {
    return NO;
  }

  Touch touch = {};
  touch.identifier = SnaplyRelayedTouchIdentifier;
  touch.target = (Tag)view.tag;
  touch.offsetPoint = RCTPointFromCGPoint(local);
  touch.pagePoint = RCTPointFromCGPoint(point);
  touch.screenPoint = RCTPointFromCGPoint([surface convertPoint:point toCoordinateSpace:surface.window.screen.coordinateSpace]);
  touch.timestamp = CACurrentMediaTime();
  touch.timeStamp = RCTHighResTimeStampFromSeconds(touch.timestamp);

  TouchEvent start = {};
  start.touches.insert(touch);
  start.changedTouches.insert(touch);
  start.targetTouches.insert(touch);
  emitter->onTouchStart(start);

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    Touch lifted = touch;
    lifted.timestamp = CACurrentMediaTime();
    lifted.timeStamp = RCTHighResTimeStampFromSeconds(lifted.timestamp);
    TouchEvent end = {};
    end.changedTouches.insert(lifted);
    emitter->onTouchEnd(end);
  });
  return YES;
}

@implementation SnaplyAgentModule

+ (NSString *)moduleName
{
  return @"SnaplyAgent";
}

- (std::shared_ptr<TurboModule>)getTurboModule:(const ObjCTurboModule::InitParams &)params
{
  return std::make_shared<NativeSnaplyAgentSpecJSI>(params);
}

- (void)configure:(NSString *)key
             host:(NSString *)host
           userId:(NSString *)userId
         userName:(NSString *)userName
  collectVendorId:(BOOL)collectVendorId
         language:(NSString *)language
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject
{
  __weak SnaplyAgentModule *weakSelf = self;
  SnaplyBridge.emit = ^(NSDictionary<NSString *, id> *event) {
    [weakSelf emitOnSnaplyEvent:event];
  };
  SnaplyBridge.tapRelay = ^BOOL(UIView *surface, CGPoint point) {
    return SnaplyRelayTap(surface, point);
  };
  [SnaplyBridge configureWithKey:key
                            host:host
                          userId:userId
                        userName:userName
                 collectVendorId:collectVendorId
                        language:language
                      completion:^(NSString *code, NSString *message, NSInteger status) {
                        if (code == nil) {
                          resolve(nil);
                          return;
                        }
                        reject(code, message, [NSError errorWithDomain:@"SnaplyAgent" code:status userInfo:@{@"status" : @(status)}]);
                      }];
}

- (void)identify:(NSString *)id name:(NSString *)name phone:(NSString *)phone identitySignature:(NSString *)identitySignature
{
  [SnaplyBridge identifyWithId:id name:name phone:phone identitySignature:identitySignature];
}

- (void)reset
{
  [SnaplyBridge reset];
}

- (void)supportCode:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject
{
  [SnaplyBridge supportCode:^(NSString *code) {
    resolve(code ?: [NSNull null]);
  }];
}

- (void)showSupportCode
{
  [SnaplyBridge showSupportCode];
}

- (void)stop
{
  [SnaplyBridge stop];
}

@end
