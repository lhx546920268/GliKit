//
//  GKRouter.m
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKRouter.h"
#import <objc/runtime.h>
#import "GKBaseViewController.h"
#import "GKObject.h"
#import "NSObject+GKUtils.h"
#import "NSDictionary+GKUtils.h"
#import "NSString+GKUtils.h"

@implementation GKRouter

+ (void)openWithData:(NSDictionary *) data
{
    if(![data isKindOfClass:NSDictionary.class] || data.count == 0)
        return;
    
    NSString *className = [data gkStringForKey:@"className"];
    if([NSString isEmpty:className])
        return;
    
    Class clazz = NSClassFromString(className);

    if(!clazz)
        return;
    
    GKBaseViewController *vc = [clazz new];
    if(![vc isKindOfClass:GKBaseViewController.class])
        return;
    
    NSDictionary *propertyData = [data gkDictionaryForKey:@"data"];
    if(propertyData.count > 0){
        [self setPropertyForViewController:vc data:propertyData];
    }
    UINavigationController *nav = self.gkCurrentNavigationController;
    BOOL closeCurrent = [data gkBoolForKey:@"closeCurrent"];
    if(closeCurrent && nav){
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
        [viewControllers removeLastObject];
        [viewControllers addObject:vc];
        [nav pushViewController:vc animated:YES];
    }else{
        [NSObject gkPushViewController:vc];
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
                    [vc setValue:[data gkStringForKey:name] forKey:name];
                }else{
                    [vc setValue:value forKey:name];
                }
            }else if ([value isKindOfClass:NSDictionary.class]){
                
                //把字典转换成对应模型
                NSDictionary *dic = (NSDictionary*)value;
                NSString *className = [dic gkStringForKey:@"className"];
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
