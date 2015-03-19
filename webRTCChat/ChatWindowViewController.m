//  Created by Alexander Skorulis on 13/03/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.

#import "ChatWindowViewController.h"
#import <Masonry/Masonry.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "UIViewController+KeyboardAnimation.h"

@interface ChatWindowViewController () <RTCServiceDelegate> {
    UITextView* _chatText;
    UIButton* _sendButton;
    UIButton* _connectButton;
    RTCService* _service;
    NSMutableAttributedString* _text;
}

@property (nonatomic, readonly) MASConstraint* entryBottomConstraint;
@property (nonatomic, readonly) UITextView* entryText;


@end

@implementation ChatWindowViewController

- (instancetype) initWithService:(RTCService*)service {
    self = [super init];
    _service = service;
    _service.delegate = self;
    _text = [[NSMutableAttributedString alloc] init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chatText = [[UITextView alloc] init];
    _chatText.editable = false;
    _chatText.font = [UIFont systemFontOfSize:16];
    _chatText.backgroundColor = [UIColor grayColor];
    
    _sendButton = [[UIButton alloc] init];
    _sendButton.backgroundColor = [UIColor whiteColor];
    FAKIcon* sendIcon = [FAKFontAwesome sendIconWithSize:30];
    [_sendButton setAttributedTitle:sendIcon.attributedString forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _connectButton = [[UIButton alloc] init];
    FAKIcon* connectIcon = [FAKFontAwesome powerOffIconWithSize:30];
    [connectIcon addAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
    [_connectButton setAttributedTitle:connectIcon.attributedString forState:UIControlStateNormal];
    [_connectButton addTarget:self action:@selector(connectPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _entryText = [[UITextView alloc] init];
    _entryText.editable = true;
    _entryText.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:_chatText];
    [self.view addSubview:_entryText];
    [self.view addSubview:_sendButton];
    [self.view addSubview:_connectButton];
    
    [self buildLayout];
    [_service connectSocket];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        CGFloat showingOffset = -CGRectGetHeight(keyboardRect);
        weakSelf.entryBottomConstraint.offset = isShowing ? showingOffset  : 0;
        [weakSelf.view layoutIfNeeded];
    } completion:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self an_unsubscribeKeyboard];
}

- (void) buildLayout {
    [_chatText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(20);
    }];
    
    [_entryText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_chatText.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(_sendButton.mas_left);
        make.height.equalTo(@80);
        _entryBottomConstraint = make.bottom.equalTo(self.view);
    }];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.top.bottom.equalTo(_entryText);
        make.height.equalTo(_sendButton.mas_width);
    }];
    
    [_connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.right.equalTo(_sendButton);
        make.bottom.equalTo(_chatText);
    }];
}

#pragma mark RTCServiceDelegate

- (void) rtcServiceDidSendIceMessage:(RTCService*)rtcService {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendText:@"sent ice candidate" name:@"System" color:[UIColor yellowColor]];
    });
}

- (void) rtcServiceDidReceiveIceMessage:(RTCService*)rtcService {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendText:@"received ice candidate" name:@"System" color:[UIColor yellowColor]];
    });
}

- (void) rtcServiceDidSendOffer:(RTCService*)rtcService {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendText:@"sent chat offer" name:@"System" color:[UIColor yellowColor]];
    });
}

- (void) rtcServiceDidSendAnswer:(RTCService*)rtcService {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendText:@"sent chat answer" name:@"System" color:[UIColor yellowColor]];
    });
}

- (void) rtcServiceDidConnectSocket:(RTCService*)rtcService {
    [self appendText:@"connected to server" name:@"System" color:[UIColor yellowColor]];
    _connectButton.enabled = true;
}

- (void) rtcServiceDidConnectChannel:(RTCService*)rtcService {
    [self appendText:@"found user, chat away" name:@"System" color:[UIColor yellowColor]];
}

- (void) rtcService:(RTCService*)rtcService didReceiveText:(NSString*)text {
    [self appendText:text name:@"Stranger" color:[UIColor purpleColor]];
}

#pragma mark actions

- (void) connectPressed:(id)sender {
    [self appendText:@"searching for user..." name:@"System" color:[UIColor yellowColor]];
    [_service connectToPeer];
}

- (void) sendPressed:(id)sender {
    NSString* toSend = _entryText.text;
    if(toSend.length == 0) {
        return;
    }
    [self appendText:toSend name:@"You" color:[UIColor blueColor]];
    _entryText.text = nil;
    [_service sendText:toSend];
}

- (void) appendText:(NSString*)text name:(NSString*)name color:(UIColor*)color {
    NSString* s = [NSString stringWithFormat:@"%@ : %@\n",name,text];
    NSAttributedString* att = [[NSAttributedString alloc] initWithString:s attributes:@{NSForegroundColorAttributeName : color, NSFontAttributeName: [UIFont systemFontOfSize:18]}];
    [_text appendAttributedString:att];
    _chatText.attributedText = _text;
    [_chatText scrollRangeToVisible:NSMakeRange(_text.length-2, 1)];
}
@end
