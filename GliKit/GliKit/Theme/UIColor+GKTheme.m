//
//  UIColor+GKTheme.m
//  GliKit
//
//  Created by 罗海雄 on 2019/8/21.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UIColor+GKTheme.h"
#import "UIColor+GKUtils.h"

static UIColor *appThemeColor = nil;
static UIColor *appThemeTintColor = nil;
static UIColor *appNavigationBarBackgroundColor = nil;
static UIColor *appNavigationBarTitleColor = nil;
static UIColor *appNavigationBarTintColor = nil;
static UIColor *appSeparatorColor = nil;
static UIColor *appGrayBackgroundColor = nil;
static UIColor *appSkeletonBackgroundColor = nil;
static UIColor *appPlaceholderColor = nil;

@implementation UIColor (GKTheme)

+ (void)setGkThemeColor:(UIColor *)gkThemeColor
{
    appThemeColor = gkThemeColor;
}

+ (UIColor *)gkThemeColor
{
    if(!appThemeColor){
        appThemeColor = UIColor.whiteColor;
    }
    return appThemeColor;
}

+ (void)setGkThemeTintColor:(UIColor *)gkThemeTintColor
{
    appThemeTintColor = gkThemeTintColor;
}

+ (UIColor *)gkThemeTintColor
{
    if(!appThemeTintColor){
        appThemeTintColor = UIColor.blackColor;
    }
    return appThemeTintColor;
}

+ (UIColor *)gkNavigationBarBackgroundColor
{
    if(!appNavigationBarBackgroundColor){
        appNavigationBarBackgroundColor = UIColor.whiteColor;
    }
    return appNavigationBarBackgroundColor;
}

+ (void)setGkNavigationBarBackgroundColor:(UIColor *)gkNavigationBarBackgroundColor
{
    appNavigationBarBackgroundColor = gkNavigationBarBackgroundColor;
}

+ (UIColor *)gkNavigationBarTintColor
{
    if(!appNavigationBarTintColor){
        appNavigationBarTintColor = UIColor.blackColor;
    }
    return appNavigationBarTintColor;
}

+ (void)setGkNavigationBarTintColor:(UIColor *)gkNavigationBarTintColor
{
    appNavigationBarTintColor = gkNavigationBarTintColor;
}

+ (UIColor *)gkNavigationBarTitleColor
{
    if(!appNavigationBarTitleColor){
        appNavigationBarTitleColor = UIColor.blackColor;
    }
    return appNavigationBarTitleColor;
}

+ (void)setGkNavigationBarTitleColor:(UIColor *)gkNavigationBarTitleColor
{
    appNavigationBarTitleColor = gkNavigationBarTitleColor;
}

+ (UIColor *)gkSeparatorColor
{
    if(!appSeparatorColor){
        appSeparatorColor = [UIColor colorWithWhite:0.86 alpha:1.0];
    }
    return appSeparatorColor;
}

+ (void)setGkSeparatorColor:(UIColor *)gkSeparatorColor
{
    appSeparatorColor = gkSeparatorColor;
}

+ (UIColor *)gkGrayBackgroundColor
{
    if(!appGrayBackgroundColor){
        appGrayBackgroundColor = [UIColor gkColorFromHex:@"F2F2F2"];
    }
    return appGrayBackgroundColor;
}

+ (void)setGkGrayBackgroundColor:(UIColor *)gkGrayBackgroundColor
{
    appGrayBackgroundColor = gkGrayBackgroundColor;
}

+ (UIColor *)gkSkeletonBackgroundColor
{
    if(!appSkeletonBackgroundColor){
        appSkeletonBackgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }
    return appSkeletonBackgroundColor;
}

+ (void)setGkSkeletonBackgroundColor:(UIColor *)gkSkeletonBackgroundColor
{
    appSkeletonBackgroundColor = gkSkeletonBackgroundColor;
}

+ (UIColor *)gkPlaceholderColor
{
    if(!appPlaceholderColor){
        appPlaceholderColor = [UIColor colorWithWhite:0.702f alpha:0.7];
    }
    return appPlaceholderColor;
}

+ (void)setGkPlaceholderColor:(UIColor *)gkPlaceholderColor
{
    appPlaceholderColor = gkPlaceholderColor;
}

@end
