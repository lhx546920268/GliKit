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
    if(@available(iOS 13, *)){
        
        Class cls = UIView.class;
        SEL selector = NSSelectorFromString(@"gkLayoutMargins");
        Method method1 = class_getInstanceMethod(cls, @selector(layoutMargins));
        Method method2 = class_getInstanceMethod(self, selector);
        
        class_addMethod(cls, selector, method_getImplementation(method2), method_getTypeEncoding(method2));
        
        method2 = class_getInstanceMethod(cls, selector);
        method_exchangeImplementations(method1, method2);
        
        selector = NSSelectorFromString(@"gkDirectionalLayoutMargins");
        method1 = class_getInstanceMethod(cls, @selector(directionalLayoutMargins));
        method2 = class_getInstanceMethod(self, selector);
        
        class_addMethod(cls, selector, method_getImplementation(method2), method_getTypeEncoding(method2));
        
        method2 = class_getInstanceMethod(cls, selector);
        
        method_exchangeImplementations(method1, method2);
    }else if(@available(iOS 11, *)){
        
        Method method1 = class_getInstanceMethod(self, @selector(layoutSubviews));
        Method method2 = class_getInstanceMethod(self, @selector(gkLayoutSubviews));
        method_exchangeImplementations(method1, method2);
    }
}

- (void)gkLayoutSubviews NS_AVAILABLE_IOS(11.0)
{
    [self gkLayoutSubviews];
    [self gkSetNavigationItemMargin];
}

- (void)gkSetNavigationItemMargin NS_AVAILABLE_IOS(11.0)
{
    //_UINavigationBarContentView
    for(UIView *view in self.subviews){
        //ios 13 以下按照上面那样设置 presentViewController 会报约束警告
        if([NSStringFromClass(view.class) isEqualToString:@"_UINavigationBarContentView"]){
            //系统默认为20
            view.layoutMargins = UIEdgeInsetsZero;
            view.directionalLayoutMargins = NSDirectionalEdgeInsetsZero;
            break;
        }
    }
}

- (UIEdgeInsets)gkLayoutMargins
{
    if([NSStringFromClass(self.class) isEqualToString:@"_UINavigationBarContentView"]){
        return UIEdgeInsetsZero;
    }
    return self.gkLayoutMargins;
}

- (NSDirectionalEdgeInsets)gkDirectionalLayoutMargins NS_AVAILABLE_IOS(11.0)
{
    if([NSStringFromClass(self.class) isEqualToString:@"_UINavigationBarContentView"]){
        return NSDirectionalEdgeInsetsZero;
    }
    return self.gkDirectionalLayoutMargins;
}

@end
