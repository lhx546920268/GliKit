//
//  NSArray+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/22.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSArray+GKUtils.h"

@implementation NSArray (GKUtils)

- (id)gk_objectAtIndex:(NSUInteger) index
{
    if(index < self.count){
        return [self objectAtIndex:index];
    }
    return nil;
}

- (id)gk_objectAtIndex:(NSUInteger) index class:(Class) clazz
{
    id obj = [self gk_objectAtIndex:index];
    if([obj isKindOfClass:clazz]){
        return obj;
    }
    return nil;
}

@end

@implementation NSMutableArray (Utils)

- (BOOL)gk_addNotExistObject:(id)obj
{
    if(![self containsObject:obj]){
        [self addObject:obj];
        return YES;
    }
    
    return NO;
}

- (BOOL)gk_insertNotExistObject:(id)obj atIndex:(NSInteger)index
{
    if(![self containsObject:obj]){
        [self insertObject:obj atIndex:index];
        return YES;
    }
    return NO;
}


- (void)gk_addNotNilObject:(id) obj
{
    if(obj != nil){
        [self addObject:obj];
    }
}

- (BOOL)gk_containString:(NSString *)string
{
    BOOL isEqual = NO;
    
    for (NSString *str in self) {
        
        if ([str isEqualToString:string]) {
            isEqual = YES;
            break;
        }
    }
    
    return isEqual;
}

@end
