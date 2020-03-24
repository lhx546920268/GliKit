//
//  UIViewController+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 导航条按钮位置
 */
typedef NS_ENUM(NSInteger, GKNavigationItemPosition)
{
    GKNavigationItemPositionLeft = 0, //左边
    GKNavigationItemPositionRight = 1 //右边
};

///UIViewController 扩展
@interface UIViewController (GKUtils)

///隐藏导航栏阴影
@property(nonatomic, assign) BOOL gkHideNavigationBarShadowImage;

///是否可以滑动返回 default 'YES'
@property(nonatomic, assign) BOOL gkInteractivePopEnable;

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

///显示返回按钮
@property(nonatomic, assign) BOOL gkShowBackItem;

///返回按钮
@property(nonatomic, readonly, nullable) UIBarButtonItem *gkBackBarButtonItem;


///返回 动画
- (void)gkBack;

///返回 是否动画
- (void)gkBackAnimated:(BOOL) flag;

///返回 是否动画 返回完成回调
- (void)gkBackAnimated:(BOOL) flag completion:(void (^_Nullable)(void))completion;

///返回最前面
- (void)gkBackToRootViewControllerAnimated:(BOOL) flag completion:(void (^)(void))completion;

@end

@interface UIViewController (GKNavigationBarItemUtils)

/**
 导航栏按钮tintColor，默认是 导航栏上的tintColor
 */
@property(null_resettable, nonatomic, strong) UIColor *gkTintColor;

/**
 设置item tintColor
 */
- (void)gkSetTintColorForItem:(UIBarButtonItem*) item;

/**
 设置导航栏按钮

 @param item 按钮
 @param position 位置
 */
- (void)gkSetNavigationBarItem:(nullable UIBarButtonItem*) item posiiton:(GKNavigationItemPosition) position;

/**
 设置导航栏左边按钮
 
 @param title 按钮标题
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gkSetLeftItemWithTitle:(NSString*) title action:(nullable SEL) action;

/**
 设置导航栏左边按钮
 
 @param image 按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gkSetLeftItemWithImage:(UIImage*) image action:(nullable SEL) action;

/**
 设置导航栏左边按钮
 
 @param systemItem 系统按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gkSetLeftItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(nullable SEL) action;

/**
 设置导航栏左边按钮
 
 @param customView 自定义视图
 @return 按钮
 */
- (UIBarButtonItem*)gkSetLeftItemWithCustomView:(UIView*) customView;

/**
 设置导航栏右边按钮
 
 @param title 按钮标题
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gkSetRightItemWithTitle:(NSString*) title action:(nullable SEL) action;

/**
 设置导航栏右边按钮
 
 @param image 按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gkSetRightItemWithImage:(UIImage*) image action:(nullable SEL) action;

/**
 设置导航栏右边按钮
 
 @param systemItem 系统按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gkSetRightItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(nullable SEL) action;

/**
 设置导航栏右边按钮
 
 @param customView 自定义视图
 @return 按钮
 */
- (UIBarButtonItem*)gkSetRightItemWithCustomView:(UIView*) customView;

// MARK: - Class Method

+ (UIBarButtonItem*)gkBarItemWithImage:(UIImage*) image target:(nullable id) target action:(nullable SEL) action;
+ (UIBarButtonItem*)gkBarItemWithTitle:(NSString*) title target:(nullable id) target action:(nullable SEL) action;
+ (UIBarButtonItem*)gkBarItemWithCustomView:(UIView*) customView;
+ (UIBarButtonItem*)gkBarItemWithSystemItem:(UIBarButtonSystemItem) systemItem target:(nullable id) target action:(nullable SEL) action;

@end

NS_ASSUME_NONNULL_END

