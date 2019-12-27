//
//  UIView+GKNavigationBarUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKNavigationBarUtils.h"
#import <objc/runtime.h>
#import "UIApplication+GKTheme.h"
#import "NSObject+GKUtils.h"
#import "GKSystemNavigationBar.h"

static NSString *const GKNavigationBarContentViewName = @"_UINavigationBarContentView";

@implementation UIView (GKNavigationBarUtils)

+ (void)load
{
    if(@available(iOS 11, *)){

        SEL selector = NSSelectorFromString(@"gkLayoutMargins");
        Method method1 = class_getInstanceMethod(self, @selector(layoutMargins));
        Method method2 = class_getInstanceMethod(self, selector);
        
        class_addMethod(self, selector, method_getImplementation(method2), method_getTypeEncoding(method2));
        
        method2 = class_getInstanceMethod(self, selector);
        method_exchangeImplementations(method1, method2);
        
        selector = NSSelectorFromString(@"gkDirectionalLayoutMargins");
        method1 = class_getInstanceMethod(self, @selector(directionalLayoutMargins));
        method2 = class_getInstanceMethod(self, selector);
        
        class_addMethod(self, selector, method_getImplementation(method2), method_getTypeEncoding(method2));
        
        method2 = class_getInstanceMethod(self, selector);
        
        method_exchangeImplementations(method1, method2);
    }
}

- (UIEdgeInsets)gkLayoutMargins
{
    if(self.gkIsAppNavigationBar){
        return UIEdgeInsetsZero;
    }
    return self.gkLayoutMargins;
}

- (NSDirectionalEdgeInsets)gkDirectionalLayoutMargins NS_AVAILABLE_IOS(11.0)
{
    if(self.gkIsAppNavigationBar){
        return NSDirectionalEdgeInsetsZero;
    }
    return self.gkDirectionalLayoutMargins;
}

///是否自己的导航栏
- (BOOL)gkIsAppNavigationBar
{
    return [NSStringFromClass(self.class) isEqualToString:GKNavigationBarContentViewName] && [self.superview isKindOfClass:GKSystemNavigationBar.class];
}

@end
