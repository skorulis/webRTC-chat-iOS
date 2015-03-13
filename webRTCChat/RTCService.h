//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

@import Foundation;

@class RTCService;

@protocol RTCServiceDelegate <NSObject>

- (void) rtcServiceDidConnectSocket:(RTCService*)rtcService;

@end

@interface RTCService : NSObject

@property (nonatomic, weak) id<RTCServiceDelegate> delegate;

- (void) connectSocket;

@end
