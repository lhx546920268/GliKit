//
//  GKRouter.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKRouter.h"
#import <objc/runtime.h>
#import "GKBaseViewController.h"
#import "GKOrderConfirmViewController.h"
#import "GKObject.h"
#import "GKHomePageViewController.h"
#import "GKMeViewController.h"
#import "GKCateContainerViewController.h"
#import "GKShopcartViewController.h"

@implementation GKRouter

+ (void)openWithData:(NSDictionary *) data
{
    if(![data isKindOfClass:NSDictionary.class] || data.count == 0)
        return;
    
    NSString *className = [data gk_stringForKey:@"className"];
    if([NSString isEmpty:className])
        return;
    
    Class clazz = NSClassFromString(className);

    if(!clazz)
        return;
    
    GKTabBarIndex tabBarIndex = GKTabBarIndexNotKnow;
    //如果是首页那4个标签 则直接返回
    if(clazz == GKHomePageViewController.class){
        tabBarIndex = GKTabBarIndexHome;
    }else if (clazz == GKCateContainerViewController.class){
        tabBarIndex = GKTabBarIndexCategory;
    }else if (clazz == GKShopcartViewController.class){
        tabBarIndex = GKTabBarIndexShopcart;
    }else if (clazz == GKMeViewController.class){
        tabBarIndex = GKTabBarIndexMe;
    }
    
    
    switch (tabBarIndex) {
        case GKTabBarIndexMe :
        case GKTabBarIndexCategory :
        case GKTabBarIndexHome : {
            
            UIViewController *vc = self.gk_currentViewController;
            [vc gk_backAnimated:NO completion:^{
                [GKTabBarController setSelectedIndex:tabBarIndex];
            }];
        }
            break;
        case GKTabBarIndexShopcart : {
            
            //购物车要登录
            if(GKUserModel.isLogin){
                UIViewController *vc = self.gk_currentViewController;
                [vc gk_backAnimated:NO completion:^{
                    [GKTabBarController setSelectedIndex:tabBarIndex];
                }];
            }else{
                [AppDelegate showLoginWithCompletionHandler:^(NSString *userId) {
                    UIViewController *vc = self.gk_currentViewController;
                    [vc gk_backAnimated:NO completion:^{
                        [GKTabBarController setSelectedIndex:tabBarIndex];
                    }];
                }];
            }
        }
            break;
        default: {
            GKBaseViewController *vc = [clazz new];
            if(![vc isKindOfClass:GKBaseViewController.class])
                return;
            
            NSDictionary *propertyData = [data gk_dictionaryForKey:@"data"];
            if(propertyData.count > 0){
                [self setPropertyForViewController:vc data:propertyData];
            }
            UINavigationController *nav = self.gk_currentNavigationController;
            BOOL closeCurrent = [data gk_boolForKey:@"closeCurrent"];
            if(closeCurrent && nav){
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
                [viewControllers removeLastObject];
                [viewControllers addObject:vc];
                [nav pushViewController:vc animated:YES];
            }else{
                [NSObject gk_pushViewController:vc];
            }
        }
            break;
    }
}

+ (void)setPropertyForViewController:(GKBaseViewController*) vc data:(NSDictionary*) data
{
    [self setPropertyForViewController:vc data:data clazz:vc.class];
}

+ (void)setPropertyForViewController:(GKBaseViewController*) vc data:(NSDictionary*) data clazz:(Class) clazz
{
    if(clazz == GKBaseViewController.class){
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
            
            id value = [data objectForKey:name];
            if([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class]){
                
                if([attr containsString:@"NSString"]){
                    [vc setValue:[data gk_stringForKey:name] forKey:name];
                }else{
                    [vc setValue:value forKey:name];
                }
            }else if ([value isKindOfClass:NSDictionary.class]){
                
                //把字典转换成对应模型
                NSDictionary *dic = (NSDictionary*)value;
                NSString *className = [dic gk_stringForKey:@"className"];
                Class clazz = NSClassFromString(className);
                GKObject *obj = [clazz new];
                if([obj isKindOfClass:GKObject.class]){
                    
                    id modelData = [dic objectForKey:@"data"];
                    if([modelData isKindOfClass:NSDictionary.class]){
                        [obj setDictionary:modelData];
                        [vc setValue:obj forKey:name];
                    }else if([modelData isKindOfClass:NSArray.class]){
                        
                        [vc setValue:[clazz modelsFromArray:modelData] forKey:name];
                    }
                }
            }
        }
    }
    
    //递归获取父类的属性
    [self setPropertyForViewController:vc data:data clazz:[clazz superclass]];
}

@end
