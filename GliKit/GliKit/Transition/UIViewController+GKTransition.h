//
//  UIViewController+GKTransition.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPartialPresentTransitionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (GKTransition)

///过渡动画代理 设置这个可防止 transitioningDelegate 提前释放，不要设置为 self，否则会抛出异常
@property(nonatomic, weak, nullable) id<UIViewControllerTransitioningDelegate> gkTransitioningDelegate;

// MARK: - present

///部分显示 属性
@property(nonatomic, readonly) GKPartialPresentProps *partialPresentProps;

///返回要显示的viewController 默认是self
@property(nonatomic, readonly) UIViewController *partialViewController;

///从底部部分显示
- (void)partialPresentFromBottom;

///从顶部部分显示
- (void)partialPresentFromTop;

///部分显示
- (void)partialPresent;

// MARK: - push

/**
 [self.navigationController pushViewController:viewController animated:YES]
 */
- (void)gkPushViewController:(UIViewController*) viewController;

/**
 使用自定义过渡方式
 */
- (void)gkPushViewControllerUseTransitionDelegate:(UIViewController *)viewController;

- (void)gkPushViewControllerUseTransitionDelegate:(UIViewController *)viewController useNavigationBar:(BOOL) use;

@end

NS_ASSUME_NONNULL_END
