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
#import "NSObject+GKUtils.h"

//是否已交换
static BOOL GKDidChangeMargins = NO;

@implementation UINavigationBar (GKUtils)

+ (void)load
{
    if(@available(iOS 11, *)){
        Method method1 = class_getInstanceMethod(self.class, @selector(layoutSubviews));
        Method method2 = class_getInstanceMethod(self.class, @selector(gkLayoutSubviews));
        method_exchangeImplementations(method1, method2);
    }
}

- (void)gkLayoutSubviews
{
    [self gkLayoutSubviews];
    [self gkSetNavigationItemMargin];
}

- (void)gkSetNavigationItemMargin
{
    //_UINavigationBarContentView
    if(@available(iOS 13, *)){
        if(!GKDidChangeMargins){
            //ios 13 直接设置间距会无效
            for(UIView *view in self.subviews){
                if([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarContentView"]){
                    //系统默认为20
                    GKDidChangeMargins = YES;
                    Method method1 = class_getInstanceMethod(view.class, @selector(layoutMargins));
                    Method method2 = class_getInstanceMethod(self.class, NSSelectorFromString(@"gkLayoutMargins"));
                    
                    method_exchangeImplementations(method1, method2);
                    
                    method1 = class_getInstanceMethod(view.class, @selector(directionalLayoutMargins));
                    method2 = class_getInstanceMethod(self.class, NSSelectorFromString(@"gkDirectionalLayoutMargins"));
                                               
                    method_exchangeImplementations(method1, method2);

                    break;
                }
            }
        }
    }else if(@available(iOS 11, *)){
        for(UIView *view in self.subviews){
            //ios 13 以下按照上面那样设置 presentViewController 会报约束警告
            if([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarContentView"]){
                //系统默认为20
                view.layoutMargins = UIEdgeInsetsZero;
                view.directionalLayoutMargins = NSDirectionalEdgeInsetsZero;
                break;
            }
        }
    }
}

- (UIEdgeInsets)gkLayoutMargins
{
    return UIEdgeInsetsZero;
}

- (NSDirectionalEdgeInsets)gkDirectionalLayoutMargins NS_AVAILABLE_IOS(11.0)
{
    return NSDirectionalEdgeInsetsZero;
}

@end
