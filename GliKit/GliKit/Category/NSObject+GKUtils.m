//
//  NSObject+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "NSObject+GKUtils.h"
#import <objc/runtime.h>

@implementation NSObject (GKUtils)

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
    
    if(properties != NULL){
        free(properties);
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


+ (BOOL)gkExchangeImplementations:(SEL)selector1 prefix:(NSString *)prefix
{
    Method method1 = class_getInstanceMethod(self.class, selector1);
    Method method2 = class_getInstanceMethod(self.class, NSSelectorFromString([NSString stringWithFormat:@"%@%@", prefix, NSStringFromSelector(selector1)]));
    
    if(method1 && method2){
        method_exchangeImplementations(method1, method2);
        return YES;
    }
    return NO;
}

+ (BOOL)gkExchangeImplementations:(SEL)selector1 selector2:(SEL)selector2
{
    Method method1 = class_getInstanceMethod(self.class, selector1);
    Method method2 = class_getInstanceMethod(self.class, selector2);
    
    if(method1 && method2){
        method_exchangeImplementations(method1, method2);
        return YES;
    }
    return NO;
}

// MARK: - coder

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
    
    if(properties != NULL){
        free(properties);
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
            }else{
                value = [decoder decodeObjectForKey:name];
                if(!value){
                    value = @(0);
                }
            }
            
            [self setValue:value forKey:name];
        }
    }
    
    if(properties != NULL){
        free(properties);
    }
    
    //递归获取父类的属性
    [self gkInitWithCoder:decoder clazz:[clazz superclass]];
}

// MARK: - copy

- (void)gkCopyObject:(NSObject*) object
{
    [self gkCopyObject:object clazz:[object class]];
}

- (void)gkCopyObject:(NSObject*) object clazz:(Class) clazz
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
    
    if(properties != NULL){
        free(properties);
    }
    
    [self gkCopyObject:object clazz:[clazz superclass]];
}

@end

