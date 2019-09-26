//
//  GKPartialPresentTransitionDelegate.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKPresentTransitionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

///使用方法

/*
 UIViewController *vc = [UIViewController new];
 vc.navigationItem.title = sender.currentTitle;
 vc.view.backgroundColor = UIColor.whiteColor;
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
 nav.partialContentSize = CGSizeMake(UIScreen.gkScreenWidth, 400);
 [nav partialPresentFromBottom];
 */

/**
 可部分地显示present出来UIViewController，通过init初始化，设置UIViewController 的 gk_transitionDelegate来使用
 @warning UIViewController中的 transitioningDelegate 是 weak引用
 @warning 如果在 present出来的viewController 中再present, 必须把 present出来的viewController.modelPresentationStyle 设置为 UIModalPresentationCustom
 */
@interface GKPartialPresentTransitionDelegate : NSObject<UIViewControllerTransitioningDelegate>

///部分显示大小
@property(nonatomic, assign) CGSize partialContentSize;

///背景颜色
@property(nonatomic, strong) UIColor *backgroundColor;

///点击背景是否会关闭当前显示的viewController，default is 'YES'
@property(nonatomic, assign) BOOL dismissWhenTapBackground;

///动画时间 default is '0.25'
@property(nonatomic, assign) NSTimeInterval duration;

///动画样式 default is 'GKPresentTransitionStyleCoverVerticalFromBottom'
@property(nonatomic, assign) GKPresentTransitionStyle transitionStyle;

///点击半透明背景回调 设置这个时，弹窗不会关闭
@property(nonatomic, copy, nullable) void(^tapBackgroundHandler)(void);

///消失时的回调
@property(nonatomic, copy, nullable) void(^dismissHandler)(void);

///显示一个 视图
- (void)showViewController:(UIViewController*) viewController;

@end

NS_ASSUME_NONNULL_END

