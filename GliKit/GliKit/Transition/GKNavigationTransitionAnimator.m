//
//  GKNavigationTransitionAnimator.m
//  GliKit
//
//  Created by 罗海雄 on 2020/6/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKNavigationTransitionAnimator.h"
#import "UIView+GKUtils.h"

@interface GKNavigationTransitionAnimator()<CAAnimationDelegate>

@property(nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation GKNavigationTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if(!transitionContext.isInteractive){
        self.transitionContext = transitionContext;
        UIView *containerView = transitionContext.containerView;
           
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
           
        BOOL isPush = self.operation == UINavigationControllerOperationPush;
           
        CGRect fromFrame = fromView.frame;
        CGRect toFrame = toView.frame;
        
        CGFloat fromValue1;
        CGFloat toValue1;
        
        CGFloat fromValue2;
        CGFloat toValue2;
        
        if(isPush){
            toView.layer.shadowColor = UIColor.lightGrayColor.CGColor;
            toView.layer.shadowOpacity = 0.1;
            toView.layer.shadowOffset = CGSizeMake(-1, 0);
            
            [containerView addSubview:toView];
            fromValue1 = fromFrame.size.width / 2;
            toValue1 = fromFrame.size.width / 3;
            
            fromValue2 = toFrame.size.width + toFrame.size.width / 2;
            toValue2 = toFrame.size.width / 2;
        }else{
            fromView.layer.shadowColor = UIColor.lightGrayColor.CGColor;
            fromView.layer.shadowOpacity = 0.1;
            fromView.layer.shadowOffset = CGSizeMake(-1, 0);
            
            [containerView insertSubview:toView belowSubview:fromView];
            
            fromValue1 = fromFrame.size.width / 2;
            toValue1 = fromFrame.size.width / 2 + fromFrame.size.width;
            
            fromValue2 = toFrame.size.width / 3;
            toValue2 = toFrame.size.width / 2;
        }

        CAAnimation *animation = [self animationWithFromValue:@(fromValue1) toValue:@(toValue1)];
        animation.delegate = self;
        [fromView.layer addAnimation:animation forKey:@"position"];
        
        [toView.layer addAnimation:[self animationWithFromValue:@(fromValue2) toValue:@(toValue2)] forKey:@"position"];
    }
}

///获取动画
- (CAAnimation*)animationWithFromValue:(id) fromValue toValue:(id) toValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = [self transitionDuration:self.transitionContext];
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
