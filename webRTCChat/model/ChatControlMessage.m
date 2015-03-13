//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "ChatControlMessage.h"

@implementation ChatControlMessage

- (instancetype) initWithType:(NSString*)type payload:(MTLModel<MTLJSONSerializing>*)payload {
    self = [super init];
    _type = type;
    if(payload) {
        NSError* error;
        NSDictionary* dic = [MTLJSONAdapter JSONDictionaryFromModel:payload];
        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        _payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(error || !_payload) {
            NSLog(@"Error serialising payload %@",error);
        }
    }
    return self;
}

- (id) payloadAs:(Class)c {
    NSError* error;
    NSData* data = [_payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(!dic || error) {
        NSLog(@"Error parsing paylod %@",error);
        return nil;
    }
    id model = [MTLJSONAdapter modelOfClass:c fromJSONDictionary:dic error:&error];
    if(!model || error) {
        NSLog(@"Error parsing paylod %@",error);
        return nil;
    }
    return model;
}

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{};
}

- (BOOL) isInit {
    return [_type isEqualToString:CCT_CHAT_INIT];
}

- (BOOL) isOffer {
    return [_type isEqualToString:CCT_CHAT_OFFER];
}

- (BOOL) isAnswer {
    return [_type isEqualToString:CCT_CHAT_ANSWER];
}

- (BOOL) isIceCandidate {
    return [_type isEqualToString:CCT_ICE_CANDIDATE];
}

@end
