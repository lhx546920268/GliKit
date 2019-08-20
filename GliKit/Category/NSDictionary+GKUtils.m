//
//  NSDictionary+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSDictionary+GKUtils.h"

@implementation NSDictionary (GKUtils)

- (NSString*)gk_stringForKey:(id<NSCopying>) key
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

- (id)gk_numberForKey:(id<NSCopying>) key
{
    id value = [self objectForKey:key];
    
    if([value isKindOfClass:[NSNumber class]]){
        return value;
    }else if([value isKindOfClass:[NSString class]]){
        return value;
    }
    return nil;
}

- (int)gk_intForKey:(id<NSCopying>) key
{
    return [[self gk_numberForKey:key] intValue];
}

- (NSInteger)gk_integerForKey:(id<NSCopying>) key
{
    return [[self gk_numberForKey:key] integerValue];
}

- (float)gk_floatForKey:(id<NSCopying>) key
{
    return [[self gk_numberForKey:key] floatValue];
}

- (double)gk_doubleForKey:(id<NSCopying>) key
{
    return [[self gk_numberForKey:key] doubleValue];
}

- (BOOL)gk_boolForKey:(id<NSCopying>) key
{
    return [[self gk_numberForKey:key] boolValue];
}

- (NSDictionary*)gk_dictionaryForKey:(id<NSCopying>) key
{
    NSDictionary *dic = [self objectForKey:key];
    if([dic isKindOfClass:[NSDictionary class]]){
        return dic;
    }
    return nil;
}

- (NSArray*)gk_arrayForKey:(id<NSCopying>) key
{
    NSArray *array = [self objectForKey:key];
    if([array isKindOfClass:[NSArray class]]){
        return array;
    }
    return nil;
}

@end
