//
//  GKCollectionViewLayoutInvalidationContext.m
//  GliKit
//
//  Created by 罗海雄 on 2019/8/23.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKCollectionViewLayoutInvalidationContext.h"

@implementation GKCollectionViewLayoutInvalidationContext

- (NSDictionary<NSString *,NSArray<NSIndexPath *> *> *)invalidatedSupplementaryIndexPaths
{
    return self.invalidSupplementaryIndexPaths;
}

@end
