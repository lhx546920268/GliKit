//
//  GKPartialPresentTransitionDelegate.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPartialPresentTransitionDelegate.h"
#import "UIViewController+GKTransition.h"
#import "UIImage+GKUtils.h"
#import "UIViewController+GKUtils.h"
#import "UIView+GKUtils.h"
#import "GKPartialPresentationController.h"
#import "UIScreen+GKUtils.h"

@implementation GKPartialPresentProps

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitionDuration = 0.25;
        self.cancelable = YES;
        self.transitionStyle = GKPresentTransitionStyleFromBottom;
        self.frameUseSafeArea = YES;
        self.corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    }
    return self;
}

- (UIColor *)backgroundColor
{
    if(!_backgroundColor){
        _backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _backgroundColor;
}

- (CGRect)frame
{
    if(_frame.size.width > 0 && _frame.size.height > 0)
        return _frame;
    
    //弹窗大小位置
    CGSize size = self.contentSize;
    CGSize parentSize = UIScreen.gkScreenSize;
    switch (self.transitionStyle) {
        case GKPresentTransitionStyleFromTop : {
            if(self.frameUseSafeArea){
                size.height += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.top;
            }
            return CGRectMake((parentSize.width - size.width) / 2.0, 0, size.width, size.height);
        }
        case GKPresentTransitionStyleFromLeft : {
            if(self.frameUseSafeArea){
                size.width += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.left;
            }
            return CGRectMake(size.width, (parentSize.height - size.height) / 2.0, size.width, size.height);
        }
        case GKPresentTransitionStyleFromBottom : {
            if(self.frameUseSafeArea){
                size.height += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.bottom;
            }
            return CGRectMake((parentSize.width - size.width) / 2.0, parentSize.height - size.height, size.width, size.height);
        }
        case GKPresentTransitionStyleFromRight : {
            if(self.frameUseSafeArea){
                size.width += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.right;
            }
            return CGRectMake(parentSize.width - size.width, (parentSize.height - size.height) / 2.0, size.width, size.height);
        }
    }
}

@end

@interface GKPartialPresentTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

///
@property(nonatomic,weak) GKPartialPresentProps *props;

@end

@interface GKPartialPresentTransitionDelegate()

///动画
@property(nonatomic,strong) GKPartialPresentTransitionAnimator *animator;

@end

@implementation GKPartialPresentTransitionDelegate


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if(!self.animator){
        self.animator = [[GKPartialPresentTransitionAnimator alloc] init];
        self.animator.props = self.props;
    }
    
    return self.animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if(!self.animator){
        self.animator = [[GKPartialPresentTransitionAnimator alloc] init];
        self.animator.props = self.props;
    }
    return self.animator;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    GKPartialPresentationController *controller = [[GKPartialPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    controller.transitionDelegate = self;
    return controller;
}

- (void)showViewController:(UIViewController *)viewController completion:(void (^)(void))completion
{
    viewController.gkTransitioningDelegate = self;
    [UIApplication.sharedApplication.delegate.window.rootViewController.gkTopestPresentedViewController presentViewController:viewController animated:YES completion:completion];
}



@end

@interface GKPartialPresentTransitionAnimator ()

@end

@implementation GKPartialPresentTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.props.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    ///是否是弹出
    BOOL isPresenting = toViewController.presentingViewController == fromViewController;
    
    CGRect frame = self.props.frame;
    CGRect fromFrame = fromView.frame;
    CGRect toFrame = frame;
    
    if(isPresenting){
        
        switch (self.props.transitionStyle){
                
            case GKPresentTransitionStyleFromTop : {
                toView.frame = CGRectOffset(toFrame, 0, -CGRectGetMaxY(frame));
            }
                break;
            case GKPresentTransitionStyleFromBottom : {
                toView.frame = CGRectOffset(toFrame, 0, CGRectGetMaxY(frame));
            }
                break;
            case GKPresentTransitionStyleFromLeft : {
                toView.frame = CGRectOffset(toFrame, -CGRectGetMaxX(frame), 0);
            }
                break;
            case GKPresentTransitionStyleFromRight : {
                toView.frame = CGRectOffset(toFrame, CGRectGetMaxX(frame), 0);
            }
                break;
        }
        
        [containerView addSubview:toView];
    }else{
        
        switch (self.props.transitionStyle){
            case GKPresentTransitionStyleFromLeft : {
                fromFrame = CGRectOffset(frame, -CGRectGetMaxX(frame), 0);
            }
                break;
            case GKPresentTransitionStyleFromBottom : {
                fromFrame = CGRectOffset(frame, 0, CGRectGetMaxY(frame));
            }
                break;
            case GKPresentTransitionStyleFromTop : {
                fromFrame = CGRectOffset(frame, 0, -CGRectGetMaxY(frame));
            }
                break;
            case GKPresentTransitionStyleFromRight : {
                fromFrame = CGRectOffset(frame, CGRectGetMaxX(frame), 0);
            }
                break;
        }
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if(isPresenting){
            toView.frame = toFrame;
        }else{
            fromView.frame = fromFrame;
        }
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
        ///移除背景视图
        if(!isPresenting){
            toView.hidden = NO;
        }
    }];
}

@end
