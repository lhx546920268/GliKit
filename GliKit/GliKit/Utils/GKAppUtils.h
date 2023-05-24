//
//  GKAppUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/26.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///与app有关的工具类
@interface GKAppUtils : NSObject

///app版本号
@property(class, nonatomic, readonly) NSString *appVersion;

///是否是测试包 用版本号识别是否是测试包 如2.6.3.01 3个点以上的是测试包
@property(class, nonatomic, readonly) BOOL isTestApp;

///app名称
@property(class, nonatomic, readonly) NSString *appName;

///app图标
@property(class, nonatomic, readonly, nullable) UIImage *appIcon;

///bundle id
@property(class, nonatomic, readonly) NSString *bundleId;

///获取唯一标识符
@property(class, nonatomic, readonly) NSString *uuid;

///获取ip地址，只能获取局域网ip
@property(class, nonatomic, readonly, nullable) NSString *currentIP;

///是否有相册权限
@property(class, nonatomic, readonly) BOOL hasPhotosAuthorization;

///拨打电话
+ (void)makePhoneCall:(nullable NSString*) mobile;

///打开一个URL 兼容所有版本 校验是否可以打开
+ (void)openCompatURL:(NSURL*) URL;

///打开一个URL 兼容所有版本 校验是否可以打开
+ (void)openCompatURL:(NSURL*) URL callCanOpen:(BOOL) call;

///打开设置
+ (void)openSettings;

///打开通知设置 iOS 15.4之后才行，否则只是打开设置
+ (void)openNotificationSettings;

///请求相册权限 如果已授权 则回调，否则在授权完成后才回调 保证在主线程回调
+ (void)requestPhotosAuthorizationWithCompletion:(void(^)(BOOL hasAuth)) completion;

@end

NS_ASSUME_NONNULL_END

