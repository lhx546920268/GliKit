//
//  UIApplication+GKTheme.m
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UIApplication+GKTheme.h"

static CGFloat appSeparatorHeight = 0;
static CGFloat appNavigationBarMargin = 12;
static CGFloat appNavigationBarTitleViewItemMargin = -6;
static UIStatusBarStyle appStatusBarStyle = UIStatusBarStyleDefault;

@implementation UIApplication (GKTheme)

+ (CGFloat)gkSeparatorHeight
{
    if(appSeparatorHeight == 0){
        appSeparatorHeight = 1.0 / UIScreen.mainScreen.scale;
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

+ (CGFloat)gkNavigationBarTitleViewItemMargin
{
    return appNavigationBarTitleViewItemMargin;
}

+ (void)setGkNavigationBarTitleViewItemMargin:(CGFloat)gkNavigationBarTitleViewItemMargin
{
    appNavigationBarTitleViewItemMargin = gkNavigationBarTitleViewItemMargin;
}

+ (UIStatusBarStyle)gkStatusBarStyle
{
    return appStatusBarStyle;
}

+ (void)setGkStatusBarStyle:(UIStatusBarStyle)gkStatusBarStyle
{
    appStatusBarStyle = gkStatusBarStyle;
}

@end
