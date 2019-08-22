//
//  UIScreen+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIScreen+GKUtils.h"

@implementation UIScreen (GKUtils)

+ (CGFloat)gkScreenWidth
{
    return self.gkScreenSize.width;
}

+ (CGFloat)gkScreenHeight
{
    return self.gkScreenSize.height;
}

+ (CGSize)gkScreenSize
{
    CGSize size = UIScreen.mainScreen.nativeBounds.size;
    size.width /= UIScreen.mainScreen.nativeScale;
    size.height /= UIScreen.mainScreen.nativeScale;
    
    return size;
}

@end
