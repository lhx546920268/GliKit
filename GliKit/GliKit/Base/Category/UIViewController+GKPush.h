//
//  UIViewController+GKPush.h
//  GliKit
//
//  Created by 罗海雄 on 2020/3/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///UIViewController扩展
@interface NSObject (GKUIViewControllerUtils)

/**
 获取当前显示的UIViewController
 */
@property(class, nonatomic, readonly) UIViewController *gkCurrentViewController;
@property(nonatomic, readonly) UIViewController *gkCurrentViewController;

/**
 获取当前显示的 UINavigationController 如果是部分present出来的，则忽略
 */
@property(class, nonatomic, readonly, nullable) UINavigationController *gkCurrentNavigationController;
@property(nonatomic, readonly, nullable) UINavigationController *gkCurrentNavigationController;

// MARK: - push

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push

 @param viewController 要push 的视图控制器
 */
+ (void)gkPushViewController:(UIViewController*) viewController;
- (void)gkPushViewController:(UIViewController*) viewController;

/**
 替换当前 页面，如果有存在navigationController, 则替换成功
 
 @param viewController 要push 的视图控制器
 */
+ (void)gkReplaceCurrentWithViewController:(UIViewController*) viewController;
- (void)gkReplaceCurrentWithViewController:(UIViewController*) viewController;

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push
 如果最后一个和要打开的viewController 相同，则替换
 
 @param viewController 要push 的视图控制器
 */
+ (void)gkPushViewControllerReplaceLastSameIfNeeded:(UIViewController*) viewController;
- (void)gkPushViewControllerReplaceLastSameIfNeeded:(UIViewController*) viewController;

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push
 移除相同的viewController
 
 @param viewController 要push 的视图控制器
 */
+ (void)gkPushViewControllerRemoveSameIfNeeded:(UIViewController*) viewController;
- (void)gkPushViewControllerRemoveSameIfNeeded:(UIViewController*) viewController;

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push

 @param viewController 要push 的视图控制器
 @param toReplacedViewControlelrs 要替换的
 */
+ (void)gkPushViewController:(UIViewController*) viewController toReplacedViewControlelrs:(nullable NSArray<UIViewController*> *) toReplacedViewControlelrs;
- (void)gkPushViewController:(UIViewController*) viewController toReplacedViewControlelrs:(nullable NSArray<UIViewController*> *) toReplacedViewControlelrs;

@end

NS_ASSUME_NONNULL_END
