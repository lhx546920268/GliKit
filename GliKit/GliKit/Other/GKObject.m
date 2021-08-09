//
//  GKObject.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKObject.h"
#import "NSArray+GKUtils.h"

@implementation GKObject

+ (instancetype)modelFromDictionary:(NSDictionary*) dic
{
    id obj = [[[self class] alloc] init];
    [obj setDictionary:dic];
    
    return obj;
}

+ (NSMutableArray*)modelsFromArray:(NSArray<NSDictionary*>*) array
{
    if(array.count > 0){
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:array.count];
        for(NSDictionary *dic in array){
            [models gkAddNotNilObject:[[self class] modelFromDictionary:dic]];
        }
        return models;
    }
    
    return nil;
}

+ (NSMutableArray*)modelsFromArray:(NSArray<NSDictionary*>*) array maxCount:(int) maxCount
{
    if(array.count > 0){
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:MIN(maxCount, array.count)];
        for(NSDictionary *dic in array){
            [models gkAddNotNilObject:[[self class] modelFromDictionary:dic]];
            if(models.count >= maxCount){
                break;
            }
        }
        return models;
    }
    
    return nil;
}

- (void)setDictionary:(NSDictionary*) dic
{
    
}

@end
