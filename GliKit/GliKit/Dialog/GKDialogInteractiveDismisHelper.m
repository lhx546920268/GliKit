//
//  GKDialogInteractiveDismisHelper.m
//  GliKit
//
//  Created by xiaozhai on 2023/8/1.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDialogInteractiveDismisHelper.h"
#import "GKScrollViewController.h"
#import "UIViewController+GKDialog.h"
#import "GKBaseDefines.h"
#import "UIView+GKUtils.h"

@interface UIViewController (GKDialogPrivate)

- (void)onDialogDismissWithCompletion:(void(^)(void)) completion;

@end

@interface GKDialogInteractiveDismisHelper ()

///
@property(nonatomic, strong) UIScrollView *scrollView;

///是否正在交互中
@property(nonatomic, assign) BOOL interacting;

///
@property(nonatomic, assign) CGFloat transitionY;

@end

@implementation GKDialogInteractiveDismisHelper

- (instancetype)initWithViewController:(UIViewController*) viewController
{
    self = [super init];
    if (self) {
        _viewController = viewController;
        [viewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
        UIViewController *vc = viewController;
        if([vc isKindOfClass:UINavigationController.class]){
            UINavigationController *nav = (UINavigationController*)vc;
            vc = nav.viewControllers.firstObject;
        }
        if([vc isKindOfClass:GKScrollViewController.class]){
            GKScrollViewController *scrollViewController = (GKScrollViewController*)vc;
            self.scrollView = scrollViewController.scrollView;
            
            WeakObj(self)
            scrollViewController.scrollViewDidChange = ^(UIScrollView *scrollView) {
                selfWeak.scrollView = scrollView;
            };
        }
    }
    return self;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    if(_scrollView != scrollView){
        [_scrollView.panGestureRecognizer removeTarget:self action:@selector(handlePan:)];
        _scrollView = scrollView;
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(handlePan:)];
    }
}

///平移手势
- (void)handlePan:(UIPanGestureRecognizer*) pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan : {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            if(pan == self.scrollView.panGestureRecognizer){
                if(self.scrollView.contentOffset.y <= 0){
                    self.scrollView.contentOffset = CGPointZero;
                    [self startInteractiveTransition:pan];
                }
            }else{
                [self startInteractiveTransition:pan];
            }
        }
            break;
        case UIGestureRecognizerStateChanged : {
            if(pan == self.scrollView.panGestureRecognizer){
                if(self.scrollView.contentOffset.y <= 0){
                    self.scrollView.contentOffset = CGPointZero;
                    [self startInteractiveTransition:pan];
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded :
        case UIGestureRecognizerStateCancelled : {
            if (self.interacting) {
                [self interactiveComplete:pan];
            }
        }
            break;
        default:
            break;
    }
}

///开始交互动画
- (void)startInteractiveTransition:(UIPanGestureRecognizer*) pan
{
    //回收键盘
    self.interacting = YES;
    
    UIView *dialog = self.viewController.dialog;
    CGPoint point = [pan translationInView:dialog];
    if (point.y < 0) {
        point.y = 0;
        [pan setTranslation:CGPointZero inView:dialog];
    }
    
    self.transitionY = point.y;
    dialog.transform = CGAffineTransformMakeTranslation(0, point.y);
    self.viewController.dialogBackgroundView.alpha = 1.0 - fabs(point.y) / dialog.gkHeight;
}

- (void)interactiveComplete:(UIPanGestureRecognizer*) pan
{
    self.interacting = NO;
    UIView *dialog = self.viewController.dialog;
    
    //快速滑动也算完成
    CGPoint velocity = [pan velocityInView:dialog];
    self.transitionY += velocity.y * 0.490750;
    if (self.transitionY < 0) {
        self.transitionY = 0;
    }
    
    BOOL complete = self.transitionY / dialog.gkHeight  >= 0.4;
    NSTimeInterval duration = 0.25;
    
    CGAffineTransform transform;
    if(complete){
        duration *= 1.0 - self.transitionY / dialog.gkHeight;
        transform = CGAffineTransformMakeTranslation(0, dialog.gkHeight);
    }else{
        transform = CGAffineTransformIdentity;
    }
    
    [UIView animateWithDuration:0.25
                          delay:0 usingSpringWithDamping:1.0
          initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        dialog.transform = transform;
        self.viewController.dialogBackgroundView.alpha = complete ? 0 : 1.0;
    }
                     completion:^(BOOL finished) {
        self.transitionY = 0;
        if (complete) {
            [self.viewController onDialogDismissWithCompletion:nil];
        }
    }];
}

@end
