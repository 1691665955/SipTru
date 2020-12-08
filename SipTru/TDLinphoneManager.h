//
//  TDLinphoneManager.h
//  TDEntranceGuard
//
//  Created by 曾龙 on 2019/3/22.
//  Copyright © 2019年 farbell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinphoneManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TDLinphoneManageDelegate <NSObject>

@optional
- (void)callBusy;
- (void)didReceiveCallForID:(NSString *)ID;
- (void)didCallOut;
- (void)didCallEnd;
- (void)loginStatus:(LinphoneRegistrationState)status;
@end

@interface TDLinphoneManager : NSObject
@property (nonatomic, weak) id<TDLinphoneManageDelegate> delegate;
@property (nonatomic, assign) LinphoneRegistrationState registerationState;
+ (instancetype)shareInstance;
+ (void)initLinphoneCore;
+ (void)unInitLinphoneCore;
+ (void)logout;
+ (void)setVideoView:(UIView *)view;
+ (void)call:(NSString *)ID;
+ (void)answer;
+ (void)hangup;
+ (void)micOFF;
+ (void)micON;

+ (void)acceptVideo;

+ (void)switchSoundDevice;
@end

NS_ASSUME_NONNULL_END
