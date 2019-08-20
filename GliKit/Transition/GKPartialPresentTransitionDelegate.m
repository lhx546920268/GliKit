//
//  GKPartialPresentTransitionDelegate.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKPartialPresentTransitionDelegate.h"
#import "UIViewController+GKTransition.h"
#import "UIImage+GKUtils.h"
#import "UIViewController+GKUtils.h"

///自定义Present类型的过度动画实现 通过init初始化
@interface GKPresentTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

///关联的 GKPresentTransitionDelegate
@property(nonatomic,weak) GKPresentTransitionDelegate *delegate;

@end

///自定义Present类型的过度动画，用于用户滑动屏幕触发的过度动画
@interface GKPresentInteractiveTransition : UIPercentDrivenInteractiveTransition

///关联的 GKPresentTransitionDelegate
@property(nonatomic,weak) GKPresentTransitionDelegate *delegate;

@end

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
        self.backTransform = CGAffineTransformIdentity;
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

+ (void)pushViewController:(UIViewController *)child
{
    [self showViewController:child style:GKPresentTransitionStyleCoverHorizontal];
}

+ (void)presentViewController:(UIViewController *)child
{
    [self showViewController:child style:GKPresentTransitionStyleCoverVerticalFromBottom];
}

+ (void)showViewController:(UIViewController*) child style:(GKPresentTransitionStyle) style
{
    GKPartialPresentTransitionDelegate *delegate = [[GKPartialPresentTransitionDelegate alloc] init];
    delegate.transitionStyle = style;
    child.gk_transitioningDelegate = delegate;
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController.gk_topestPresentedViewController presentViewController:child animated:YES completion:nil];
}

@end

@interface GKPartialPresentTransitionAnimator ()<UIGestureRecognizerDelegate>

///弹出来的视图
@property(nonatomic,weak) UIViewController *presentedViewController;

///背景视图
@property(nonatomic,strong) UIView *backgroundView;

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
    UIView *fromView;
    UIView *toView;
    
    ///ios 8 才有的api
    if([transitionContext respondsToSelector:@selector(viewForKey:)]){
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }else{
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    ///是否是弹出
    BOOL isPresenting = toViewController.presentingViewController == fromViewController;
    
    ///背景视图
    if(isPresenting){
        self.backgroundView = [[UIView alloc] initWithFrame:containerView.bounds];
        self.backgroundView.backgroundColor = self.delegate.backgroundColor;
        if(self.delegate.dismissWhenTapBackground){
            ///防止手势冲突
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            tap.delegate = self;
            self.presentedViewController = toViewController;
            [self.backgroundView addGestureRecognizer:tap];
            self.backgroundView.userInteractionEnabled = YES;
        }else{
            self.backgroundView.userInteractionEnabled = NO;
        }
        self.backgroundView.alpha = 0;
    }
    
    CGRect fromFrame = fromView.frame;
    CGRect toFrame = toView.frame;
    
    if(isPresenting){
        fromView.frame = fromFrame;
        fromView.hidden = YES;
        
        switch (self.delegate.transitionStyle){
                
            case GKPresentTransitionStyleCoverVerticalFromTop : {
                toFrame.origin.y = 0;
                toFrame.origin.x = (containerView.mj_w - toFrame.size.width) / 2.0;
                toView.frame = CGRectOffset(toFrame, 0, -toFrame.size.height);
            }
                break;
            case GKPresentTransitionStyleCoverVerticalFromBottom : {
                toFrame.origin.y = containerView.mj_h - toFrame.size.height;
                toFrame.origin.x = (containerView.mj_w - toFrame.size.width) / 2.0;
                toView.frame = CGRectOffset(toFrame, 0, toFrame.size.height);
            }
                break;
            case GKPresentTransitionStyleCoverHorizontal : {
                toFrame.origin.y = (containerView.mj_h - toFrame.size.height) / 2.0;
                toFrame.origin.x = containerView.mj_w - toFrame.size.width;
                toView.frame = CGRectOffset(toFrame, toFrame.size.width, 0);
            }
                break;
        }
        
        [containerView addSubview:toView];
        [containerView insertSubview:self.backgroundView belowSubview:toView];
    }else{
        
        fromView.frame = fromFrame;
        //当 fromViewController.modalPresentationStyle = UIModalPresentationCustom, UIModalPresentationOverCurrentContext 时， toView 为nil
        if(toView){
            toView.hidden = YES;
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
            self.backgroundView.alpha = 1.0;
        }else{
            switch (self.delegate.transitionStyle){
                case GKPresentTransitionStyleCoverHorizontal : {
                    fromView.frame = CGRectOffset(fromFrame, toFrame.size.width, 0);
                }
                    break;
                case GKPresentTransitionStyleCoverVerticalFromBottom : {
                    fromView.frame = CGRectOffset(fromFrame, 0, toFrame.size.height);
                }
                    break;
                case GKPresentTransitionStyleCoverVerticalFromTop : {
                    fromView.frame = CGRectOffset(fromFrame, 0, -toFrame.size.height);
                }
                    break;
                default:
                    break;
            }
            self.backgroundView.alpha = 0;
        }
    }completion:^(BOOL finish){
        
        [transitionContext completeTransition:YES];
        
        ///移除背景视图
        if(!isPresenting){
            [self.backgroundView removeFromSuperview];
            toView.hidden = NO;
        }
    }];
    
}

- (void)dealloc
{
    [self.backgroundView removeFromSuperview];
}

///点击背景视图
- (void)handleTap:(UITapGestureRecognizer*) tap
{
    if(self.delegate.dismissWhenTapBackground){
        if(self.delegate.tapBackgroundHandler){
            self.delegate.tapBackgroundHandler();
        }else{
            [self.presentedViewController dismissViewControllerAnimated:YES completion:self.delegate.dismissHandler];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    if(CGRectContainsPoint(self.presentedViewController.view.frame, point)){
        return NO;
    }
    
    return YES;
}

@end
