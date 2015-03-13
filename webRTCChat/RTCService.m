//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "RTCService.h"
#import <SocketRocket/SRWebSocket.h>

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

#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Got message %@",message);
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
