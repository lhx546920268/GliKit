//
//  NSObject+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSObject+GKUtils.h"
#import <objc/runtime.h>
#import "GKTabBarController.h"
#import "UIViewController+GKUtils.h"
#import "UIViewController+GKTransition.h"
#import "GKPartialPresentTransitionDelegate.h"

@implementation NSObject (GKUtils)

+ (UIViewController*)gk_currentViewController
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //刚开始启动 不一定是tabBar
    if(![delegate.window.rootViewController isKindOfClass:[GKTabBarController class]]){
        return delegate.window.rootViewController;
    }
    
    GKTabBarController *tab = (GKTabBarController*)delegate.window.rootViewController;
    UIViewController *parentViewControlelr = tab.gk_topestPresentedViewController;
    if(parentViewControlelr == tab){
        parentViewControlelr = tab.selectedViewController;
    }

    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        UINavigationController *nav = (UINavigationController*)parentViewControlelr;
        if(nav.viewControllers.count > 0){
            return [nav.viewControllers lastObject];
        }else{
            return nav;
        }
    }else{
        return parentViewControlelr;
    }
}

- (UIViewController*)gk_currentViewController
{
    return NSObject.gk_currentViewController;
}

+ (UINavigationController*)gk_currentNavigationController
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //刚开始启动 不一定是tabBar
    if(![delegate.window.rootViewController isKindOfClass:[GKTabBarController class]]){
        return delegate.window.rootViewController.navigationController;
    }
    
    GKTabBarController *tab = (GKTabBarController*)delegate.window.rootViewController;
    UIViewController *parentViewControlelr = tab.gk_topestPresentedViewController;
    
    if([parentViewControlelr.gk_transitioningDelegate isKindOfClass:[GKPartialPresentTransitionDelegate class]]){
        parentViewControlelr = parentViewControlelr.presentingViewController;
    }
    
    if(parentViewControlelr == tab){
        parentViewControlelr = tab.selectedViewController;
    }

    
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        return (UINavigationController*)parentViewControlelr;
    }else{
        return parentViewControlelr.navigationController;
    }
}

- (UINavigationController*)gk_currentNavigationController
{
    return NSObject.gk_currentNavigationController;
}

- (NSArray<NSString*>*)gk_propertyNames
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:count];
    
    for(int i = 0;i < count;i ++){
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [propertyNames addObject:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
    }
    
    return propertyNames;
}

- (NSString*)gk_nameOfClass
{
    return NSStringFromClass(self.class);
}

+ (NSString*)gk_nameOfClass
{
    return NSStringFromClass(self.class);
}


+ (void)gk_exchangeImplementations:(SEL)selector1 prefix:(NSString *)prefix
{
    Method method1 = class_getInstanceMethod(self.class, selector1);
    Method method2 = class_getInstanceMethod(self.class, NSSelectorFromString([NSString stringWithFormat:@"%@%@", prefix, NSStringFromSelector(selector1)]));
    
    method_exchangeImplementations(method1, method2);
}

+ (void)gk_exchangeImplementations:(SEL)selector1 selector2:(SEL)selector2
{
    Method method1 = class_getInstanceMethod(self.class, selector1);
    Method method2 = class_getInstanceMethod(self.class, selector2);
    
    method_exchangeImplementations(method1, method2);
}

#pragma mark coder

- (void)gk_encodeWithCoder:(NSCoder *)coder
{
    [self gk_encodeWithCoder:coder clazz:[self class]];
}

- (void)gk_encodeWithCoder:(NSCoder*) coder clazz:(Class) clazz
{
    if(clazz == [NSObject class]){
        return;
    }
    
    //获取当前类的所有属性，该方法无法获取父类或者子类的属性
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    for(int i = 0;i < count;i ++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        //类型地址 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
        NSString *attr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        NSArray *attrs = [attr componentsSeparatedByString:@","];
        
        //判断是否是只读属性
        if(attrs.count > 0 && ![attrs containsObject:@"R"]){
            
            id value = [self valueForKey:name];
            [coder encodeObject:value forKey:name];
        }
    }
    
    //递归获取父类的属性
    [self gk_encodeWithCoder:coder clazz:[clazz superclass]];
}

- (void)gk_initWithCoder:(NSCoder *)decoder
{
    [self gk_initWithCoder:decoder clazz:[self class]];
}

