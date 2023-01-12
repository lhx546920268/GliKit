//
//  GKRouteConfig.h
//  GliKit
//
//  Created by 罗海雄 on 2022/6/24.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///路由方式
typedef NS_ENUM(NSInteger, GKRouteStyle){
    
    ///直接用系统的push
    GKRouteStylePush,
    
    ///用push替换当前的页面，viewControllers.count必须大于1，否则直接push
    GKRouteStyleReplace,
    
    ///present 有导航栏
    GKRouteStylePresent,
    
    ///没导航栏
    GKRouteStylePresentWithoutNavigationBar,
    
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

///解析后的路由参数
@property(nonatomic, readonly, nullable) NSDictionary *routeParams;

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
@property(nonatomic, readonly) NSMutableDictionary *mExtras;

///打开方式
@property(nonatomic, assign) GKRouteStyle style;

///是否是弹出来
@property(nonatomic, readonly) BOOL isPresent;

///是否动画 default `YES`
@property(nonatomic, assign) BOOL animated;

///需要关闭的路由
@property(nonatomic, copy, nullable) NSSet<NSString*> *routesToClosed;

///是否需要关闭一样的路由，会校验 path和参数
@property(nonatomic, assign) BOOL closeRouteIfSame;

///如果不为空，需要从后面开始遍历，直到该路由名称为止，关闭中间的所有界面（包含closeUntilRoute）
@property(nonatomic, copy, nullable) NSString *closeUntilRoute;

///这个页面只打开一个，用push，校验viewController.class
@property(nonatomic, assign) BOOL onlyOne;

///将要打开某个界面
@property(nonatomic, copy, nullable) void(^willRoute)(__kindof UIViewController *viewController);

///完成回调
@property(nonatomic, copy, nullable) GKRouteCompletion completion;

@end

NS_ASSUME_NONNULL_END
