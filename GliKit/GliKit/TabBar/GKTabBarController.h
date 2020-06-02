//
//  GKTabBarController.h
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import "GKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class GKTabBarItem;

/**
 tabBar控制器协议
 */
@protocol GKTabBarController <NSObject>

/**
 当前显示的 viewController
 */
@property(nonatomic, readonly, nullable) UIViewController *selectedViewController;

@end

@interface UITabBarController(GKTabBarControllerProtocol)<GKTabBarController>

@end

/**选项卡按钮信息
 */
@interface GKTabBarItemInfo : NSObject

/**
 按钮标题
 */
@property(nonatomic, strong, nullable) NSString *title;

/**
 按钮未选中图标 当selectedImage 为nil时，使用 UIImageRenderingModeAlwaysTemplate
 */
@property(nonatomic, strong, nullable) UIImage *normalImage;

/**
 按钮选中图标
 */
@property(nonatomic, strong, nullable) UIImage *selectedImage;

/**
 关联的控制器
 */
@property(nonatomic, strong, nullable) UIViewController *viewController;

/**
 便利构造方法
 *@return 一个实例
 */
+ (instancetype)infoWithTitle:(nullable NSString*) title
                  normalImage:(nullable UIImage*) normalImage
               viewController:(nullable UIViewController*) viewControllr;

/**
 便利构造方法
 *@return 一个实例
 */
+ (instancetype)infoWithTitle:(nullable NSString*) title
                  normalImage:(nullable UIImage*) normalImage
                selectedImage:(nullable UIImage*) selectedImage
               viewController:(nullable UIViewController*) viewControllr;

@end

@class GKTabBar, GKTabBarController;

///选项卡控制器代理
@protocol GKTabBarControllerDelegate <NSObject>

@optional

/**
 是否可以选择某个按钮 default is 'YES'
 */
- (BOOL)gkTabBarController:(GKTabBarController*) tabBarController shouldSelectAtIndex:(NSInteger) index;

/**
 选中某个
 */
- (void)gkTabBarController:(GKTabBarController*) tabBarController didSelectAtIndex:(NSInteger) index;

@end

/**
 选项卡控制器
 */
@interface GKTabBarController : GKBaseViewController<GKTabBarController>

/**
 正常颜色 defaut is '#95959a'
 */
@property(nonatomic, strong, null_resettable) UIColor *normalColor;

/**
 选中颜色 default is 'CAAppMainColor'
 */
@property(nonatomic, strong, null_resettable) UIColor *selectedColor;

/**
 字体 default is '12'
 */
@property(nonatomic, strong, null_resettable) UIFont *font;

/**
 选中的视图 default is '0'
 */
@property(nonatomic, assign) NSUInteger selectedIndex;

/**
 选项卡按钮
 */
@property(nonatomic, readonly, copy, nullable) NSArray<GKTabBarItem*> *tabBarItems;

/**
 选项卡按钮信息
 */
@property(nonatomic, copy, nullable) NSArray<GKTabBarItemInfo*> *itemInfos;

/**
 选项卡
 */
@property(nonatomic, readonly) GKTabBar *tabBar;

/**
 代理
 */
@property(nonatomic, weak, nullable) id<GKTabBarControllerDelegate> delegate;

/**
 设置选项卡边缘值
 *@param badgeValue 边缘值 @"" 为红点，要隐藏使用 nil
 *@param index 下标
 */
- (void)setBadgeValue:(nullable NSString*) badgeValue forIndex:(NSInteger) index;

/**
 获取指定的viewController
 *@param index 下标
 */
- (nullable UIViewController*)viewControllerForIndex:(NSUInteger) index;

/**
 获取指定的item
 */
- (nullable GKTabBarItem*)itemForIndex:(NSUInteger) index;

/**
 设置tabBar 隐藏状态
 */
- (void)setTabBarHidden:(BOOL) hidden animated:(BOOL) animated;

@end

NS_ASSUME_NONNULL_END
