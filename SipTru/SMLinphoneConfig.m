//
//  SMLinphoneConfig.m
//  SiMiCloudShare
//
//  Created by MAC_OSSS on 17/4/17.
//  Copyright © 2017年 MAC_OSSS. All rights reserved.
//

#import "SMLinphoneConfig.h"
#import "LinphoneManager.h"


static SMLinphoneConfig *linphoneCfg = nil;
@implementation SMLinphoneConfig

+ (SMLinphoneConfig *)instance{

    @synchronized(self) {
        
        if (linphoneCfg == nil) {
            
            linphoneCfg = [[SMLinphoneConfig alloc] init];
        }
    }
    return linphoneCfg;
}

- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password displayName:(NSString *)displayName domain:(NSString*)domain port:(NSString *)port withTransport:(NSString*)transport iceEnable:(BOOL)iceEnable turnEnable:(BOOL)turnEnable turnServer:(NSString *)turnServer turnUser:(NSString *)turnUser turnPassword:(NSString *)turnPassword {
    
    @try {
        [[LinphoneManager instance] startLinphoneCore];
    } @catch (NSException *exception) {
        
    }
    LinphoneCore *lc = [LinphoneManager getLc];
    
    linphone_core_clear_proxy_config(lc);
    linphone_core_clear_all_auth_info(lc);
    
    LinphoneNatPolicy *policy = linphone_core_get_nat_policy(lc);
    if (policy == nil) {
        policy = linphone_core_create_nat_policy(lc);
    }
    linphone_nat_policy_enable_stun(policy, iceEnable); // We always use STUN with ICE
    linphone_nat_policy_enable_ice(policy, iceEnable);
    linphone_nat_policy_enable_turn(policy, turnEnable);
    if (iceEnable && turnServer.length > 0) {
        if (turnUser.length > 0) {
            linphone_nat_policy_set_stun_server_username(policy, turnUser.UTF8String);
            if (turnPassword.length > 0) {
                const LinphoneAuthInfo *authInfo = linphone_core_find_auth_info(lc, NULL, linphone_nat_policy_get_stun_server_username(policy), NULL);
                if (authInfo == nil) {
                    authInfo = linphone_auth_info_new([turnUser UTF8String]
                                                      , [turnUser UTF8String], [turnPassword UTF8String]
                                                      , NULL
                                                      , NULL
                                                      ,NULL);
                    linphone_core_add_auth_info(lc, authInfo);
                } else {
                    LinphoneAuthInfo *cloneAuthInfo = linphone_auth_info_clone(authInfo);
                    linphone_core_remove_auth_info(lc, authInfo);
                    linphone_auth_info_set_username(cloneAuthInfo, [turnUser UTF8String]);
                    linphone_auth_info_set_userid(cloneAuthInfo, [turnUser UTF8String]);
                    linphone_auth_info_set_password(cloneAuthInfo, [turnPassword UTF8String]);
                    linphone_core_add_auth_info(lc, cloneAuthInfo);
                }
            }
        }
        linphone_nat_policy_set_stun_server(policy, turnServer.UTF8String);
    } else {
        linphone_nat_policy_enable_stun(policy, false); // We always use STUN with ICE
        linphone_nat_policy_enable_ice(policy, false);
        linphone_nat_policy_set_stun_server(policy, NULL);
    }
    
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    
    linphone_core_set_inc_timeout(LC, 65);
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    
    const char *identity = [[NSString stringWithFormat:@"sip:%@@%@", username, domain] cStringUsingEncoding:NSUTF8StringEncoding];
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    if (displayName && displayName.length != 0) {
        linphone_address_set_display_name(linphoneAddress, (displayName.length ? displayName.UTF8String : NULL));
    }
    if( domain && [domain length] != 0) {
        if( transport != nil ){
            server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, port, [transport lowercaseString]];
        }
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    LCSipTransports transportValue = {-1, -1, -1, -1};
    linphone_core_set_sip_transports(lc, &transportValue);
    
    // 添加了昵称后的identity(此处是大坑！大坑！大坑)
    identity = linphone_address_as_string(linphoneAddress);
    
    linphone_address_destroy(linphoneAddress);
    
    linphone_proxy_config_set_nat_policy(proxyCfg, policy);
    
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String]
                                                    , NULL, [password UTF8String]
                                                    , NULL
                                                    , linphone_proxy_config_get_realm(proxyCfg)
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    linphone_proxy_config_set_identity(proxyCfg, identity);
    linphone_proxy_config_set_expires(proxyCfg, 2000);
    linphone_proxy_config_enable_register(proxyCfg, true);
    linphone_core_add_auth_info(lc, info);
    linphone_core_add_proxy_config(lc, proxyCfg);
    linphone_core_set_default_proxy_config(lc, proxyCfg);
    ms_free(identity);
    
    return TRUE;
}