- (void)gk_initWithCoder:(NSCoder*) decoder clazz:(Class) clazz
{
    if(clazz == [NSObject class]){
        return;
    }
    
    //获取当前类的所有属性，该方法无法获取父类或者子类的属性
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    for(int i = 0;i < count;i ++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        //类型地址 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
        NSString *attr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        NSArray *attrs = [attr componentsSeparatedByString:@","];
        
        //判断是否是只读属性
        if(attrs.count > 0 && ![attrs containsObject:@"R"]){
            
            NSString *type = [attrs firstObject];
            id value = nil;
            //判断是否是对象属性
            if([type containsString:@"T@\""]){
                type = [type stringByReplacingOccurrencesOfString:@"T@\"" withString:@""];
                type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                Class clazz1 = NSClassFromString(type);
                value = [decoder decodeObjectOfClass:clazz1 forKey:name];
                if(!value){
                    value = [[clazz1 alloc] init];
                }
            }else{
                value = [decoder decodeObjectForKey:name];
                if(!value){
                    value = @(0);
                }
            }
            
            [self setValue:value forKey:name];
        }
    }
    
    //递归获取父类的属性
    [self gk_initWithCoder:decoder clazz:[clazz superclass]];
}

#pragma mark copy

- (void)gk_copyObject:(NSObject*) object
{
    [self gk_copyObject:object clazz:[object class]];
}

- (void)gk_copyObject:(NSObject*) object clazz:(Class) clazz
{
    if(clazz == [NSObject class]){
        return;
    }
    NSAssert([object isKindOfClass:[self class]], @"%@必须是%@或者其子类", object.gk_nameOfClass, self.gk_nameOfClass);
    
    //获取当前类的所有属性，该方法无法获取父类或者子类的属性
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    for(int i = 0;i < count;i ++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        //类型地址 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
        NSString *attr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        NSArray *attrs = [attr componentsSeparatedByString:@","];
        
        //判断是否是只读属性
        if(attrs.count > 0 && ![attrs containsObject:@"R"]){
            
            [self setValue:[object valueForKey:name] forKey:name];
        }
    }
    
    [self gk_copyObject:object clazz:[clazz superclass]];
}

#pragma mark push

+ (void)gk_pushViewController:(UIViewController*) viewController
{
    [self gk_pushViewController:viewController shouldReplaceLastSame:NO];
}

+ (void)gk_pushViewControllerReplaceLastSameIfNeeded:(UIViewController*) viewController
{
    [self gk_pushViewController:viewController shouldReplaceLastSame:YES];
}

+ (void)gk_pushViewController:(UIViewController*) viewController shouldReplaceLastSame:(BOOL) replace
{
    if(!viewController)
        return;
    viewController.hidesBottomBarWhenPushed = YES;
    UIViewController *parentViewControlelr = self.gk_currentViewController;
    
    UINavigationController *nav = parentViewControlelr.navigationController;
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController*)parentViewControlelr;
    }
    if(nav){
        if(replace && [parentViewControlelr isKindOfClass:[viewController class]]){
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
            [viewControllers removeLastObject];
            [viewControllers addObject:viewController];
            
            viewController.gk_showBackItem = YES;
            
            [nav setViewControllers:viewControllers animated:YES];
        }else{
            [nav pushViewController:viewController animated:YES];
        }
           
    }else{
        [parentViewControlelr gk_pushViewControllerUseTransitionDelegate:viewController];
    }
}

+ (void)gk_pushViewControllerRemoveSameIfNeeded:(UIViewController*) viewController;
{
    if(!viewController)
        return;
    viewController.hidesBottomBarWhenPushed = YES;
    UIViewController *parentViewControlelr = self.gk_currentViewController;
    
    UINavigationController *nav = parentViewControlelr.navigationController;
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController*)parentViewControlelr;
    }
    if(nav){
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
        NSMutableArray *removedViewControlelrs = [NSMutableArray array];
        for(UIViewController *vc in viewControllers){
            if([vc isKindOfClass:[viewController class]]){
                [removedViewControlelrs addObject:vc];
            }
        }
        [viewControllers removeObjectsInArray:removedViewControlelrs];
        viewController.gk_showBackItem = YES;
        [viewControllers addObject:viewController];
        
        [nav setViewControllers:viewControllers animated:YES];
    }else{
        [parentViewControlelr gk_pushViewControllerUseTransitionDelegate:viewController];
    }
}

@end
