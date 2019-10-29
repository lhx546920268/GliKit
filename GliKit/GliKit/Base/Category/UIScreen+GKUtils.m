//
//  UIScreen+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
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
    return UIScreen.mainScreen.bounds.size;
}

@end
