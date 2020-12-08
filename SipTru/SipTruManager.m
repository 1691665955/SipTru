//
//  SipTruManager.m
//  SipTruDemo
//
//  Created by 曾龙 on 2020/12/8.
//

#import "SipTruManager.h"
#import "TDLinphoneManager.h"
#import "SMLinphoneConfig.h"

@interface SipTruManager ()<TDLinphoneManageDelegate>

@end

@implementation SipTruManager
+ (instancetype)shareInstance {
    static SipTruManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
        [[TDLinphoneManager shareInstance] setDelegate:manager];
        [TDLinphoneManager initLinphoneCore];
    });
    return manager;
}

+ (SipTruLoginStatus)getLoginStatus {
    switch ([TDLinphoneManager shareInstance].registerationState) {
        case LinphoneRegistrationNone:
            return SipTruLoginStatusNone;
            break;
        case LinphoneRegistrationOk:
            return SipTruLoginStatusOk;
            break;
        case LinphoneRegistrationProgress:
            return SipTruLoginStatusProgress;
            break;
        case LinphoneRegistrationCleared:
            return SipTruLoginStatusNone;
            break;
        case LinphoneRegistrationFailed:
            return SipTruLoginStatusFailed;
            break;
        default:
            break;
    }
}

+ (void)loginWithSipID:(NSString *)sipID sipPassword:(NSString *)sipPassword sipDomain:(NSString *)sipDomain sipPort:(NSString *)sipPort sipTransport:(NSString *)sipTransport iceEnable:(BOOL)iceEnable turnEnable:(BOOL)turnEnable turnServer:(NSString *)turnServer turnUser:(NSString *)turnUser turnPassword:(NSString *)turnPassword {
    [[SMLinphoneConfig instance] addProxyConfig:sipID password:sipPassword displayName:sipID domain:sipDomain port:sipPort withTransport:sipTransport iceEnable:iceEnable turnEnable:turnEnable turnServer:turnServer turnUser:turnUser turnPassword:turnPassword];
}

+ (void)logout{
    [TDLinphoneManager logout];
}

+ (void)setVideoView:(UIView *)view {
    [TDLinphoneManager setVideoView:view];
}

+ (void)call:(NSString *)ID {
    [TDLinphoneManager call:ID];
}

+ (void)answer {
    [TDLinphoneManager answer];
}

+ (void)hangup {
    [TDLinphoneManager hangup];
}

+ (void)micOFF {
    [TDLinphoneManager micOFF];
}

+ (void)micON {
    [TDLinphoneManager micON];
}

+ (void)switchSoundDevice {
    [TDLinphoneManager switchSoundDevice];
}

#pragma mark - TDLinphoneManageDelegate
- (void)didCallEnd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCallEnd)]) {
        [self.delegate didCallEnd];
    }
}

- (void)didCallOut {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCallOut)]) {
        [self.delegate didCallOut];
    }
}

- (void)callBusy {
    if (self.delegate && [self.delegate respondsToSelector:@selector(callBusy)]) {
        [self.delegate callBusy];
    }
}

- (void)didReceiveCallForID:(NSString *)ID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveCallForID:)]) {
        [self.delegate didReceiveCallForID:ID];
    }
}

- (void)loginStatus:(LinphoneRegistrationState)status {
    if (self.loginStatusUpdate) {
        self.loginStatusUpdate([SipTruManager getLoginStatus]);
    }
}

@end
