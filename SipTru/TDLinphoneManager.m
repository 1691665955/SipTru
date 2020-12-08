//
//  TDLinphoneManager.m
//  TDEntranceGuard
//
//  Created by 曾龙 on 2019/3/22.
//  Copyright © 2019年 farbell. All rights reserved.
//

#import "TDLinphoneManager.h"
#import "SMLinphoneConfig.h"
#import "LinphoneManager.h"


@interface TDLinphoneManager()
@property (nonatomic, assign) LinphoneCall *call;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation TDLinphoneManager
+ (instancetype)shareInstance {
    static TDLinphoneManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotification:) name:kLinphoneCallUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithRegister:) name:kLinphoneRegistrationUpdate object:nil];
    }
    return self;
}

- (void)dealWithNotification:(NSNotification *)notification {
    LinphoneCall *call = [[notification.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = [[notification.userInfo objectForKey:@"state"] intValue];
    NSString *message = [notification.userInfo objectForKey:@"message"];
    
    NSLog(@"LinphoneCallStatezz:%@",message);
    if ([message containsString:@"Connected (streams running)"]) {
        [self performSelector:@selector(judgeIsAcceptVideo:) withObject:notification afterDelay:0.5f];
    } else if ([message containsString:@"Call declined"] || [message containsString:@"Another call is in progress"] || [message containsString:@"Busy"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(callBusy)]) {
                [self.delegate callBusy];
            }
        });
        return;
    }
    switch (state) {
        case LinphoneCallIncomingReceived:
        case LinphoneCallIncomingEarlyMedia: {
            if (self.call) {
                const LinphoneAddress *oldAddress = linphone_call_get_remote_address(self.call);
                NSString *oldUsername = [NSString stringWithUTF8String:linphone_address_get_username(oldAddress)];
                const LinphoneAddress *address = linphone_call_get_remote_address(call);
                NSString *username = [NSString stringWithUTF8String:linphone_address_get_username(address)];
                if (![oldUsername isEqualToString:username]) {
                    [TDLinphoneManager decline:call];
                    return;
                }
            }
            const LinphoneAddress *address = linphone_call_get_remote_address(call);
            NSString *localID = [NSString stringWithUTF8String:linphone_address_get_username(address)];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.call = call;
                if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveCallForID:)]) {
                    [self.delegate didReceiveCallForID:localID];
                }
            });
            break;
        }
        case LinphoneCallOutgoingInit: {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.call = call;
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCallOut)]) {
                    [self.delegate didCallOut];
                }
            });
            break;
        }
        case LinphoneCallPausedByRemote: {

            break;
        }
            
        case LinphoneCallConnected: {
            
            break;
        }
        case LinphoneCallStreamsRunning: {
            [LinphoneManager instance].speakerEnabled = YES;
            break;
        }
        case LinphoneCallUpdatedByRemote: {
            const LinphoneCallParams *current = linphone_call_get_current_params(call);
            const LinphoneCallParams *remote = linphone_call_get_remote_params(call);
            
            if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
                
            }
            break;
        }
        case LinphoneCallError:
        case LinphoneCallEnd: {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCallEnd)]) {
                    [self.delegate didCallEnd];
                }
            });
            break;
        }
        case LinphoneCallEarlyUpdatedByRemote:
        case LinphoneCallEarlyUpdating:
        case LinphoneCallIdle:
            break;
        case LinphoneCallOutgoingEarlyMedia:
        case LinphoneCallOutgoingProgress: {
            
            break;
        }
        case LinphoneCallOutgoingRinging:
        case LinphoneCallPaused:
        case LinphoneCallPausing:
        case LinphoneCallRefered:
            break;
        case LinphoneCallReleased:
        {
            break;
        }
        case LinphoneCallResuming: {
            
            break;
        }
        case LinphoneCallUpdating:
            break;
    }
}

