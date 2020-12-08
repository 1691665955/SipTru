//
//  SipTruManager.h
//  SipTruDemo
//
//  Created by 曾龙 on 2020/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SipTruLoginStatus) {
    SipTruLoginStatusNone,///未登录
    SipTruLoginStatusProgress,///登录中
    SipTruLoginStatusOk,///登录成功
    SipTruLoginStatusFailed//登录失败
};

@protocol SipTruManagerDeleagte <NSObject>

@optional

/// 呼叫忙碌（主动）
- (void)callBusy;

/// 收到呼叫
/// @param ID 呼叫的用户id
- (void)didReceiveCallForID:(NSString *)ID;

/// 成功呼叫（主动）
- (void)didCallOut;

/// 呼叫或通话结束
- (void)didCallEnd;

@end

@interface SipTruManager : NSObject
@property (nonatomic, weak) id<SipTruManagerDeleagte> delegate;

/// 登录状态回调
@property (nonatomic, copy) void (^loginStatusUpdate)(SipTruLoginStatus status);
/// 初始化SDK
+ (instancetype)shareInstance;

/// 获取Sip登录状态
+ (SipTruLoginStatus)getLoginStatus;

/// 登录账号
/// @param sipID Sip服务器的账号
/// @param sipPassword Sip服务器的密码
/// @param sipDomain Sip服务器的地址
/// @param sipPort Sip服务器的端口号
/// @param sipTransport Sip服务器的传输协议
/// @param iceEnable 是否开启ICE服务
/// @param turnEnable 是否开启TURN服务
/// @param turnServer TURN服务器地址
/// @param turnUser TURN服务器用户名
/// @param turnPassword TURN服务器密码
+ (void)loginWithSipID:(NSString *)sipID sipPassword:(NSString *)sipPassword sipDomain:(NSString *)sipDomain sipPort:(NSString *)sipPort sipTransport:(NSString *)sipTransport iceEnable:(BOOL)iceEnable turnEnable:(BOOL)turnEnable turnServer:(NSString *)turnServer turnUser:(NSString *)turnUser turnPassword:(NSString *)turnPassword;

/// 退出登录
+ (void)logout;

/// 设置视频显示View
/// @param view 用于显示视频的View
+ (void)setVideoView:(UIView *)view;

/// 呼叫用户
/// @param ID 用户ID
+ (void)call:(NSString *)ID;

/// 接听呼叫
+ (void)answer;

/// 挂断呼叫或通话
+ (void)hangup;

/// 静音
+ (void)micOFF;

/// 取消静音
+ (void)micON;

/// 切换免提和听筒
+ (void)switchSoundDevice;
@end

NS_ASSUME_NONNULL_END
