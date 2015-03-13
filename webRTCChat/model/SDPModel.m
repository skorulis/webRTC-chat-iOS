//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "SDPModel.h"

@implementation SDPModel

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{};
}

- (instancetype) initWithSDP:(RTCSessionDescription*)sdp {
    self = [super init];
    _sdpType = sdp.type;
    _sdpDescription = sdp.description;
    return self;
}

- (RTCSessionDescription*) sdp {
    return [[RTCSessionDescription alloc] initWithType:_sdpType sdp:_sdpDescription];
}

@end
