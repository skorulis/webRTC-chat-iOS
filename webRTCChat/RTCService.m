//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "RTCService.h"
#import <SocketRocket/SRWebSocket.h>
#import "ChatControlMessage.h"

static NSString* const kServerAddress = @"ws://192.168.1.2:8123";

@interface RTCService () <SRWebSocketDelegate>{
    SRWebSocket* _webSocket;
}

@end

@implementation RTCService

- (void) connectSocket {
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kServerAddress]];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void) connectToPeer {
    ChatControlMessage* message = [[ChatControlMessage alloc] init];
    message.type = @"CCT_CHAT_REQUEST";
    [self sendControlMessage:message];
}

- (void) disconnectFromPeer {
    
}

- (void) sendControlMessage:(ChatControlMessage*)message {
    NSDictionary* json = [MTLJSONAdapter JSONDictionaryFromModel:message];
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if(error || !data) {
        NSLog(@"Error sending control message %@",message);
    } else {
        [_webSocket send:data];
    }
}

#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if([message isKindOfClass:[NSString class]]) {
        message = [((NSString*)message) dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSError* error;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:message options:0 error:&error];
    if(!dic || error) {
        NSLog(@"Error parsing JSON %@",error);
        return;
    }
    ChatControlMessage* control = [MTLJSONAdapter modelOfClass:ChatControlMessage.class fromJSONDictionary:dic error:&error];
    if(!control || error) {
        NSLog(@"Error parsing dic %@",error);
        return;
    }
    
    NSLog(@"Got message %@",control);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Socket did open");
    [_delegate rtcServiceDidConnectSocket:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Websocket error %@",error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Did close %@",reason);
}

@end
