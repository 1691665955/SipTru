//
//  SMLinphoneConfig.h
//  SiMiCloudShare
//
//  Created by MAC_OSSS on 17/4/17.
//  Copyright © 2017年 MAC_OSSS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMLinphoneConfig : NSObject

+ (SMLinphoneConfig *)instance;

- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password displayName:(NSString *)displayName domain:(NSString*)domain port:(NSString *)port withTransport:(NSString*)transport iceEnable:(BOOL)iceEnable turnEnable:(BOOL)turnEnable turnServer:(NSString *)turnServer turnUser:(NSString *)turnUser turnPassword:(NSString *)turnPassword;

- (void) logout;

- (void)registeByUserName:(NSString *)userName pwd:(NSString *)pwd domain:(NSString *)domain port:(NSString *)port tramsport:(NSString *)transport;

- (void)callPhoneWithPhoneNumber:(NSString *)phone withVideo:(BOOL)video;

- (void)switchCamera;

- (void)enableVideoCodecWithString:(NSString *)codec enable:(BOOL)enable;

- (NSMutableArray *)getAllEnableVideoCodec;

- (NSMutableArray *)getAllEnableAudioCodec;

- (void)acceptCall;

- (void)hold;

- (void)unhold;

- (void)remoteAccount;

- (void)haveCall;

- (void)muteMic;

- (void)enableSpeaker;

- (void)tabeSnapshot;

- (void)takePreviewSnapshot;

- (void)setVideoSize;

- (void)showVideo;

- (void)setRemoteVieoPreviewWindow:(UIView *)preview;

//- (void)setCurrentVideoPreviewWindow:(UIView *)preview;




@end
