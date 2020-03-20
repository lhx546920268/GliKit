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

///其他代理
@property(nonatomic, weak) id<UINavigationControllerDelegate> otherDelegate;

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
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handleInteractivePop:)];
    self.delegate = weakSelf;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if(delegate != self){
        self.otherDelegate = delegate;
    }
    [super setDelegate:self];
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle
{
    return UIUserInterfaceStyleLight;
}

// MARK: - Action

///滑动返回
- (void)handleInteractivePop:(UIScreenEdgePanGestureRecognizer*) sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateCancelled :
        case UIGestureRecognizerStateEnded : {
            
            _isInteractivePop = NO;
        }
            break;
            
        default:
            break;
    }
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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([self.otherDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]){
        [self.otherDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    self.interactivePopGestureRecognizer.enabled = viewController.gkInteractivePopEnable;
    if([self.otherDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]){
        [self.otherDelegate navigationController:self didShowViewController:viewController animated:animate];
    }
    
    if(self.transitionCompletion){
        self.transitionCompletion();
        self.transitionCompletion = nil;
    }
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
    
    _isInteractivePop = YES;
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
