//
//  UIViewController+GKTransition.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIViewController+GKTransition.h"

/**
 过渡代理
 */
static char GKTransitioningDelegateKey;

@implementation UIViewController (GKTransition)

//MARK: swwizle

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
    if([viewControllerToPresent.gk_transitioningDelegate isKindOfClass:[GKPartialPresentTransitionDelegate class]]){
        //让后面的视图不在动画完成后移除
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    //主要用于 当使用 GKPartialPresentTransitionDelegate 部分显示某个UIViewController A时，在A中 preset UIViewController B，B dismiss时，A会变成全屏，设置UIModalPresentationCustom将不影响 A的大小
    UIViewController *viewController = self;
    if(self.parentViewController){
        viewController = self.parentViewController;
    }
    if([viewController.gk_transitioningDelegate isKindOfClass:[GKPartialPresentTransitionDelegate class]]){
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationCustom;
    }
    [self gk_presentViewController:viewControllerToPresent animated:flag completion:completion];
}


- (void)setCa_transitioningDelegate:(id<UIViewControllerTransitioningDelegate>)gk_transitioningDelegate
{
#ifdef DEBUG
    NSAssert(![gk_transitioningDelegate isEqual:self], @"gk_transitioningDelegate 不能设置为self，如果要设置成self，使用 transitioningDelegate");
#endif
    objc_setAssociatedObject(self, &GKTransitioningDelegateKey, gk_transitioningDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.transitioningDelegate = gk_transitioningDelegate;
}

//MARK: present

- (CGSize)partialContentSize
{
    return UIScreen.gk_screenSize;
}

- (UIViewController*)partialViewController
{
    return self;
}

- (void)partialPresentFromBottom
{
    CGSize size = self.partialContentSize;
    size.height += self.gk_currentViewController.view.gk_safeAreaInsets.bottom;
    [self partialPresentWithStyle:GKPresentTransitionStyleCoverVerticalFromBottom contentSize:size];
}

- (void)partialPresentFromTop
{
    CGSize size = self.partialContentSize;
    size.height += self.gk_statusBarHeight;
    [self partialPresentWithStyle:GKPresentTransitionStyleCoverVerticalFromTop contentSize:size];
}

- (void)partialPresentWithStyle:(GKPresentTransitionStyle) style contentSize:(CGSize) contentSize
{
    [self partialPresentViewController:self.partialViewController style:style contentSize:contentSize];
}

- (void)partialPresentViewController:(UIViewController*) viewController style:(GKPresentTransitionStyle) style contentSize:(CGSize) contentSize
{
    viewController.view.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    [GKPartialPresentTransitionDelegate showViewController:viewController style:style];
}

//MARK: push

- (id<UIViewControllerTransitioningDelegate>)gk_transitioningDelegate
{
    return objc_getAssociatedObject(self, &GKTransitioningDelegateKey);
}

- (void)gk_pushViewController:(UIViewController*) viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)gk_pushViewControllerUseTransitionDelegate:(UIViewController *)viewController
{
    [self gk_pushViewControllerUseTransitionDelegate:viewController useNavigationBar:YES];
}

- (void)gk_pushViewControllerUseTransitionDelegate:(UIViewController *)viewController useNavigationBar:(BOOL) use
{
    [GKPresentTransitionDelegate pushViewController:viewController useNavigationBar:use parentedViewConttroller:self];
}

@end
