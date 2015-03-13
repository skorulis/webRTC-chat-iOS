//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "ICECandidateModel.h"

@implementation ICECandidateModel

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{};
}

- (instancetype) initWithICECandidate:(RTCICECandidate *)candidate {
    self = [super init];
    _sdpMid = candidate.sdpMid;
    _sdp = candidate.sdp;
    _sdpMLineIndex = candidate.sdpMLineIndex;
    return self;
}

- (RTCICECandidate*) candidate {
    return [[RTCICECandidate alloc] initWithMid:_sdpMid index:_sdpMLineIndex sdp:_sdp];
}

@end
