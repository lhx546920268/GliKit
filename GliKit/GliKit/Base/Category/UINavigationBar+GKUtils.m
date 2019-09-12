//
//  UINavigationBar+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UINavigationBar+GKUtils.h"
#import <objc/runtime.h>
#import "UIApplication+GKTheme.h"

@implementation UINavigationBar (GKUtils)

+ (void)load
{
    Method method1 = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method method2 = class_getInstanceMethod(self, @selector(gkLayoutSubviews));
    method_exchangeImplementations(method1, method2);
}

- (void)gkLayoutSubviews
{
    [self gkLayoutSubviews];
    
    CGFloat margin = UIApplication.gkNavigationBarMargin;
    [self gkSetNavigationItemMargin:UIEdgeInsetsMake(0, margin, 0, margin)];
}

- (void)gkSetNavigationItemMargin:(UIEdgeInsets)margins
{
    //ios 11适配间距
    if(@available(iOS 11, *)){
        for(UIView *view in self.subviews){
            //_UINavigationBarContentView
            if([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarContentView"]){
                //系统默认为20
                margins.left = 0;
                margins.right = 0;
                view.layoutMargins = margins;
                view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, margins.left, 0, margins.right);
                break;
            }
        }
    }
}


@end
