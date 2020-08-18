//
//  GKNavigationInteractiveTransition.m
//  GliKit
//
//  Created by 罗海雄 on 2020/6/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKNavigationInteractiveTransition.h"
#import "UIView+GKUtils.h"

@interface GKNavigationInteractiveTransition ()<CAAnimationDelegate>

@property(nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation GKNavigationInteractiveTransition

- (void)setGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if(_gestureRecognizer != gestureRecognizer){
        [_gestureRecognizer removeTarget:self action:@selector(handlePan:)];
        _gestureRecognizer = gestureRecognizer;
        
        //添加手势监听
        [_gestureRecognizer addTarget:self action:@selector(handlePan:)];
    }
}

- (void)dealloc
{
    //移除手势
    [self.gestureRecognizer removeTarget:self action:@selector(handlePan:)];
}

// MARK: - super method

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    [super startInteractiveTransition:transitionContext];
    
    //触发交互了，要把视图加到容器里面
    UIView *containerView = transitionContext.containerView;
       
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    fromView.layer.shadowColor = UIColor.lightGrayColor.CGColor;
    fromView.layer.shadowOpacity = 0.1;
    fromView.layer.shadowOffset = CGSizeMake(-1, 0);
    
    [containerView insertSubview:toView belowSubview:fromView];
}

// MARK: - Action

- (CGFloat)percentForGesture:(UIScreenEdgePanGestureRecognizer *)gesture
{
    UIView *containerView = self.transitionContext.containerView;
    
    CGPoint point = [gesture locationInView:containerView];
    CGFloat width = CGRectGetWidth(containerView.bounds);
    CGFloat percent = gesture.edges == UIRectEdgeLeft ? point.x / width : (width - point.x) / width;
    
    return percent;
}

//平移手势
- (void)handlePan:(UIScreenEdgePanGestureRecognizer*) pan
{
    switch (pan.state){
        case UIGestureRecognizerStateChanged: {
            
            //更新UI位置
            CGFloat percent = [self percentForGesture:pan];
            [self updateInteractiveTransition:percent];
               
            UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
            UIView *toView = [self.transitionContext viewForKey:UITransitionContextToViewKey];
               
            CGRect fromFrame = fromView.frame;
            CGRect toFrame = toView.frame;
            
            fromView.gkCenterX = fromFrame.size.width / 2 + fromFrame.size.width * percent;
            toView.gkCenterX = toFrame.size.width / 3 + (toFrame.size.width / 2 - toFrame.size.width / 3) * percent;
        }
            break;
        case UIGestureRecognizerStateEnded :
        case UIGestureRecognizerStateCancelled : {
            
            UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
            UIView *toView = [self.transitionContext viewForKey:UITransitionContextToViewKey];
            CGRect fromFrame = fromView.frame;
            CGRect toFrame = toView.frame;
            
            CAAnimation *animation1;
            CAAnimation *animation2;
            if([self percentForGesture:pan] >= 0.5){
                [self finishInteractiveTransition];
                animation1 = [self animationWithFromValue:@(fromView.gkCenterX) toValue:@((fromFrame.size.width / 2 + fromFrame.size.width))];
                animation2 = [self animationWithFromValue:@(toView.gkCenterX) toValue:@(toFrame.size.width / 2)];
            }else{
                [self cancelInteractiveTransition];
                animation1 = [self animationWithFromValue:@(fromView.gkCenterX) toValue:@((fromFrame.size.width / 2))];
                animation2 = [self animationWithFromValue:@(toView.gkCenterX) toValue:@(toFrame.size.width / 3)];
            }
            
            animation1.delegate = self;
            [fromView.layer addAnimation:animation1 forKey:@"position"];
            [toView.layer addAnimation:animation2 forKey:@"position"];
        }
            break;
        default: {
            [self cancelInteractiveTransition];
        }
            break;
    }
}

///获取动画
- (CAAnimation*)animationWithFromValue:(id) fromValue toValue:(id) toValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = self.duration * (1 - self.percentComplete);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0 :0 :0.2 :1];
    
    return animation;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [self.transitionContext viewForKey:UITransitionContextToViewKey];
    BOOL wasCancelled = [self.transitionContext transitionWasCancelled];
    
    if(wasCancelled){
        [self.transitionContext.containerView addSubview:fromView];
        [toView removeFromSuperview];
    }else{
        fromView.layer.shadowOpacity = 0;
    }
    toView.layer.shadowOpacity = 0;
    
    [self.transitionContext completeTransition:!wasCancelled];
    
    CABasicAnimation *animation = (CABasicAnimation*)anim;
    fromView.gkCenterX = [animation.toValue floatValue];
    toView.gkCenterX =  toView.gkWidth / 2;
    
    [toView.layer removeAnimationForKey:@"position"];
    [fromView.layer removeAnimationForKey:@"position"];
}

@end
