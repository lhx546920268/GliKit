//
//  UIViewController+GKTransition.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKTransition.h"
#import "UIViewController+GKUtils.h"
#import <objc/runtime.h>
#import "UIScreen+GKUtils.h"
#import "UIView+GKUtils.h"
#import "NSObject+GKUtils.h"
#import "UIViewController+GKPush.h"

/**
 过渡代理
 */
static char GKTransitioningDelegateKey;

/**
 部分显示 属性
 */
static char GKPartialPresentPropsKey;

@implementation UIViewController (GKTransition)

- (void)setGkTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)gkTransitioningDelegate
{
    NSAssert(![gkTransitioningDelegate isEqual:self], @"gkTransitioningDelegate 不能设置为self，如果要设置成self，使用 transitioningDelegate");
    objc_setAssociatedObject(self, &GKTransitioningDelegateKey, gkTransitioningDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.transitioningDelegate = gkTransitioningDelegate;
}

- (id<UIViewControllerTransitioningDelegate>)gkTransitioningDelegate
{
    return objc_getAssociatedObject(self, &GKTransitioningDelegateKey);
}

// MARK: - present

- (GKPartialPresentProps *)partialPresentProps
{
    GKPartialPresentProps *props = objc_getAssociatedObject(self, &GKPartialPresentPropsKey);
    if(!props){
        props = GKPartialPresentProps.new;
        objc_setAssociatedObject(self, &GKPartialPresentPropsKey, props, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return props;
}

- (UIViewController*)partialViewController
{
    return self;
}

- (void)partialPresentFromBottom
{
    self.partialPresentProps.transitionStyle = GKPresentTransitionStyleFromBottom;
    [self partialPresentWithCompletion:nil];
}

- (void)partialPresentFromTop
{
    self.partialPresentProps.transitionStyle = GKPresentTransitionStyleFromTop;
    [self partialPresentWithCompletion:nil];
}

- (void)partialPresentWithCompletion:(void (^)(void))completion
{
    UIViewController *viewController = self.partialViewController;
    GKPartialPresentProps *props = self.partialPresentProps;

    if(props.cornerRadius > 0){
        CGRect frame = props.frame;
        [viewController.view gkSetCornerRadius:props.cornerRadius corners:props.corners rect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
    
    GKPartialPresentTransitionDelegate *delegate = [GKPartialPresentTransitionDelegate new];
    delegate.props = props;
    [delegate showViewController:viewController completion:completion];
}

// MARK: - push

- (void)gkPushViewController:(UIViewController*) viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)gkPushViewControllerUseTransitionDelegate:(UIViewController *)viewController
{
    [self gkPushViewControllerUseTransitionDelegate:viewController useNavigationBar:YES];
}

- (void)gkPushViewControllerUseTransitionDelegate:(UIViewController *)viewController useNavigationBar:(BOOL) use
{
    [GKPresentTransitionDelegate pushViewController:viewController useNavigationBar:use parentedViewConttroller:self];
}

@end
