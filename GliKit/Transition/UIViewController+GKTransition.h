//
//  UIViewController+GKTransition.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPartialPresentTransitionDelegate.h"

@interface UIViewController (GKTransition)

///过渡动画代理 设置这个可防止 transitioningDelegate 提前释放，不要设置为 self，否则会抛出异常
@property(nonatomic,strong) id<UIViewControllerTransitioningDelegate> gk_transitioningDelegate;

//MARK: present

///部分显示大小 会自己加上安全区域高度 子类重写
@property(nonatomic, readonly) CGSize partialContentSize;

///返回要显示的viewController 默认是self
@property(nonatomic, readonly) UIViewController *partialViewController;

///从底部部分显示
- (void)partialPresentFromBottom;

///从顶部部分显示
- (void)partialPresentFromTop;

///部分显示 可设置样式和大小
- (void)partialPresentWithStyle:(GKPresentTransitionStyle) style contentSize:(CGSize) contentSize;

///部分显示 可设置要显示的viewController、样式和大小
- (void)partialPresentViewController:(UIViewController*) viewController style:(GKPresentTransitionStyle) style contentSize:(CGSize) contentSize;

//MARK: push

/**
 [self.navigationController pushViewController:viewController animated:YES]
 */
- (void)gk_pushViewController:(UIViewController*) viewController;

/**
 使用自定义过渡方式
 */
- (void)gk_pushViewControllerUseTransitionDelegate:(UIViewController *)viewController;

- (void)gk_pushViewControllerUseTransitionDelegate:(UIViewController *)viewController useNavigationBar:(BOOL) use;

@end
