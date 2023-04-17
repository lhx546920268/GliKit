//
//  UIScreen+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIScreen+GKUtils.h"

@implementation UIScreen (GKUtils)

+ (UIScreen *)gkMainScreen
{
    //无法在其他线程使用
//    UIScreen *screen = nil;
//    if (@available(iOS 13, *)) {
//        UIWindowScene *scene = (UIWindowScene*)UIApplication.sharedApplication.connectedScenes.anyObject;
//        if ([scene isKindOfClass:UIWindowScene.class]) {
//            screen = scene.screen;
//        }
//    }
//
//    return screen ?: UIScreen.mainScreen;
    return UIScreen.mainScreen;
}

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
    return self.gkMainScreen.bounds.size;
}

@end
