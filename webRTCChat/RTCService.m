//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "RTCService.h"
#import <SocketRocket/SRWebSocket.h>
#import "ChatControlMessage.h"
#import <RTCPeerConnectionFactory.h>
#import <RTCMediaConstraints.h>
#import <RTCPair.h>
#import <RTCPeerConnectionDelegate.h>
#import <RTCDataChannel.h>
#import <RTCPeerConnection.h>
#import <RTCICEServer.h>
#import <RTCSessionDescriptionDelegate.h>
#import <RTCSessionDescription.h>

static NSString* const kServerAddress = @"ws://192.168.1.2:8123";

@interface RTCService () <SRWebSocketDelegate, RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate> {
    SRWebSocket* _webSocket;
    RTCPeerConnectionFactory* _factory;
    RTCPeerConnection* _peerConnection;
    RTCDataChannel* _dataChannel;
    NSArray* _stunServers;
}

@end

@implementation RTCService

- (void) connectSocket {
    NSMutableArray* stunServers = [[NSMutableArray alloc] init];;
    NSArray* stunServerURLStrings = @[@"stun1.voiceeclipse.net",@"stun.l.google.com:19302",@"stun3.l.google.com:19302"];
    for(NSString* s in stunServerURLStrings) {
        NSURL* url = [NSURL URLWithString:s];
        NSParameterAssert(url);
        RTCICEServer* server = [[RTCICEServer alloc] initWithURI:url username:@"" password:@""];
        NSParameterAssert(server);
        [stunServers addObject:server];
    }
    
    _stunServers = stunServers.copy;
    [RTCPeerConnectionFactory initializeSSL];
    _factory = [[RTCPeerConnectionFactory alloc] init];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kServerAddress]];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    [_webSocket open];
    [self createPeerConnection];
}

- (void) createPeerConnection {
    RTCPair* pair = [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"];
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:@[pair]];
    _peerConnection = [_factory peerConnectionWithICEServers:_stunServers constraints:constraints delegate:self];
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

#pragma mark RTCPeerConnectionDelegate

// Triggered when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged {
    
}

// Triggered when media is received on a new stream from remote peer.
- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream {
    
}

// Triggered when a remote peer close a stream.
- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream {
    
}

// Triggered when renegotiation is needed, for example the ICE has restarted.
- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
    
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState {
    
}

// Called any time the ICEGatheringState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState {
    
}

// New Ice candidate have been found.
- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate {
    
}

// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel {
    
}

#pragma mark RTCSessionDescriptionDelegate

// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error {
    NSLog(@"Did create session description %@",sdp);
}

// Called when setting a local or remote description.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
    
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
    
    if(control.isInit) {
        [self handleInit];
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

#pragma mark private

- (void) handleInit {
    RTCDataChannelInit* config = [[RTCDataChannelInit alloc] init];
    config.isOrdered = false;
    _dataChannel = [_peerConnection createDataChannelWithLabel:@"sender" config:config];
    [_peerConnection createOfferWithDelegate:self constraints:nil];
}

@end
