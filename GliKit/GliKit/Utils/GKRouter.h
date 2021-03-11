//
//  GKRouter.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKRouteConfig;

@interface UIViewController (GKRouteUtils)

///当前路由配置，只有通过路由的方式打开的才有
@property(nonatomic, readonly) GKRouteConfig *routeConfig;

///路由路径 可子类重写配置 默认返回 routeConfig.path
@property(nonatomic, readonly) NSString *routePath;

///配置路由
- (void)configRoute:(GKRouteConfig*) config;

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
    
    ///如果前一个是该页面，则返回
    GKRouteStyleBackIfEnabled,
};

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

///路由配置
@interface GKRouteConfig : NSObject

///路由参数
@property(nonatomic, readonly, nullable) NSDictionary *routeParams;

///打开方式
@property(nonatomic, assign) GKRouteStyle style;

///是否动画 default `YES`
@property(nonatomic, assign) BOOL animated;

///需要关闭的路由
@property(nonatomic, strong) NSSet<NSString*> *routesToClosed;

///以下3个属性优先级从高到低，3个值设置其中一个就行了

///页面原始链接
@property(nonatomic, copy, nullable) NSURLComponents *URLComponents;

///一个完整的URL
@property(nonatomic, copy, nullable) NSString *URLString;

///app的路由路径 如 goods/detail
@property(nonatomic, copy, nullable) NSString *path;

///额外参数，可传递对象，在拦截器会加入到 routeParams
@property(nonatomic, copy, nullable) NSDictionary *extras;

///和上面的是同一个，会自动创建，如果上面的属性赋值不是 NSMutableDictionary，访问这个属性会抛出异常
@property(nonatomic, readonly, nullable) NSMutableDictionary *mExtras;

///将要打开某个界面
@property(nonatomic, copy, nullable) void(^willRoute)(__kindof UIViewController *viewController);

///完成回调
@property(nonatomic, copy) GKRouteCompletion completion;

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
- (void)processRoute:(GKRouteConfig*) config interceptHandler:(void(^)(GKRouteInterceptPolicy)) policy;

@end

///页面初始化处理 自己处理则返回nil，在这里改变config.path 并返回nil 会重定向到另一个页面
typedef UIViewController* _Nullable (^GKRouteHandler)(GKRouteConfig *config);

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
注册一个页面 与上一个方法互斥 不会调用 setRouteParams

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
- (void)open:(void(NS_NOESCAPE ^)(GKRouteConfig* config)) block;

@end

NS_ASSUME_NONNULL_END

