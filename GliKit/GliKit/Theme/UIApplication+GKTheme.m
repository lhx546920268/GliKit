//
//  UIApplication+GKTheme.m
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UIApplication+GKTheme.h"
#import "UIScreen+GKUtils.h"

static CGFloat appSeparatorHeight = 0;
static CGFloat appNavigationBarMargin = 15;
static UIStatusBarStyle appStatusBarStyle;
static NSString *appKeychainAccessGroup = nil;

@implementation UIApplication (GKTheme)

+ (void)load
{
    appStatusBarStyle = UIApplication.gkDarkStatusBarStyle;
}

+ (CGFloat)gkSeparatorHeight
{
    if(appSeparatorHeight == 0){
        appSeparatorHeight = 1.0 / UIScreen.gkMainScreen.scale;
    }
    return appSeparatorHeight;
}

+ (void)setGkSeparatorHeight:(CGFloat)gkSeparatorHeight
{
    appSeparatorHeight = gkSeparatorHeight;
}

+ (CGFloat)gkNavigationBarMargin
{
    return appNavigationBarMargin;
}

+ (void)setGkNavigationBarMargin:(CGFloat)gkNavigationBarMargin
{
    appNavigationBarMargin = gkNavigationBarMargin;
}

+ (CGFloat)gkNavigationBarMarginForItem
{
    return 6;
}

+ (CGFloat)gkNavigationBarMarginForScreen
{
    return 0;
}

+ (UIStatusBarStyle)gkStatusBarStyle
{
    return appStatusBarStyle;
}

+ (void)setGkStatusBarStyle:(UIStatusBarStyle)gkStatusBarStyle
{
    appStatusBarStyle = gkStatusBarStyle;
}

+ (UIStatusBarStyle)gkDarkStatusBarStyle
{
    if (@available(iOS 13, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

+ (CGFloat)gkStatusBarHeight
{
    return UIApplication.sharedApplication.statusBarFrame.size.height;
}

+ (void)setGkKeychainAcessGroup:(NSString *) group
{
    appKeychainAccessGroup = group;
}

+ (NSString *)gkKeychainAcessGroup
{
    return appKeychainAccessGroup;
}

@end
