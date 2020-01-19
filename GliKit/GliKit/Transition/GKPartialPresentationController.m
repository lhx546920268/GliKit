//
//  GKPartialPresentationController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/5.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKPartialPresentationController.h"
#import "GKBaseDefines.h"
#import "GKPartialPresentTransitionDelegate.h"

@interface GKPartialPresentationController ()<UIGestureRecognizerDelegate>

///背景视图
@property(nonatomic, strong) UIView *backgroundView;

@end

@implementation GKPartialPresentationController

- (void)presentationTransitionWillBegin
{
    //添加背景
    if(!self.backgroundView){
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = self.transitionDelegate.backgroundColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        tap.delegate = self;
        [self.backgroundView addGestureRecognizer:tap];
        [self.containerView addSubview:self.backgroundView];
        
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(0);
        }];
    }
    
    //背景渐变动画
    self.backgroundView.alpha = 0;
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.backgroundView.alpha = 1.0;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    //如果展示过程被中断了，移除背景
    if(!completed){
        [self.backgroundView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin
{
    //背景渐变
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.backgroundView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    //界面被关闭了，移除背景
    if(completed){
        [self.backgroundView removeFromSuperview];
    }else{
        self.backgroundView.alpha = 1.0;
    }
}

- (BOOL)shouldPresentInFullscreen
{
    return NO;
}

- (void)containerViewDidLayoutSubviews
{
    //系统还会调整视图大小的，所以这里要设置成我们需要的大小
    self.presentedView.frame = self.frameOfPresentedViewInContainerView;
}

- (CGRect)frameOfPresentedViewInContainerView
{
    //弹窗大小位置
    CGSize size = self.transitionDelegate.partialContentSize;
    CGSize parentSize = self.containerView.frame.size;
    switch (self.transitionDelegate.transitionStyle) {
        case GKPresentTransitionStyleCoverVerticalFromTop : {
            return CGRectMake((parentSize.width - size.width) / 2.0, 0, size.width, size.height);
        }
            break;
        case GKPresentTransitionStyleCoverHorizontal : {
            return CGRectMake(parentSize.width - size.width, (parentSize.height - size.height) / 2.0, size.width, size.height);
        }
            break;
        case GKPresentTransitionStyleCoverVerticalFromBottom : {
            return CGRectMake((parentSize.width - size.width) / 2.0, parentSize.height - size.height, size.width, size.height);
        }
            break;
    }
}

// MARK: - Action

///点击背景
- (void)handleTap
{
    if(self.transitionDelegate.tapBackgroundHandler){
        self.transitionDelegate.tapBackgroundHandler();
    }else{
        if(self.transitionDelegate.dismissWhenTapBackground){
            [self.presentedViewController dismissViewControllerAnimated:YES completion:self.transitionDelegate.dismissHandler];
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    if(CGRectContainsPoint(self.presentedViewController.view.frame, point)){
        return NO;
    }
    
    return YES;
}

@end
