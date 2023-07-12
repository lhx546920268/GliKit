//
//  UIViewController+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///UIViewController 扩展
@interface UIViewController (GKUtils)

///隐藏导航栏阴影
@property(nonatomic, assign) BOOL gkHideNavigationBarShadowImage;

///是否可以滑动返回 default `YES`
@property(nonatomic, assign) BOOL gkInteractivePopEnabled;

///状态栏高度
@property(nonatomic, readonly) CGFloat gkStatusBarHeight;

///获取兼容的状态栏高度 比如有连接个人热点的时候状态栏的高度是不一样的 viewDidLayoutSubviews 获取
@property(nonatomic, readonly) CGFloat gkCompatiableStatusHeight;

///导航栏高度
@property(nonatomic, readonly) CGFloat gkNavigationBarHeight;

///选项卡高度
@property(nonatomic, readonly) CGFloat gkTabBarHeight;

///工具条高度
@property(nonatomic, readonly) CGFloat gkToolBarHeight;

///获取最上层的 presentedViewController
@property(nonatomic, readonly) __kindof UIViewController *gkTopestPresentedViewController;

///获取最底层的 presentingViewController
@property(nonatomic, readonly) __kindof UIViewController *gkRootPresentingViewController;

///创建导航栏并返回
@property(nonatomic, readonly) __kindof UINavigationController *gkCreateWithNavigationController;

@end

@interface UIViewController (GKNavigationBarBackItem)

///返回 动画
- (void)gkBack;

///返回 是否动画
- (void)gkBackAnimated:(BOOL) flag;

///返回 是否动画 返回完成回调
- (void)gkBackAnimated:(BOOL) flag completion:(void (^_Nullable)(void))completion;

///返回最前面
- (void)gkBackToRootViewControllerAnimated:(BOOL) flag completion:(void (^_Nullable)(void))completion;

///返回某个视图 是否动画 返回完成回调
- (void)gkBackToViewController:(Class) cls;
- (void)gkBackToViewController:(Class) cls animated:(BOOL) flag;
- (void)gkBackToViewController:(Class) cls animated:(BOOL) flag completion:(void (^_Nullable)(void))completion;

///返回某个路由 是否动画 返回完成回调
- (void)gkBackToPath:(NSString*) path;
- (void)gkBackToPath:(NSString*) path animated:(BOOL) flag;
- (void)gkBackToPath:(NSString*) path animated:(BOOL) flag completion:(void (^_Nullable)(void))completion;

@end

@class GKTabBarController;

///自定义tabBar扩展
@interface UIViewController (GKTabBarExtension)

///当前tabBarController
@property(nonatomic, readonly, nullable) GKTabBarController *gkTabBarController;

///是否有tabBar
@property(nonatomic, assign) BOOL gkHasTabBar;

@end

NS_ASSUME_NONNULL_END

