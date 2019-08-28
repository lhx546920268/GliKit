//
//  GKPartialPresentTransitionDelegate.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKPresentTransitionDelegate.h"

///使用方法

/*
 UIViewController *viewController = [[UIViewController alloc] init];
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
 
 viewController.view.backgroundColor = [UIColor whiteColor];
 
 nav.view.frame = CGRectMake(0, 0, GKScreenWidth, GKScreenHeight - 200.0);
 self.p_delegate = [[GKPartialPresentTransitionDelegate alloc] init]; ///delegate要保存起来
 nav.transitioningDelegate = self.p_delegate;
 
 [self.navigationController presentViewController:nav animated:YES completion:nil];
 */

/**
 可部分地显示present出来UIViewController，通过init初始化，设置UIViewController 的 gk_transitionDelegate来使用
 @warning UIViewController中的 transitioningDelegate 是 weak引用
 @warning 如果在 present出来的viewController 中再present, 必须把 present出来的viewController.modelPresentationStyle 设置为 UIModalPresentationCustom
 */
@interface GKPartialPresentTransitionDelegate : NSObject<UIViewControllerTransitioningDelegate>

///背景颜色
@property(nonatomic,strong) UIColor *backgroundColor;

///后面的viewController 动画效果
@property(nonatomic,assign) CGAffineTransform backTransform;

///点击背景是否会关闭当前显示的viewController，default is 'YES'
@property(nonatomic,assign) BOOL dismissWhenTapBackground;

///动画时间 default is '0.25'
@property(nonatomic,assign) NSTimeInterval duration;

///动画样式 default is 'GKPresentTransitionStyleCoverVerticalFromBottom'
@property(nonatomic,assign) GKPresentTransitionStyle transitionStyle;

///点击半透明背景回调 设置这个时，弹窗不会关闭
@property(nonatomic, copy) void(^tapBackgroundHandler)(void);

///消失时的回调
@property(nonatomic,copy) void(^dismissHandler)(void);

///显示一个 视图 垂直 可以设置 child.view 的大小
+ (void)presentViewController:(UIViewController*) child;

///显示一个 视图 水平 可以设置 child.view 的大小
+ (void)pushViewController:(UIViewController*) child;

///显示一个 视图  可以设置 child.view 的大小
+ (void)showViewController:(UIViewController*) child style:(GKPresentTransitionStyle) style;

@end

