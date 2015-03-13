//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import <Mantle/Mantle.h>
#import <RTCSessionDescription.h>

@interface SDPModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSString* sdpType;
@property (nonatomic, readonly) NSString* sdpDescription;

- (instancetype) initWithSDP:(RTCSessionDescription*)sdp;

- (RTCSessionDescription*) sdp;

@end
