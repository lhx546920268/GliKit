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

// MARK: - Swizzle

+ (void)load
{
    SEL selectors[] = {
        
        @selector(presentViewController:animated:completion:)
    };
    
    int count = sizeof(selectors) / sizeof(SEL);
    for(int i = 0;i < count;i ++){
        SEL selector1 = selectors[i];
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gk_%@", NSStringFromSelector(selector1)]);
        Method method1 = class_getInstanceMethod(self, selector1);
        Method method2 = class_getInstanceMethod(self, selector2);
        
        method_exchangeImplementations(method1, method2);
    }
}

- (void)gk_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if([viewControllerToPresent.gkTransitioningDelegate isKindOfClass:[GKPartialPresentTransitionDelegate class]]){
        //让后面的视图不在动画完成后移除
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationCustom;
    }
    //主要用于 当使用 GKPartialPresentTransitionDelegate 部分显示某个UIViewController A时，在A中 preset UIViewController B，B dismiss时，A会变成全屏，设置UIModalPresentationCustom将不影响 A的大小
    UIViewController *viewController = self;
    if(self.parentViewController){
        viewController = self.parentViewController;
    }
    if([viewController.gkTransitioningDelegate isKindOfClass:[GKPartialPresentTransitionDelegate class]]){
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationCustom;
    }
    [self gk_presentViewController:viewControllerToPresent animated:flag completion:completion];
}


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
    [self partialPresent];
}

- (void)partialPresentFromTop
{
    self.partialPresentProps.transitionStyle = GKPresentTransitionStyleFromTop;
    [self partialPresent];
}

- (void)partialPresent
{
    UIViewController *viewController = self.partialViewController;
    GKPartialPresentProps *props = self.partialPresentProps;
    
    CGFloat cornerRadius = props.cornerRadius;
    if(cornerRadius > 0){
        CGRect frame = props.frame;
        [viewController.view gkSetCornerRadius:cornerRadius corners:props.corners rect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
    
    GKPartialPresentTransitionDelegate *delegate = [GKPartialPresentTransitionDelegate new];
    delegate.props = props;
    [delegate showViewController:viewController];
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