- (void)dealWithRegister:(NSNotification *)notification {
    LinphoneRegistrationState state = [[notification.userInfo objectForKey:@"state"] intValue];
    self.registerationState = state;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginStatus:)]) {
            [self.delegate loginStatus:state];
        }
    });
    switch (state) {
        case LinphoneRegistrationNone:
            NSLog(@"LinphoneRegistrationState========无账号");
            [self saveRegisteratonState:@"无账号"];
            break;
        case LinphoneRegistrationProgress:
            NSLog(@"LinphoneRegistrationState========注册中");
            [self saveRegisteratonState:@"注册中"];
            break;
        case LinphoneRegistrationOk:
            NSLog(@"LinphoneRegistrationState========注册成功");
            [self saveRegisteratonState:@"注册成功"];
            //回音抑制
            linphone_core_enable_echo_limiter(LC, TRUE);
            linphone_core_enable_echo_cancellation(LC, TRUE);
            break;
        case LinphoneRegistrationCleared:
            NSLog(@"LinphoneRegistrationState========注销成功");
            [self saveRegisteratonState:@"注销成功"];
            break;
        case LinphoneRegistrationFailed:
            NSLog(@"LinphoneRegistrationState========注册失败");
            [self saveRegisteratonState:@"注册失败"];
            break;
        default:
            break;
    }
}

- (void)saveRegisteratonState:(NSString *)state {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:state forKey:@"LinphoneRegistrationState"];
    [defaults synchronize];
}


+ (void)initLinphoneCore {
    [[LinphoneManager instance] startLinphoneCore];
}

+ (void)unInitLinphoneCore {
    [[LinphoneManager instance] destroyLinphoneCore];
}

+ (void)logout {
    [[SMLinphoneConfig instance] logout];
}

+ (void)setVideoView:(UIView *)view {
    linphone_core_set_native_video_window_id(LC, (__bridge void *)(view));
}

+ (void)call:(NSString *)ID {
    [[SMLinphoneConfig instance] callPhoneWithPhoneNumber:ID withVideo:YES];
}

+ (void)answer {
    if ([TDLinphoneManager shareInstance].call) {
        linphone_call_accept([TDLinphoneManager shareInstance].call);
    }
}

+ (void)hangup {
    if ([TDLinphoneManager shareInstance].call) {
        linphone_call_terminate([TDLinphoneManager shareInstance].call);
    }
}

+ (void)decline:(LinphoneCall *)call {
    if ([TDLinphoneManager shareInstance].call) {
        LinphoneErrorInfo *info = linphone_error_info_new();
        linphone_error_info_set(info, [@"SIP" UTF8String], LinphoneReasonForbidden, 403, [@"Another call is in progress" UTF8String], nil);
        linphone_call_terminate_with_error_info(call, info);
    }
}

+ (void)micON {
    linphone_core_enable_mic(LC, true);
}

+ (void)micOFF {
    linphone_core_enable_mic(LC, false);
}

+ (void)acceptVideo {
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        LinphoneCallAppData *callAppData = (__bridge LinphoneCallAppData *)linphone_call_get_user_data(call);
        callAppData->videoRequested = TRUE; /* will be used later to notify user if video was not activated because of the linphone core*/
        LinphoneCallParams *call_params = linphone_core_create_call_params(LC,call);
        linphone_call_params_enable_video(call_params, TRUE);
        linphone_core_update_call(LC, call, call_params);
        linphone_call_params_destroy(call_params);
    }
}

- (void)judgeIsAcceptVideo:(NSNotification *)notification {
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call != NULL) {
        @try {
            LinphoneCallStats *stats = linphone_call_get_video_stats(call);
            if (stats != NULL) {
                float download = linphone_call_stats_get_download_bandwidth(stats);
                if (download == 0) {
                    [TDLinphoneManager acceptVideo];
                }
            }
        } @catch (NSException *exception) {
            
        }
    }
}

+ (void)switchSoundDevice {
    if ([LinphoneManager instance].speakerEnabled == YES) {
        [LinphoneManager instance].speakerEnabled = NO;
    } else {
        [LinphoneManager instance].speakerEnabled = YES;
    }
}
@end
