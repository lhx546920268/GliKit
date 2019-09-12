//
//  GKRefreshStyle.m
//  GliKit
//
//  Created by luohaixiong on 2018/7/20.
//  Copyright © 2018年 罗海雄. All rights reserved.
//

#import "GKRefreshStyle.h"
#import "GKDefaultRefreshControl.h"
#import "GKDefaultLoadMoreControl.h"

@implementation GKRefreshStyle

- (instancetype)init
{
    self = [super init];
    if(self){
        self.refreshClass = [GKDefaultRefreshControl class];
        self.loadMoreClass = [GKDefaultLoadMoreControl class];
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static GKRefreshStyle *style = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        style = [GKRefreshStyle new];
    });
    
    return style;
}

@end
