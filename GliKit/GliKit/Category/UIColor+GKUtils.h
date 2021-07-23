//
//  UIColor+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///红
static NSString *const GKColorRed = @"red";

///绿
static NSString *const GKColorGreen = @"green";

///蓝
static NSString *const GKColorBlue = @"blue";

///透明度
static NSString *const GKColorAlpha = @"alpha";


/**
 16进制可不带#，格式为 #c0f，c0f，#cc00ff，cc00ff，#fc0f，fc0f，#ffcc00ff，ffcc00ff
 返回的16进制是不带#的 小写字母
 返回的ARGB 值 rgb，透明度为0~1.0
 */
@interface UIColor (GKUtils)

///获取颜色的ARGB值 0 ~ 1.0
@property(nonatomic, readonly, nullable) NSDictionary<NSString*, NSNumber*> *gkColorARGB;

///获取颜色的16进制 含透明度 FFFFFFFF
@property(nonatomic, readonly) NSString *gkColorHex;

///是否是浅色
@property(nonatomic, readonly) BOOL isLightColor;

///颜色是否相同
- (BOOL)isEqualToColor:(nullable UIColor*) color;

///为某个颜色设置透明度
- (UIColor*)gkColorWithAlpha:(CGFloat) alpha;

///通过16进制值获取颜色 rgb，如果hex里面没有包含rgb，则透明度为1.0
+ (nullable NSDictionary<NSString*, NSNumber*>*)gkColorARGBFromHex:(NSString*) hex;

///通过ARGB值获取颜色的16进制 0~255
+ (NSString*)gkColorHexFromRed:(int) red green:(int) green  blue:(int) blue alpha:(CGFloat) alpha;

///通过16进制颜色值获取颜色 当hex里面有没有透明度值时，透明度为 1.0
+ (nullable UIColor*)gkColorFromHex:(NSString*) hex;

///通过16进制和透明度（0~1.0）值获取颜色 将忽略16进制值里面的透明度
+ (nullable UIColor*)gkColorFromHex:(NSString*) hex alpha:(CGFloat) alpha;

///以整数rpg初始化 0~255，alpha 0~1.0
+ (nullable UIColor*)gkColorWithRed:(int) red green:(int) green blue:(int) blue alpha:(CGFloat) alpha;

@end

NS_ASSUME_NONNULL_END


