//
//  UIApplication+GKTheme.m
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UIApplication+GKTheme.h"

static CGFloat GKSeparatorHeight = 0;

@implementation UIApplication (GKTheme)

+ (CGFloat)gkSeparatorHeight
{
    if(GKSeparatorHeight == 0){
        GKSeparatorHeight = 1.0 / UIScreen.mainScreen.scale;
    }
    return GKSeparatorHeight;
}

+ (void)setGkSeparatorHeight:(CGFloat)gkSeparatorHeight
{
    GKSeparatorHeight = gkSeparatorHeight;
}

@end
