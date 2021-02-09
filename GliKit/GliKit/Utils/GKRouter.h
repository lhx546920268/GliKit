//
//  GKRouter.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (GKRouterUtils)

///设置路由参数，如果参数名和属性名一致，则不需要处理这个
- (void)setRouterParams:(nullable NSDictionary*) params;

@end

///路由方式
typedef NS_ENUM(NSInteger, GKRouteStyle){
    
    ///直接用系统的push
    GKRouteStylePush,
    
    ///用push替换当前的页面
    GKRouteStyleReplace,
    
    ///present 有导航栏
    GKRouteStylePresent,
    
    ///没导航栏
    GKRouteStylePresentWithoutNavigationBar,
    
    ///这个页面只打开一个，用push
    GKRouteStyleOnlyOne,
};

///路由属性
@interface GKRouteProps : NSObject

///页面原始链接
@property(nonatomic, readonly) NSURLComponents *URLComponents;

///路由参数
@property(nonatomic, readonly, nullable) NSDictionary *routeParams;

///打开方式
@property(nonatomic, assign) GKRouteStyle style;

///app的路由路径 如 goods/detail
@property(nonatomic, copy, nullable) NSString *path;

///一个完整的URL 和 path二选一 优先使用这个
@property(nonatomic, copy, nullable) NSString *URLString;

///额外参数，可传递对象，在拦截器会加入到 routeParams
@property(nonatomic, copy, nullable) NSDictionary *extras;

@end

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
- (void)processRoute:(GKRouteProps*) props interceptHandler:(void(^)(GKRouteInterceptPolicy)) policy;

@end

///路由结果
typedef NS_ENUM(NSInteger, GKRouteResult){
    
    ///打开了
    GKRouteResultSuccess,
    
    ///取消了
    GKRouteResultCancelled,
    
    ///失败
    GKRouteResultFailed,
};

///路由回调
typedef void(^GKRouteCompletion)(GKRouteResult result);

///页面初始化处理 自己处理则返回nil
typedef UIViewController* _Nullable (^GKRouteHandler)(NSDictionary * _Nullable routeParams);

///路由 在URLString中的特殊字符和参数值必须编码
@interface GKRouter : NSObject

///单例
@property(class, nonatomic, readonly) GKRouter *sharedRouter;

///app default @"app://"
@property(nonatomic, copy, null_resettable) NSString *appScheme;

///当scheme不支持时，是否用 UIApplication 打开 default YES
@property(nonatomic, assign) BOOL openURLWhileSchemeNotSupport;

///失败回调
@property(nonatomic, copy, nullable) void(^failureHandler)(NSString *URLString, NSDictionary * _Nullable routeParams);

///添加拦截器
- (void)addInterceptor:(id<GKRouteInterceptor>) interceptor;

///移除拦截器
- (void)removeInterceptor:(id<GKRouteInterceptor>) interceptor;

/**
 注册一个页面
 
 @param path 页面路径
 @param cls 页面对应的类 会根据对应的cls创建一个页面，必须是UIViewController 
 */
- (void)registerPath:(NSString*) path forClass:(Class) cls;

/**
注册一个页面 与上一个方法互斥 不会调用 setRouterParams

@param path 页面路径
@param handler 页面初始化回调
*/
- (void)registerPath:(NSString*) path forHandler:(GKRouteHandler) handler;

/**
 取消注册一个页面
 
 @param path 页面路径
 */
- (void)unregisterPath:(NSString*) path;

/**
 打开一个链接
 
 @param block 用来配置的
 */
- (void)open:(void(NS_NOESCAPE ^)(GKRouteProps* props)) block;

@end

NS_ASSUME_NONNULL_END

