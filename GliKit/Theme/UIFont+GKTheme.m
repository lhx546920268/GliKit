//
//  UIFont+GKTheme.m
//  AFNetworking
//
//  Created by 罗海雄 on 2019/9/2.
//

#import "UIFont+GKTheme.h"

static UIFont *appNavigationBarItemFont = nil;

@implementation UIFont (GKTheme)

+ (UIFont *)gkNavigationBarItemFont
{
    if(!appNavigationBarItemFont){
        appNavigationBarItemFont = [UIFont systemFontOfSize:16];
    }
    return appNavigationBarItemFont;
}

+ (void)setGkNavigationBarItemFont:(UIFont *)gkNavigationBarItemFont
{
    appNavigationBarItemFont = gkNavigationBarItemFont;
}

@end
