//
//  GKNavigationTransitionAnimator.h
//  GliKit
//
//  Created by 罗海雄 on 2020/6/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKNavigationInteractiveTransition;

///导航栏转场动画
@interface GKNavigationTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

///类型
@property(nonatomic, assign) UINavigationControllerOperation operation;

///自定义转场动画时长 default 0.25
@property(nonatomic, assign) NSTimeInterval transitionDuration;

///关联的交互转场
@property(nonatomic, weak) GKNavigationInteractiveTransition *interactiveTransition;

@end

NS_ASSUME_NONNULL_END
