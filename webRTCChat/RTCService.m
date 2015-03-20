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
#import "SDPModel.h"
#import "ICECandidateModel.h"


//static NSString* const kServerAddress = @"ws://192.168.1.2:9000/chat";
static NSString* const kServerAddress = @"ws://peaceful-hollows-7806.herokuapp.com/chat";

@interface RTCService () <SRWebSocketDelegate, RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate, RTCDataChannelDelegate> {
    SRWebSocket* _webSocket;
    RTCPeerConnectionFactory* _factory;
    RTCPeerConnection* _peerConnection;
    RTCDataChannel* _dataChannel;
    NSArray* _stunServers;
    BOOL _didInitiate;
}

@end

@implementation RTCService

- (void) connectSocket {
    NSMutableArray* stunServers = [[NSMutableArray alloc] init];;
    NSArray* stunServerURLStrings = @[@"stun3.l.google.com:19302",@"stun:stunserver.org",@"stun.xten.com"];
    for(NSString* s in stunServerURLStrings) {
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"stun:%@",s]];
        NSParameterAssert(url);
        RTCICEServer* server = [[RTCICEServer alloc] initWithURI:url username:@"" password:@""];
        NSParameterAssert(server);
        [stunServers addObject:server];
    }
    //RTCICEServer* turnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:@"turn:numb.viagenie.ca"] username:@"webrtc@live.com" password:@"muazkh"];
    //[stunServers addObject:turnServer];
    
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
    ChatControlMessage* message = [[ChatControlMessage alloc] initWithType:CCT_CHAT_REQUEST payload:nil];
    [self sendControlMessage:message];
    NSLog(@"Sending chat request");
}

- (void) disconnectFromPeer {
    
}

- (void) sendText:(NSString *)text {
    NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
    RTCDataBuffer* buffer = [[RTCDataBuffer alloc] initWithData:data isBinary:true];
    [_dataChannel sendData:buffer];
}

- (void) sendControlMessage:(ChatControlMessage*)message {
    NSDictionary* json = [MTLJSONAdapter JSONDictionaryFromModel:message];
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    NSString* jsonText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(error || !data || !jsonText) {
        NSLog(@"Error sending control message %@",message);
    } else {
        [_webSocket send:jsonText];
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
    ICECandidateModel* iceModel = [[ICECandidateModel alloc] initWithICECandidate:candidate];
    ChatControlMessage* message = [[ChatControlMessage alloc] initWithType:CCT_ICE_CANDIDATE payload:iceModel];
    NSLog(@"Sending ice candidate %@",candidate);
    [_delegate rtcServiceDidSendIceMessage:self];
    [self sendControlMessage:message];
}

// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel {
    NSLog(@"Opened data channel");
    _dataChannel = dataChannel;
    _dataChannel.delegate = self;
}

#pragma mark RTCSessionDescriptionDelegate

// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error {
    [_peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
    SDPModel* sdpModel = [[SDPModel alloc] initWithSDP:sdp];
    NSString* messageType = _didInitiate ? CCT_CHAT_OFFER : CCT_CHAT_ANSWER;
    ChatControlMessage* message = [[ChatControlMessage alloc] initWithType:messageType payload:sdpModel];
    NSLog(@"Sending SDP %@",message);
    if(_didInitiate) {
        [_delegate rtcServiceDidSendOffer:self];
    } else {
        [_delegate rtcServiceDidSendAnswer:self];
    }
    [self sendControlMessage:message];
}

// Called when setting a local or remote description.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
    
}

#pragma mark RTCDataChannelDelegate

// Called when the data channel state has changed.
- (void)channelDidChangeState:(RTCDataChannel*)channel {
    NSLog(@"Data channel did change state %u",channel.state);
    if(channel.state == kRTCDataChannelStateOpen) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate rtcServiceDidConnectChannel:self];
        });
        
    }
}

// Called when a data buffer was successfully received.
- (void)channel:(RTCDataChannel*)channel didReceiveMessageWithBuffer:(RTCDataBuffer*)buffer {
    NSLog(@"Channel did receive message %@",buffer);
    NSString* s = [[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate rtcService:self didReceiveText:s];
    });
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
    } else if(control.isOffer) {
        SDPModel* sdpModel = [control payloadAs:SDPModel.class];
        [self handleOffer:sdpModel];
    } else if(control.isAnswer) {
        SDPModel* sdpModel = [control payloadAs:SDPModel.class];
        [self handleAnswer:sdpModel];
    } else if(control.isIceCandidate) {
        ICECandidateModel* ice = [control payloadAs:ICECandidateModel.class];
        BOOL wasAdded = [_peerConnection addICECandidate:ice.candidate];
        NSLog(@"ICE candidate was added %d",wasAdded);
        [_delegate rtcServiceDidReceiveIceMessage:self];
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
    _didInitiate = true;
    RTCDataChannelInit* config = [[RTCDataChannelInit alloc] init];
    config.isOrdered = false;
    _dataChannel = [_peerConnection createDataChannelWithLabel:@"sender" config:config];
    _dataChannel.delegate = self;
    [_peerConnection createOfferWithDelegate:self constraints:nil];
}

- (void) handleOffer:(SDPModel*)sdpModel {
    [_peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdpModel.sdp];
    [_peerConnection createAnswerWithDelegate:self constraints:nil];
}

- (void) handleAnswer:(SDPModel*)sdpModel {
    [_peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdpModel.sdp];
}

@end
