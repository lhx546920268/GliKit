//
//  GKWeakObjectContainer.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKWeakObjectContainer.h"

@implementation GKWeakObjectContainer

+ (instancetype)containerWithObject:(id) object
{
    GKWeakObjectContainer *container = [[GKWeakObjectContainer alloc] init];
    container.weakObject = object;
    
    return container;
}

@end
