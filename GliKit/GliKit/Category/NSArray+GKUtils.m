//
//  NSArray+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "NSArray+GKUtils.h"

@implementation NSArray (GKUtils)

- (instancetype)gkObjectAtIndex:(NSUInteger) index
{
    if(index < self.count){
        return [self objectAtIndex:index];
    }
    return nil;
}

- (instancetype)gkObjectAtIndex:(NSUInteger) index clazz:(Class) clazz
{
    id obj = [self gkObjectAtIndex:index];
    if([obj isKindOfClass:clazz]){
        return obj;
    }
    return nil;
}

- (BOOL)gkContainString:(NSString *)string
{
    BOOL isEqual = NO;
    
    if(string){
        for (NSString *str in self) {
            
            if ([str isEqualToString:string]) {
                isEqual = YES;
                break;
            }
        }
    }
    
    return isEqual;
}

@end

@implementation NSMutableArray (Utils)

- (BOOL)gkAddNotExistObject:(id)obj
{
    if(![self containsObject:obj]){
        [self addObject:obj];
        return YES;
    }
    
    return NO;
}

- (BOOL)gkInsertNotExistObject:(id)obj atIndex:(NSInteger)index
{
    if(![self containsObject:obj]){
        [self insertObject:obj atIndex:index];
        return YES;
    }
    return NO;
}


- (void)gkAddNotNilObject:(id) obj
{
    if(obj != nil){
        [self addObject:obj];
    }
}

@end
