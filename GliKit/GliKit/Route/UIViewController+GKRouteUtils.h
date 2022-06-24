//
//  UIViewController+GKRouteUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2022/6/24.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKRouteConfig;

@interface UIViewController (GKRouteUtils)

///当前路由配置，只有通过路由的方式打开的才有
@property(nonatomic, readonly, nullable) GKRouteConfig *routeConfig;

///路由路径 可子类重写配置 默认返回 routeConfig.path
@property(nonatomic, readonly, nullable) NSString *routePath;

///配置路由
- (void)configRoute:(GKRouteConfig*) config;

///路由是否一致
- (BOOL)isRouteEqual:(nullable GKRouteConfig*) config;

@end

NS_ASSUME_NONNULL_END
