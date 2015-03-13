//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "ChatControlMessage.h"

@implementation ChatControlMessage

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{};
}

- (BOOL) isInit {
    return [_type isEqualToString:CCT_CHAT_INIT];
}

@end
