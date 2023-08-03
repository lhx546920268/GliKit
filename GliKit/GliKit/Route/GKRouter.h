//
//  GKRouter.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKRouteConfig.h"
#import "UIViewController+GKRouteUtils.h"

NS_ASSUME_NONNULL_BEGIN

///页面拦截策略
typedef NS_ENUM(NSInteger, GKRouteInterceptPolicy){
    
    ///允许打开
    GKRouteInterceptPolicyAllow,
    
    ///取消
    GKRouteInterceptPolicyCancel,
};

///拦截处理结果
typedef void(^GKRouteInterceptHandler)(GKRouteInterceptPolicy policy);

///拦截器
@protocol GKRouteInterceptor <NSObject>

///处理路由
- (void)processRoute:(GKRouteConfig*) config interceptHandler:(void(^)(GKRouteInterceptPolicy)) policy;

@end

///页面初始化处理 自己处理则返回nil，在这里改变config.path 并返回nil 会重定向到另一个页面
typedef UIViewController* _Nullable (^GKRouteHandler)(GKRouteConfig *config);

///路由 在URLString中的特殊字符和参数值必须编码
@interface GKRouter : NSObject

///单例
@property(class, nonatomic, readonly) GKRouter *sharedRouter;

///失败回调
@property(nonatomic, copy, nullable) void(^failureHandler)(GKRouteConfig *config);

///添加拦截器
- (void)addInterceptor:(id<GKRouteInterceptor>) interceptor;

///移除拦截器
- (void)removeInterceptor:(id<GKRouteInterceptor>) interceptor;

/// 注册一个页面
/// @param path 页面路径
/// @param handler 页面初始化回调
- (void)registerPath:(NSString*) path forHandler:(GKRouteHandler) handler;

/// 取消注册一个页面
/// @param path 页面路径
- (void)unregisterPath:(NSString*) path;

/// 打开一个路由
/// @param block 路由配置
- (void)open:(void(NS_NOESCAPE ^)(GKRouteConfig* config)) block;

///获取某个页面
- (nullable UIViewController*)getViewController:(void(NS_NOESCAPE ^)(GKRouteConfig* config)) block;

@end

NS_ASSUME_NONNULL_END

