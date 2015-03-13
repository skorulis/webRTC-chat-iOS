//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import <Mantle/Mantle.h>
#import <RTCICECandidate.h>

@interface ICECandidateModel : MTLModel <MTLJSONSerializing>

@property(nonatomic, readonly) NSString* sdpMid;
@property(nonatomic, readonly) NSInteger sdpMLineIndex;
@property(nonatomic, readonly) NSString* sdp;

- (instancetype) initWithICECandidate:(RTCICECandidate*)candidate;
- (RTCICECandidate*) candidate;

@end
