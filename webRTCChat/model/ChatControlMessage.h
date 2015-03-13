//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import <Mantle/Mantle.h>

static NSString* const CCT_CHAT_REQUEST = @"CCT_CHAT_REQUEST";
static NSString* const CCT_CHAT_INIT = @"CCT_CHAT_INIT";
static NSString* const CCT_CHAT_OFFER = @"CCT_CHAT_OFFER";
static NSString* const CCT_CHAT_ANSWER = @"CCT_CHAT_ANSWER";
static NSString* const CCT_ICE_CANDIDATE = @"CCT_ICE_CANDIDATE";

@interface ChatControlMessage : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* payload;

- (instancetype) initWithType:(NSString*)type payload:(MTLModel<MTLJSONSerializing>*)payload;

- (id) payloadAs:(Class)c;

- (BOOL) isInit;
- (BOOL) isOffer;
- (BOOL) isAnswer;
- (BOOL) isIceCandidate;

@end
