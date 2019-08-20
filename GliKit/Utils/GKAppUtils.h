//
//  GKAppUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/26.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///与app有关的工具类
@interface GKAppUtils : NSObject

///app版本号
@property(class, nonatomic, readonly) NSString *appVersion;

///是否是测试包 用版本号识别是否是测试包 如2.6.3.01 长度大于7的是测试包
@property(class, nonatomic, readonly) BOOL isTestApp;

///app名称
@property(class, nonatomic, readonly) NSString *appName;

///app图标
@property(class, nonatomic, readonly) UIImage *appIcon;

///获取唯一标识符
@property(class, nonatomic, readonly) NSString *uuid;

///获取ip地址
@property(class, nonatomic, readonly) NSString *currentIP;

///拨打电话 是否显示提示框
+ (void)makePhoneCall:(NSString*) mobile shouldAlert:(BOOL) alert;

///打开一个URL 兼容所有版本
+ (void)openCompatURL:(NSURL*) URL;

///打开设置
+ (void)openSettings;

@end

