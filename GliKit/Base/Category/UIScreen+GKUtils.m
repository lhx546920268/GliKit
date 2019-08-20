//
//  UIScreen+GKUtils.m
//  Zegobird
//
//  Created by 唐建平 on 2019/3/20.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIScreen+GKUtils.h"

@implementation UIScreen (GKUtils)

+ (CGFloat)gk_screenWidth
{
    return self.gk_screenSize.width;
}

+ (CGFloat)gk_screenHeight
{
    return self.gk_screenSize.height;
}

+ (CGSize)gk_screenSize
{
    CGSize size = UIScreen.mainScreen.nativeBounds.size;
    size.width /= UIScreen.mainScreen.nativeScale;
    size.height /= UIScreen.mainScreen.nativeScale;
    
    return size;
}

@end
