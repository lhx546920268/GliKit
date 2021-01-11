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

///部分显示属性
@interface GKPartialPresentProps : NSObject

///部分显示大小
@property(nonatomic, assign) CGSize contentSize;

///部分显示区域 默认通过 `contentSize` 和动画样式计算
@property(nonatomic, assign) CGRect frame;

///是否需要自动加上安全区域 default `YES`
@property(nonatomic, assign) BOOL frameUseSafeArea;

///圆角
@property(nonatomic, assign) CGFloat cornerRadius;

///圆角位置 默认是左上角和右上角
@property(nonatomic, assign) UIRectCorner corners;

///样式
@property(nonatomic, assign) GKPresentTransitionStyle transitionStyle;

///背景颜色 黑色 0.5透明度
@property(nonatomic, strong, null_resettable) UIColor *backgroundColor;

///点击背景是否会关闭当前显示的viewController，default `YES`
@property(nonatomic, assign) BOOL cancelable;

///是否可以滑动关闭 default `YES`
@property(nonatomic, assign) BOOL interactiveDismissible;

///动画时间 default `0.5`
@property(nonatomic, assign) NSTimeInterval transitionDuration;

///点击半透明背景回调 设置这个时，弹窗不会关闭
@property(nonatomic, copy, nullable) void(^cancelCallback)(void);

///消失时的回调
@property(nonatomic, copy, nullable) void(^dismissCallback)(void);

@end

///使用方法

/*
 UIViewController *vc = [UIViewController new];
 vc.navigationItem.title = sender.currentTitle;
 vc.view.backgroundColor = UIColor.whiteColor;
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
 nav.partialPresentProps.contentSize = CGSizeMake(UIScreen.gkScreenWidth, 400);
 nav.partialPresentProps.cornerRadius = 10;
 [nav partialPresentFromBottom];
 */

/**
 可部分地显示present出来UIViewController，通过init初始化，设置UIViewController 的 gk_transitionDelegate来使用
 @warning UIViewController中的 transitioningDelegate 是 weak引用
 @warning 如果在 present出来的viewController 中再present, 必须把 present出来的viewController.modelPresentationStyle 设置为 UIModalPresentationCustom
 */
@interface GKPartialPresentTransitionDelegate : NSObject<UIViewControllerTransitioningDelegate>

///部分显示属性
@property(nonatomic, strong) GKPartialPresentProps *props;

///关联的scrollView GKPresentTransitionStyleFromBottom 有效，可以让滑动列表到顶部时触发手势交互的dismiss
@property(nonatomic, weak) UIScrollView *scrollView;

///显示一个 视图
- (void)showViewController:(UIViewController*) viewController completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END

