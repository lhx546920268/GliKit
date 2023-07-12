//
//  UIViewController+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKUtils.h"
#import <objc/runtime.h>
#import "GKBaseNavigationController.h"
#import "UIView+GKUtils.h"
#import "UIApplication+GKTheme.h"
#import "NSString+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "UIFont+GKTheme.h"
#import "UIColor+GKUtils.h"
#import "UIImage+GKTheme.h"
#import "UIView+GKStateUtils.h"
#import "GKTabBarController.h"
#import "GKRouter.h"

///是否可以活动返回
static char GKInteractivePopEnabledKey;

@implementation UIViewController (Utils)

- (void)setGkHideNavigationBarShadowImage:(BOOL)gkHideNavigationBarShadowImage
{
    UIImageView *shadowImageView = [self gkFindShadowImageView:self.navigationController.navigationBar];
    shadowImageView.hidden = gkHideNavigationBarShadowImage;
}

- (BOOL)gkHideNavigationBarShadowImage
{
    UIImageView *shadowImageView = [self gkFindShadowImageView:self.navigationController.navigationBar];
    return shadowImageView.hidden;
}

- (UIImageView*)gkFindShadowImageView:(UIView*)view
{
    if([view isKindOfClass:[UIImageView class]] && view.bounds.size.height <= 1.0){
        return (UIImageView*) view;
    }
    
    for(UIView *subView in view.subviews){
        UIImageView *imageView = [self gkFindShadowImageView:subView];
        if(imageView){
            return imageView;
        }
    }
    
    return nil;
}

- (BOOL)gkInteractivePopEnabled
{
    NSNumber *number = objc_getAssociatedObject(self, &GKInteractivePopEnabledKey);
    return number != nil ? number.boolValue : YES;
}