#pragma mark - 注册
- (void)registeByUserName:(NSString *)userName pwd:(NSString *)pwd domain:(NSString *)domain port:(NSString *)port tramsport:(NSString *)transport {
    
    //设置超时
    linphone_core_set_inc_timeout(LC, 60);

    //创建配置表
    LinphoneProxyConfig *proxyCfg = linphone_core_create_proxy_config(LC);

    //初始化电话号码
    linphone_proxy_config_normalize_phone_number(proxyCfg,userName.UTF8String);

    //创建地址
    NSString *address = [NSString stringWithFormat:@"sip:%@@%@",userName,domain];//如:sip:123456@sip.com
    LinphoneAddress *identify = linphone_address_new(address.UTF8String);
    
    linphone_address_set_domain(identify, domain.UTF8String);
    
    linphone_proxy_config_set_identity_address(proxyCfg, identify);

    linphone_proxy_config_set_route(
                                    proxyCfg,
                                    [NSString stringWithFormat:@"%s;transport=%s", domain.UTF8String,  transport.lowercaseString.UTF8String]
                                    .UTF8String);
    linphone_proxy_config_set_server_addr(
                                          proxyCfg,
                                          [NSString stringWithFormat:@"%s:%@;transport=%s", domain.UTF8String, port, transport.lowercaseString.UTF8String]
                                          .UTF8String);
    
    linphone_proxy_config_enable_register(proxyCfg, TRUE);



    //创建证书
    LinphoneAuthInfo *info = linphone_auth_info_new(userName.UTF8String, nil, pwd.UTF8String, nil, linphone_proxy_config_get_realm(proxyCfg), linphone_proxy_config_get_domain(proxyCfg));

    //添加证书
    linphone_core_add_auth_info(LC, info);

    //销毁地址
    linphone_address_unref(identify);

    //注册
    linphone_proxy_config_enable_register(proxyCfg, YES);

    // 设置一个SIP路线  外呼必经之路
    linphone_proxy_config_set_route(proxyCfg,domain.UTF8String);

    //添加到配置表,添加到linphone_core
    linphone_core_add_proxy_config(LC, proxyCfg);

    //设置成默认配置表
    linphone_core_set_default_proxy_config(LC, proxyCfg);

//
//    //设置音频编码格式
////    [self synchronizeCodecs:linphone_core_get_audio_codecs(LC)];

    [self synchronizeVideoCodecs:linphone_core_get_video_codecs(LC)];
    
}
#pragma mark - 设置音频编码格式
- (void)synchronizeCodecs:(const MSList *)codecs {
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = codecs; elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        
//        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
//        NSString *normalBt = [NSString stringWithFormat:@"%d",pt->clock_rate];
//       if ([sreung isEqualToString:@"G729"]) {
        
        linphone_core_enable_payload_type(LC,pt, YES);
        
//        }
//       else
//        {
//
//            linphone_core_enable_payload_type(LC, pt, 0);
//        }
        
    }
}
#pragma mark - 设置视频编码格式
- (void)synchronizeVideoCodecs:(const MSList *)codecs {
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = codecs; elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if ([sreung isEqualToString:@"H264"]) {
            
            linphone_core_enable_payload_type(LC, pt, 1);
            
        }else {
            
            linphone_core_enable_payload_type(LC, pt, 0);
        }
    }
}

