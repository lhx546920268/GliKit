//
//  UIScreen+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIScreen+GKUtils.h"

@implementation UIScreen (GKUtils)

+ (CGFloat)gkWidth
{
    return self.gkSize.width;
}

+ (CGFloat)gkHeight
{
    return self.gkSize.height;
}

+ (CGSize)gkSize
{
    return UIScreen.mainScreen.bounds.size;
}

@end
