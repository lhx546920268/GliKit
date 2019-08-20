//
//  UINavigationBar+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UINavigationBar+GKUtils.h"
#import <objc/runtime.h>

@implementation UINavigationBar (GKUtils)

+ (void)load
{
    Method method1 = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method method2 = class_getInstanceMethod(self, @selector(gk_layoutSubviews));
    method_exchangeImplementations(method1, method2);
}

- (void)gk_layoutSubviews
{
    [self gk_layoutSubviews];
    
    CGFloat margin = GKNavigationBarMargin;
    [self gk_setNavigationItemMargin:UIEdgeInsetsMake(0, margin, 0, margin)];
}

- (void)gk_setNavigationItemMargin:(UIEdgeInsets)margins
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
