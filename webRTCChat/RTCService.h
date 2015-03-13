//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

@import Foundation;

@class RTCService;

@protocol RTCServiceDelegate <NSObject>

- (void) rtcServiceDidConnectSocket:(RTCService*)rtcService;
- (void) rtcServiceDidConnectChannel:(RTCService*)rtcService;
- (void) rtcService:(RTCService*)rtcService didReceiveText:(NSString*)text;

@end

@interface RTCService : NSObject

@property (nonatomic, weak) id<RTCServiceDelegate> delegate;

- (void) connectSocket;
- (void) connectToPeer;
- (void) disconnectFromPeer;

- (void) sendText:(NSString*)text;

@end