- (NSMutableArray *)getAllEnableVideoCodec{

    NSMutableArray *codeArray = [NSMutableArray array];
   
    PayloadType *pt;
    const MSList *elem;
    
    for (elem =  linphone_core_get_video_codecs(LC); elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if (linphone_core_payload_type_enabled(LC,pt)) {
            [codeArray addObject:sreung];
        }
    }
    return codeArray;
    
}
- (NSMutableArray *)getAllEnableAudioCodec{
    
    NSMutableArray *codeArray = [NSMutableArray array];
    NSMutableSet *mutableSet = [NSMutableSet set];
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem =  linphone_core_get_audio_codecs(LC); elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if (linphone_core_payload_type_enabled(LC,pt)) {
            [codeArray addObject:sreung];
            [mutableSet addObject:sreung];
            
        }
    }
    
    return codeArray;
    
}
#pragma mark - 开启关闭视频编码
- (void)enableVideoCodecWithString:(NSString *)codec enable:(BOOL)enable{
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = linphone_core_get_video_codecs(LC); elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if ([sreung isEqualToString:codec]) {
            
           linphone_core_enable_payload_type(LC, pt, enable);
        }
    }
}
#pragma mark - 拨打电话
- (void)callPhoneWithPhoneNumber:(NSString *)phone withVideo:(BOOL)video{

    @try {
        if ([LinphoneManager getLc]) {
            LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
            if (!cfg) {
                return;
            }
            
            LinphoneAddress *addr = [LinphoneManager.instance normalizeSipOrPhoneAddress:phone];
            
            [LinphoneManager.instance call:addr];
            if (addr) {
                linphone_address_unref(addr);
            }
        }
    } @catch (NSException *exception) {
        
    }
    
}
- (void)switchCamera{

    const char *currentCamId = (char *)linphone_core_get_video_device(LC);
    const char **cameras = linphone_core_get_video_devices(LC);
    const char *newCamId = NULL;
    int i;
    
    for (i = 0; cameras[i] != NULL; ++i) {
        if (strcmp(cameras[i], "StaticImage: Static picture") == 0)
            continue;
        if (strcmp(cameras[i], currentCamId) != 0) {
            newCamId = cameras[i];
            break;
        }
    }
    if (newCamId) {
       // LOGI(@"Switching from [%s] to [%s]", currentCamId, newCamId);
        linphone_core_set_video_device(LC, newCamId);
        LinphoneCall *call = linphone_core_get_current_call(LC);
        if (call != NULL) {
            linphone_call_update(call, NULL);
        }
    }
}
- (void)acceptCall{
    
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        
        [[LinphoneManager instance] acceptCall:call evenWithVideo:YES];
        
    }
}

- (void)hold{
    
}

- (void)unhold{
    
}

- (void)remoteAccount{
    
}

- (void)haveCall{
    
}

- (void)muteMic{
    
}

- (void)enableSpeaker{
    
}

- (void)tabeSnapshot{
    
}

- (void)takePreviewSnapshot{
    
}

- (void)setVideoSize{
    
}

- (void)showVideo{
    
    
}

- (void)setRemoteVieoPreviewWindow:(UIView *)preview{
    
    linphone_core_set_native_preview_window_id(LC, (__bridge void *)(preview));
}

- (void)setNativeVideoPreviewWindow:(UIView *)preview{
    
    linphone_core_set_native_video_window_id(LC, (__bridge void *)(preview));
}

//退出登录
- (void) logout {
    @try {
        if ([LinphoneManager getLc]) {
            LinphoneManager.instance.conf = TRUE;
            linphone_core_terminate_all_calls(LC);
            [[LinphoneManager instance] removeAllAccounts];
            [LinphoneManager.instance destroyLinphoneCore];
        }
    } @catch (NSException *exception) {
        
    }
}

@end