- (void)setGkInteractivePopEnabled:(BOOL) enabled
{
    self.navigationController.interactivePopGestureRecognizer.enabled = enabled;
    objc_setAssociatedObject(self, &GKInteractivePopEnabledKey, @(enabled), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)gkStatusBarHeight
{
    CGFloat height = UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.top;
    //iOS 14 iPhone 12 mini的导航栏和状态栏有间距
    if(height == 0){
        if(@available(iOS 13.0, *)){
            height = UIApplication.sharedApplication.delegate.window.windowScene.statusBarManager.statusBarFrame.size.height;
        }
        
        if(height == 0){
            height = [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
    }
    
    if(height == 0){
        if(UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.bottom > 0){
            height = 44;
        }else{
            height = 20;
        }
    }
    
    return height;
}

- (CGFloat)gkNavigationBarHeight
{
    return UIApplication.gkNavigationBarHeight;
}


- (CGFloat)gkTabBarHeight
{
    if(self.tabBarController){
        return self.tabBarController.tabBar.bounds.size.height;
    }else{
        return 49 + UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.bottom;
    }
}

- (CGFloat)gkToolBarHeight
{
    return 44 + UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.bottom;
}

- (__kindof UIViewController *)gkTopestPresentedViewController
{
    if(self.presentedViewController){
        return [self.presentedViewController gkTopestPresentedViewController];
    }else{
        return self;
    }
}

- (__kindof UIViewController*)gkRootPresentingViewController
{
    if(self.presentingViewController){
        return [self.presentingViewController gkRootPresentingViewController];
    }else{
        return self;
    }
}

- (__kindof UINavigationController*)gkCreateWithNavigationController
{
    if(self.navigationController){
        return self.navigationController;
    }
    return [[GKBaseNavigationController alloc] initWithRootViewController:self];
}

@end

@implementation UIViewController (GKNavigationBarBackItem)

- (void)gkBack
{
    [self gkBackAnimated:YES];
}

- (void)gkBackAnimated:(BOOL) flag
{
    [self gkBackAnimated:flag completion:nil];
}

- (void)gkBackAnimated:(BOOL) flag completion: (void (^)(void))completion
{
    [self gkBeforeBack];
    
    if(self.navigationController.viewControllers.count <= 1){
        if(self.presentingViewController){
            [self dismissViewControllerAnimated:flag completion:completion];
        }else{
            !completion ?: completion();
        }
    }else{
        [self gkSetTransitionCompletion:completion];
        [self.navigationController popViewControllerAnimated:flag];
    }
}

- (void)gkBackToRootViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self gkBeforeBack];

    //是present出来的
    if(self.presentingViewController){
        UIViewController *root = self.gkRootPresentingViewController;
        if(root.navigationController.viewControllers.count > 1){
            //dismiss 之后还有 pop,所以dismiss无动画
            [root dismissViewControllerAnimated:NO completion:^{
                [root gkSetTransitionCompletion:completion];
                [root.navigationController popToRootViewControllerAnimated:flag];
            }];
        }else{
            [root dismissViewControllerAnimated:flag completion:completion];
        }
    }else{
        [self gkSetTransitionCompletion:completion];
        [self.navigationController popToRootViewControllerAnimated:flag];
    }
}

- (void)gkBackToViewController:(Class)cls
{
    [self gkBackToViewController:cls animated:YES];
}

- (void)gkBackToViewController:(Class)cls animated:(BOOL)flag
{
    [self gkBackToViewController:cls animated:flag completion:nil];
}

- (void)gkBackToViewController:(Class)cls animated:(BOOL)flag completion:(void (^)(void))completion
{
    UIViewController *viewController = nil;
    for(UIViewController *vc in self.navigationController.viewControllers){
        if([vc isKindOfClass:cls]){
            viewController = vc;
            break;
        }
    }
    if(viewController){
        [self gkBeforeBack];
        [self gkSetTransitionCompletion:completion];
        [self.navigationController popToViewController:viewController animated:flag];
    }else{
        [self gkBackAnimated:flag completion:completion];
    }
}

- (void)gkBackToPath:(NSString*) path
{
    [self gkBackToPath:path animated:YES];
}

- (void)gkBackToPath:(NSString*) path animated:(BOOL) flag
{
    [self gkBackToPath:path animated:flag completion:nil];
}

- (void)gkBackToPath:(NSString*) path animated:(BOOL) flag completion:(void (^)(void))completion
{
    UIViewController *viewController = nil;
    for(UIViewController *vc in self.navigationController.viewControllers){
        if([vc.routeConfig.path isEqualToString:path]){
            viewController = vc;
            break;
        }
    }
    if(viewController){
        [self gkBeforeBack];
        [self gkSetTransitionCompletion:completion];
        [self.navigationController popToViewController:viewController animated:flag];
    }else{
        [self gkBackAnimated:flag completion:completion];
    }
}

///返回之前
- (void)gkBeforeBack
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
}

///设置过渡动画完成回调
- (void)gkSetTransitionCompletion:(void (^)(void))completion
{
    if(completion && [self.navigationController isKindOfClass:GKBaseNavigationController.class]){
        GKBaseNavigationController *nav = (GKBaseNavigationController*)self.navigationController;
        nav.transitionCompletion = completion;
    }
}

@end

static char GKHasTabBarKey;

@implementation UIViewController (GKTabBarExtension)

- (GKTabBarController *)gkTabBarController
{
    UIViewController *vc = UIApplication.sharedApplication.delegate.window.rootViewController;
    if([vc isKindOfClass:GKTabBarController.class]){
        return (GKTabBarController*)vc;
    }
    
    vc = self.gkRootPresentingViewController;
    if([vc isKindOfClass:GKTabBarController.class]){
        return (GKTabBarController*)vc;
    }
    
    return nil;
}

- (void)setGkHasTabBar:(BOOL)gkHasTabBar
{
    objc_setAssociatedObject(self, &GKHasTabBarKey, @(gkHasTabBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkHasTabBar
{
    if([self.parentViewController isKindOfClass:UINavigationController.class]){
        UINavigationController *nav = (UINavigationController*)self.parentViewController;
        if(nav.viewControllers.firstObject == self){
            return nav.gkHasTabBar;
        }
    }
    return [objc_getAssociatedObject(self, &GKHasTabBarKey) boolValue];
}

@end
