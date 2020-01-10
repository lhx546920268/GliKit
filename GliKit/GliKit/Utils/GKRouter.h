//
//  GKRouter.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///页面打开回调
typedef void(^GKRounterOpenCompletion)(void);

///页面初始化处理
typedef UIViewController* (^GKRounterHandler)(NSDictionary * _Nullable rounterParams);

///路由 在URLString中的特殊字符和参数值必须编码
@interface GKRouter : NSObject

///单例
@property(class, nonatomic, readonly) GKRouter *sharedRouter;

///app default @"app://"
@property(nonatomic, copy, null_resettable) NSString *appScheme;

///当scheme不支持时，是否用 UIApplication 打开 default YES
@property(nonatomic, assign) BOOL openURLWhileSchemeNotSupport;

/**
 注册一个页面
 
 @param name 页面名称
 @param cls 页面对应的类 会根据对应的cls创建一个页面，必须是UIViewController 
 */
- (void)registerName:(NSString*) name forClass:(Class) cls;

/**
注册一个页面 与上一个方法互斥 不会调用 setRouterParams

@param name 页面名称
@param handler 页面初始化回调
*/
- (void)registerName:(NSString*) name forHandler:(GKRounterHandler) handler;

/**
 取消注册一个页面
 
 @param name 页面名称
 */
- (void)unregisterName:(NSString*) name;

/**
 打开一个页面
 
 @param URLString 页面链接 可带参数，如 app://profile?userId=1
 @param params 页面参数
 @return 是否打开成功
 */
- (BOOL)push:(NSString*) URLString params:(nullable NSDictionary*) params;
- (BOOL)push:(NSString*) URLString;
- (BOOL)pushApp:(NSString*) URLString params:(nullable NSDictionary*) params;
- (BOOL)pushApp:(NSString*) URLString;

/**
 替换一个页面，只有带导航栏的视图控制器才能替换
 
 @param URLString 页面链接 可带参数，如 app://profile?userId=1
 @param params 页面参数
 @param toReplacedViewControlelrs 要替换的视图，不带toReplacedViewControlelrs时， 默认替换当前页
 @return 是否打开成功
 */
- (BOOL)replace:(NSString*) URLString params:(nullable NSDictionary*) params toReplacedViewControlelrs:(nullable NSArray<UIViewController*> *) toReplacedViewControlelrs;
- (BOOL)replace:(NSString*) URLString params:(nullable NSDictionary*) params;
- (BOOL)replace:(NSString*) URLString;
- (BOOL)replaceApp:(NSString*) URLString params:(nullable NSDictionary*) params toReplacedViewControlelrs:(nullable NSArray<UIViewController*> *) toReplacedViewControlelrs;
- (BOOL)replaceApp:(NSString*) URLString params:(nullable NSDictionary*) params;
- (BOOL)replaceApp:(NSString*) URLString;

/**
 打开一个页面
 
 @param URLString 页面链接 可带参数，如 app://profile?userId=1
 @param params 页面参数
 @param withNavigationBar 是否创建导航栏 默认创建
 @param completion 界面打开完成回调
 @return 是否打开成功
 */
- (BOOL)present:(NSString*) URLString params:(nullable NSDictionary*) params withNavigationBar:(BOOL) withNavigationBar completion:(nullable GKRounterOpenCompletion) completion;
- (BOOL)present:(NSString*) URLString params:(nullable NSDictionary*) params completion:(nullable GKRounterOpenCompletion) completion;
- (BOOL)present:(NSString*) URLString params:(nullable NSDictionary*) params;
- (BOOL)present:(NSString*) URLString;
- (BOOL)presentApp:(NSString*) URLString params:(nullable NSDictionary*) params withNavigationBar:(BOOL) withNavigationBar completion:(nullable GKRounterOpenCompletion) completion;
- (BOOL)presentApp:(NSString*) URLString params:(nullable NSDictionary*) params completion:(nullable GKRounterOpenCompletion) completion;
- (BOOL)presentApp:(NSString*) URLString params:(nullable NSDictionary*) params;
- (BOOL)presentApp:(NSString*) URLString;

/**
 获取一个已初始化的页面

 @param URLString 页面链接 可带参数，如 app://profile?userId=1
 @param params 页面参数
 @return 找不到 则返回nil
*/
- (nullable UIViewController*)get:(NSString*) URLString params:(nullable NSDictionary*) params;

@end

NS_ASSUME_NONNULL_END

