//
//  NSDictionary+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "NSDictionary+GKUtils.h"

@implementation NSDictionary (GKUtils)

- (NSString*)gkStringForKey:(id<NSCopying>) key
{
    id value = [self objectForKey:key];
    
    if([value isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@", value];
    }
    
    if([value isKindOfClass:[NSString class]]){
        return value;
    }else{
        return nil;
    }
}

- (NSString *)gkNonnullStringForKey:(id<NSCopying>)key
{
    NSString *str = [self gkStringForKey:key];
    if(!str){
        str = @"";
    }
    return str;
}

- (id)gkNumberForKey:(id<NSCopying>) key
{
    id value = [self objectForKey:key];
    
    if([value isKindOfClass:[NSNumber class]]){
        return value;
    }else if([value isKindOfClass:[NSString class]]){
        return value;
    }
    return nil;
}

- (int)gkIntForKey:(id<NSCopying>) key
{
    return [[self gkNumberForKey:key] intValue];
}

- (NSInteger)gkIntegerForKey:(id<NSCopying>) key
{
    return [[self gkNumberForKey:key] integerValue];
}

- (float)gkFloatForKey:(id<NSCopying>) key
{
    return [[self gkNumberForKey:key] floatValue];
}

- (double)gkDoubleForKey:(id<NSCopying>) key
{
    return [[self gkNumberForKey:key] doubleValue];
}

- (BOOL)gkBoolForKey:(id<NSCopying>) key
{
    return [[self gkNumberForKey:key] boolValue];
}

- (NSDictionary*)gkDictionaryForKey:(id<NSCopying>) key
{
    NSDictionary *dic = [self objectForKey:key];
    if([dic isKindOfClass:[NSDictionary class]]){
        return dic;
    }
    return nil;
}

- (NSArray*)gkArrayForKey:(id<NSCopying>) key
{
    NSArray *array = [self objectForKey:key];
    if([array isKindOfClass:[NSArray class]]){
        return array;
    }
    return nil;
}

- (NSDictionary*)gkFilteredDictionaryUsingBlock:(BOOL (^)(id _Nonnull, id _Nonnull))block
{
    if(!block || self.count == 0)
        return self;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for(id key in self){
        id obj = self[key];
        if(block(key, obj)){
            dic[key] = obj;
        }
    }
    return [dic copy];
}

@end

@implementation NSMutableDictionary (GKUtils)

- (void)gkFilterUsingBlock:(BOOL (^)(id _Nonnull, id _Nonnull))block
{
    if(block && self.count > 0){
        
        NSMutableArray *removedKeys = [NSMutableArray array];
        for(id key in self){
            if(!block(key, self[key])){
                [removedKeys addObject:key];
            }
        }
        [self removeObjectsForKeys:removedKeys];
    }
}

@end
