//
//  GKDRowModel.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRowModel.h"

@implementation GKDRowModel

+ (instancetype)modelWithTitle:(NSString *)title clazz:(NSString*)clazz
{
    GKDRowModel *model = GKDRowModel.new;
    model.title = title;
    model.className = clazz;
    
    return model;
}

@end
