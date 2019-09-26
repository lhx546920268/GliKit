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

@interface GKPartialPresentTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

///关联的 GKPartialPresentTransitionAnimator
@property(nonatomic,weak) GKPartialPresentTransitionDelegate *delegate;

@end

@interface GKPartialPresentTransitionDelegate()

///动画
@property(nonatomic,strong) GKPartialPresentTransitionAnimator *animator;

@end

@implementation GKPartialPresentTransitionDelegate

- (instancetype)init
{
    self = [super init];
    if(self){
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.duration = 0.25;
        self.dismissWhenTapBackground = YES;
        self.transitionStyle = GKPresentTransitionStyleCoverVerticalFromBottom;
    }
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.animator = [[GKPartialPresentTransitionAnimator alloc] init];
    self.animator.delegate = self;
    
    return self.animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if(!self.animator){
        self.animator = [[GKPartialPresentTransitionAnimator alloc] init];
        self.animator.delegate = self;
    }
    return self.animator;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    GKPartialPresentationController *controller = [[GKPartialPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    controller.transitionDelegate = self;
    return controller;
}

- (void)showViewController:(UIViewController *)viewController
{
    viewController.gkTransitioningDelegate = self;
    [UIApplication.sharedApplication.delegate.window.rootViewController.gkTopestPresentedViewController presentViewController:viewController animated:YES completion:nil];
}

@end

@interface GKPartialPresentTransitionAnimator ()

@end

@implementation GKPartialPresentTransitionAnimator


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.delegate.duration;
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
    
    CGRect fromFrame = fromView.frame;
    CGRect toFrame = toView.frame;
    
    CGSize size = self.delegate.partialContentSize;
    
    if(isPresenting){
        fromView.frame = fromFrame;
        
        switch (self.delegate.transitionStyle){
                
            case GKPresentTransitionStyleCoverVerticalFromTop : {
                toFrame.origin.y = 0;
                toFrame.origin.x = (containerView.gkWidth - size.width) / 2.0;
                toView.frame = CGRectOffset(toFrame, 0, -size.height);
            }
                break;
            case GKPresentTransitionStyleCoverVerticalFromBottom : {
                toFrame.origin.y = containerView.gkHeight - size.height;
                toFrame.origin.x = (containerView.gkWidth - size.width) / 2.0;
                toView.frame = CGRectOffset(toFrame, 0, size.height);
            }
                break;
            case GKPresentTransitionStyleCoverHorizontal : {
                toFrame.origin.y = (containerView.gkHeight - size.height) / 2.0;
                toFrame.origin.x = containerView.gkWidth - size.width;
                toView.frame = CGRectOffset(toFrame, size.width, 0);
            }
                break;
        }
        
        [containerView addSubview:toView];
    }else{
        
        fromView.frame = fromFrame;
        //当 fromViewController.modalPresentationStyle = UIModalPresentationCustom, UIModalPresentationOverCurrentContext 时， toView 为nil
        if(toView){
            toView.frame = toFrame;
            [containerView insertSubview:toView belowSubview:fromView];
        }else{
            CGSize size = [UIScreen mainScreen].bounds.size;
            toFrame = CGRectMake(0, 0, size.width, size.height);
        }
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^(void){
        
        if(isPresenting){
            toView.frame = toFrame;
        }else{
            switch (self.delegate.transitionStyle){
                case GKPresentTransitionStyleCoverHorizontal : {
                    fromView.frame = CGRectOffset(fromFrame, size.width, 0);
                }
                    break;
                case GKPresentTransitionStyleCoverVerticalFromBottom : {
                    fromView.frame = CGRectOffset(fromFrame, 0, size.height);
                }
                    break;
                case GKPresentTransitionStyleCoverVerticalFromTop : {
                    fromView.frame = CGRectOffset(fromFrame, 0, -size.height);
                }
                    break;
                default:
                    break;
            }
        }
    }completion:^(BOOL finish){
        
        [transitionContext completeTransition:YES];
        
        ///移除背景视图
        if(!isPresenting){
            toView.hidden = NO;
        }
    }];
    
}

@end
