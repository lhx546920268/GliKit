//
//  GKRouter.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GKRounterOpenCompletion)(void);

///路由
@interface GKRouter : NSObject

///单例
@property(class, nonatomic, readonly) GKRouter *sharedRouter;

///app default @"app://"
@property(nonatomic, copy) NSString *appScheme;

/**
 注册一个页面
 
 @param name 页面名称
 @param cls 页面对应的类
 */
- (void)registerName:(NSString*) name forClass:(Class) cls;

/**
 取消注册一个页面
 
 @param name 页面名称
 */
- (void)unregisterName:(NSString*) name;

/**
 打开一个页面
 
 @param URLString 页面链接 可带参数，如 app://profile?userId=1
 @param params 页面参数
 */
- (void)push:(NSString*) URLString params:(nullable NSDictionary*) params;
- (void)push:(NSString*) URLString;
- (void)pushApp:(NSString*) URLString params:(nullable NSDictionary*) params;
- (void)pushApp:(NSString*) URLString;

/**
 打开一个页面
 
 @param URLString 页面链接 可带参数，如 app://profile?userId=1
 @param params 页面参数
 @param withNavigationBar 是否创建导航栏 默认创建
 @param completion 界面打开完成回调
 */
- (void)present:(NSString*) URLString params:(nullable NSDictionary*) params withNavigationBar:(BOOL) withNavigationBar completion:(nullable GKRounterOpenCompletion) completion;
- (void)present:(NSString*) URLString params:(nullable NSDictionary*) params completion:(nullable GKRounterOpenCompletion) completion;
- (void)present:(NSString*) URLString params:(nullable NSDictionary*) params;
- (void)present:(NSString*) URLString;
- (void)presentApp:(NSString*) URLString params:(nullable NSDictionary*) params withNavigationBar:(BOOL) withNavigationBar completion:(nullable GKRounterOpenCompletion) completion;
- (void)presentApp:(NSString*) URLString params:(nullable NSDictionary*) params completion:(nullable GKRounterOpenCompletion) completion;
- (void)presentApp:(NSString*) URLString params:(nullable NSDictionary*) params;
- (void)presentApp:(NSString*) URLString;

/**
 获取一个已初始化的页面

 @param URLString 页面链接 可带参数，如 app://profile?userId=1
 @param params 页面参数
 @return 找不到 则返回nil
*/
- (nullable UIViewController*)get:(NSString*) URLString params:(nullable NSDictionary*) params;

@end

NS_ASSUME_NONNULL_END

