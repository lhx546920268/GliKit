//
//  NSObject+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSObject+GKUtils.h"
#import <objc/runtime.h>
#import "UIViewController+GKUtils.h"
#import "UIViewController+GKTransition.h"
#import "GKPartialPresentTransitionDelegate.h"

@implementation NSObject (GKUtils)

+ (UIViewController*)gkCurrentViewController
{
    //刚开始启动 不一定是tabBar
    if(![UIApplication.sharedApplication.delegate.window.rootViewController isKindOfClass:[UITabBarController class]]){
        return UIApplication.sharedApplication.delegate.window.rootViewController;
    }
    
    UITabBarController *tab = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *parentViewControlelr = tab.gkTopestPresentedViewController;
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

- (UIViewController*)gkCurrentViewController
{
    return NSObject.gkCurrentViewController;
}

+ (UINavigationController*)gkCurrentNavigationController
{
    //刚开始启动 不一定是tabBar
    if(![UIApplication.sharedApplication.delegate.window.rootViewController isKindOfClass:[UITabBarController class]]){
        return UIApplication.sharedApplication.delegate.window.rootViewController.navigationController;
    }
    
    UITabBarController *tab = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *parentViewControlelr = tab.gkTopestPresentedViewController;
    
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

- (UINavigationController*)gkCurrentNavigationController
{
    return NSObject.gkCurrentNavigationController;
}

- (NSArray<NSString*>*)gkPropertyNames
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

- (NSString*)gkNameOfClass
{
    return NSStringFromClass(self.class);
}

+ (NSString*)gkNameOfClass
{
    return NSStringFromClass(self.class);
}


+ (void)gkExchangeImplementations:(SEL)selector1 prefix:(NSString *)prefix
{
    Method method1 = class_getInstanceMethod(self.class, selector1);
    Method method2 = class_getInstanceMethod(self.class, NSSelectorFromString([NSString stringWithFormat:@"%@%@", prefix, NSStringFromSelector(selector1)]));
    
    method_exchangeImplementations(method1, method2);
}

+ (void)gkExchangeImplementations:(SEL)selector1 selector2:(SEL)selector2
{
    Method method1 = class_getInstanceMethod(self.class, selector1);
    Method method2 = class_getInstanceMethod(self.class, selector2);
    
    method_exchangeImplementations(method1, method2);
}

//MARK: coder

- (void)gkEncodeWithCoder:(NSCoder *)coder
{
    [self gkEncodeWithCoder:coder clazz:[self class]];
}

- (void)gkEncodeWithCoder:(NSCoder*) coder clazz:(Class) clazz
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
    [self gkEncodeWithCoder:coder clazz:[clazz superclass]];
}

- (void)gkInitWithCoder:(NSCoder *)decoder
{
    [self gkInitWithCoder:decoder clazz:[self class]];
}

- (void)gkInitWithCoder:(NSCoder*) decoder clazz:(Class) clazz
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
    [self gkInitWithCoder:decoder clazz:[clazz superclass]];
}

//MARK: copy

- (void)gkCopyObject:(NSObject*) object
{
    [self gk_copyObject:object clazz:[object class]];
}

- (void)gk_copyObject:(NSObject*) object clazz:(Class) clazz
{
    if(clazz == [NSObject class]){
        return;
    }
    NSAssert([object isKindOfClass:[self class]], @"%@必须是%@或者其子类", object.gkNameOfClass, self.gkNameOfClass);
    
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

//MARK: push

+ (void)gkPushViewController:(UIViewController*) viewController
{
    [self gkPushViewController:viewController shouldReplaceLastSame:NO];
}

+ (void)gkPushViewControllerReplaceLastSameIfNeeded:(UIViewController*) viewController
{
    [self gkPushViewController:viewController shouldReplaceLastSame:YES];
}

+ (void)gkPushViewController:(UIViewController*) viewController shouldReplaceLastSame:(BOOL) replace
{
    if(!viewController)
        return;
    viewController.hidesBottomBarWhenPushed = YES;
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    
    UINavigationController *nav = parentViewControlelr.navigationController;
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController*)parentViewControlelr;
    }
    if(nav){
        if(replace && [parentViewControlelr isKindOfClass:[viewController class]]){
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
            [viewControllers removeLastObject];
            [viewControllers addObject:viewController];
            
            viewController.gkShowBackItem = YES;
            
            [nav setViewControllers:viewControllers animated:YES];
        }else{
            [nav pushViewController:viewController animated:YES];
        }
           
    }else{
        [parentViewControlelr gk_pushViewControllerUseTransitionDelegate:viewController];
    }
}

+ (void)gkPushViewControllerRemoveSameIfNeeded:(UIViewController*) viewController;
{
    if(!viewController)
        return;
    viewController.hidesBottomBarWhenPushed = YES;
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    
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
        viewController.gkShowBackItem = YES;
        [viewControllers addObject:viewController];
        
        [nav setViewControllers:viewControllers animated:YES];
    }else{
        [parentViewControlelr gk_pushViewControllerUseTransitionDelegate:viewController];
    }
}

@end
