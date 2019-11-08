//
//  GKBaseNavigationController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseNavigationController.h"
#import "GKSystemNavigationBar.h"
#import "UIApplication+GKTheme.h"
#import "UIViewController+GKUtils.h"

@interface GKBaseNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation GKBaseNavigationController

- (instancetype)init
{
    self = [super initWithNavigationBarClass:GKSystemNavigationBar.class toolbarClass:nil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:GKSystemNavigationBar.class toolbarClass:nil];
    if(self){
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.viewControllers = @[rootViewController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak GKBaseNavigationController *weakSelf = self;
    
    self.interactivePopGestureRecognizer.delegate = weakSelf;
    self.delegate = weakSelf;
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle
{
    return UIUserInterfaceStyleLight;
}

// MARK: - Push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(animated){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    if(animated){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.interactivePopGestureRecognizer.enabled = NO;
    
    return [super popToViewController:viewController animated:animated];
}

// MARK: - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    self.interactivePopGestureRecognizer.enabled = viewController.gkInteractivePopEnable;
}

// MARK: - UIGestureRecognizerDelegate

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

// MARK: - UIStatusBar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIApplication.gkStatusBarStyle;
}

- (UIViewController*)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

@end
