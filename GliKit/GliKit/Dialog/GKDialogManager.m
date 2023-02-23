//
//  GKDialogManager.m
//  GliKit
//
//  Created by 罗海雄 on 2023/2/13.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDialogManager.h"

@implementation GKDialogManager

+ (GKDialogManager *)sharedManager
{
    static GKDialogManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GKDialogManager new];
    });
    
    return manager;
}

@end
