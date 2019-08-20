//
//  GKBaseNavigationController.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKBaseNavigationController.h"
#import "GKSystemNavigationBar.h"

@interface GKBaseNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation GKBaseNavigationController

- (instancetype)init
{
    return [self initWithRootViewController:nil];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [self initWithNavigationBarClass:GKSystemNavigationBar.class toolbarClass:nil];
    if(rootViewController){
        self.viewControllers = @[rootViewController];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //把导航栏变成透明
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.tintColor = UIColor.appNavigationBarTintColor;
    
    __weak GKBaseNavigationController *weakSelf = self;
    
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}

#pragma mark push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return [super popToViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.interactivePopGestureRecognizer.enabled = viewController.gk_interactivePopEnable;
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer){
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers firstObject]){
            return NO;
        }else{
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
        }
    }
    
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIApplication.appStatusBarStyle;
}

- (UIViewController*)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

@end
