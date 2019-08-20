//
//  UIViewController+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

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
@property(nonatomic, assign) BOOL gk_hideNavigationBarShadowImage;

///显示返回按钮
@property(nonatomic, assign) BOOL gk_showBackItem;

///返回按钮
@property(nonatomic, readonly) UIView *gk_backItem;

///是否可以滑动返回 default 'YES'
@property(nonatomic, assign) BOOL gk_interactivePopEnable;

///状态栏高度
@property(nonatomic,readonly) CGFloat gk_statusBarHeight;

///导航栏高度
@property(nonatomic,readonly) CGFloat gk_navigationBarHeight;

///选项卡高度
@property(nonatomic,readonly) CGFloat gk_tabBarHeight;

///工具条高度
@property(nonatomic,readonly) CGFloat gk_toolBarHeight;

///返回 动画
- (void)gk_back;

///返回 是否动画
- (void)gk_backAnimated:(BOOL) flag;

///返回 是否动画 返回完成回调
- (void)gk_backAnimated:(BOOL) flag completion: (void (^)(void))completion;

/**
 获取最上层的 presentedViewController
 */
- (UIViewController*)gk_topestPresentedViewController;

/**
 获取最底层的 presentingViewController
 */
- (UIViewController*)gk_rootPresentingViewController;

/**
 创建导航栏并返回
 */
- (__kindof UINavigationController*)gk_createWithNavigationController;

/**
 设置导航栏按钮

 @param item 按钮
 @param position 位置
 */
- (void)gk_setNavigationBarItem:(UIBarButtonItem*) item posiiton:(GKNavigationItemPosition) position;

/**
 设置导航栏左边按钮
 
 @param title 按钮标题
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gk_setLeftItemWithTitle:(NSString*) title action:(SEL) action;

/**
 设置导航栏左边按钮
 
 @param image 按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gk_setLeftItemWithImage:(UIImage*) image action:(SEL) action;

/**
 设置导航栏左边按钮
 
 @param systemItem 系统按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gk_setLeftItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(SEL) action;

/**
 设置导航栏左边按钮
 
 @param customView 自定义视图
 @return 按钮
 */
- (UIBarButtonItem*)gk_setLeftItemWithCustomView:(UIView*) customView;

/**
 设置导航栏右边按钮
 
 @param title 按钮标题
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gk_setRightItemWithTitle:(NSString*) title action:(SEL) action;

/**
 设置导航栏右边按钮
 
 @param image 按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gk_setRightItemWithImage:(UIImage*) image action:(SEL) action;

/**
 设置导航栏右边按钮
 
 @param systemItem 系统按钮图标
 @param action 点击方法
 @return 按钮
 */
- (UIBarButtonItem*)gk_setRightItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(SEL) action;

/**
 设置导航栏右边按钮
 
 @param customView 自定义视图
 @return 按钮
 */
- (UIBarButtonItem*)gk_setRightItemWithCustomView:(UIView*) customView;

#pragma mark- Class Method

+ (UIBarButtonItem*)gk_barItemWithImage:(UIImage*) image target:(id) target action:(SEL) action;
+ (UIBarButtonItem*)gk_barItemWithTitle:(NSString*) title target:(id) target action:(SEL) action;
+ (UIBarButtonItem*)gk_barItemWithCustomView:(UIView*) customView;
+ (UIBarButtonItem*)gk_barItemWithSystemItem:(UIBarButtonSystemItem) systemItem target:(id) target action:(SEL) action;


@end

