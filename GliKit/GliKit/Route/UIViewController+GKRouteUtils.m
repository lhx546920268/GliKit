//
//  UIViewController+GKRouteUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2022/6/24.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import "UIViewController+GKRouteUtils.h"
#import <objc/runtime.h>
#import "GKRouteConfig.h"

static char CARouteConfigKey;

@implementation UIViewController (GKRouteUtils)

- (GKRouteConfig *)routeConfig
{
    return objc_getAssociatedObject(self, &CARouteConfigKey);
}

- (void)setRouteConfig:(GKRouteConfig*) config
{
    objc_setAssociatedObject(self, &CARouteConfigKey, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)routePath
{
    return self.routeConfig.path;
}

- (void)configRoute:(GKRouteConfig *)config
{
    //子类重写
}

- (BOOL)isRouteEqual:(GKRouteConfig *)config
{
    return [self.routeConfig isEqual:config];
}

@end
