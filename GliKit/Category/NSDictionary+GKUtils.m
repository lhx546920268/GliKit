//
//  NSDictionary+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
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

@end
