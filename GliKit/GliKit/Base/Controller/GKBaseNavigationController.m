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
#import "GKNavigationTransitionAnimator.h"
#import "GKNavigationInteractiveTransition.h"

@interface GKBaseNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

///其他代理
@property(nonatomic, weak) id<UINavigationControllerDelegate> otherDelegate;

///设置是否可以使用滑动返回
@property(nonatomic, assign) BOOL interactivePodEnabled;

@end

@implementation GKBaseNavigationController

@synthesize customInteractivePopGestureRecognizer = _customInteractivePopGestureRecognizer;

- (instancetype)init
{
    self = [super initWithNavigationBarClass:GKSystemNavigationBar.class toolbarClass:nil];
    if (self) {
        [self initParams];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:GKSystemNavigationBar.class toolbarClass:nil];
    if(self){
        [self initParams];
        self.viewControllers = @[rootViewController];
    }
    return self;
}

///初始化参数
- (void)initParams
{
    self.customTransitionDuration = 0.25;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

- (UIScreenEdgePanGestureRecognizer *)customInteractivePopGestureRecognizer
{
    if(!_customInteractivePopGestureRecognizer){
        _customInteractivePopGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleInteractivePop:)];
        _customInteractivePopGestureRecognizer.edges = UIRectEdgeLeft;
    }
    return _customInteractivePopGestureRecognizer;
}

- (void)setShouldUseCustomTransition:(BOOL)shouldUseCustomTransition
{
    if(_shouldUseCustomTransition != shouldUseCustomTransition){
        _shouldUseCustomTransition = shouldUseCustomTransition;
        if(_shouldUseCustomTransition){
            if(_customInteractivePopGestureRecognizer.view == nil){
                [self.view addGestureRecognizer:self.customInteractivePopGestureRecognizer];
            }
            _customInteractivePopGestureRecognizer.enabled = YES;
        }else{
            _customInteractivePopGestureRecognizer.enabled = NO;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.shouldUseCustomTransition){
        [self.view addGestureRecognizer:self.customInteractivePopGestureRecognizer];
    }
    
    self.interactivePopGestureRecognizer.delegate = self;
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handleInteractivePop:)];
    self.delegate = self;
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
        case UIGestureRecognizerStateBegan : {
            _isInteractivePop = YES;
            if(sender == self.customInteractivePopGestureRecognizer){
                [self popViewControllerAnimated:YES];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled :
        case UIGestureRecognizerStateEnded : {
            
            _isInteractivePop = NO;
        }
            break;
            
        default:
            break;
    }
}

///设置是否可以使用滑动返回
- (void)setInteractivePodEnabled:(BOOL) enabled
{
    _interactivePodEnabled = enabled;
    if(self.shouldUseCustomTransition){
        self.customInteractivePopGestureRecognizer.enabled = enabled;
    }else{
        self.interactivePopGestureRecognizer.enabled = enabled;
    }
}

// MARK: - Push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(animated){
        self.interactivePodEnabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    if(animated){
        self.interactivePodEnabled = NO;
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.interactivePodEnabled = NO;
    
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
    self.interactivePodEnabled = viewController.gkInteractivePopEnabled;
    if([self.otherDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]){
        [self.otherDelegate navigationController:self didShowViewController:viewController animated:animate];
    }
    
    if(self.transitionCompletion){
        self.transitionCompletion();
        self.transitionCompletion = nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if(self.shouldUseCustomTransition){
        GKNavigationTransitionAnimator *animator = GKNavigationTransitionAnimator.new;
        animator.operation = operation;
        animator.transitionDuration = self.customTransitionDuration;
        
        return animator;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if(self.shouldUseCustomTransition && self.isInteractivePop){
        GKNavigationInteractiveTransition *transition = GKNavigationInteractiveTransition.new;
        transition.gestureRecognizer = self.customInteractivePopGestureRecognizer;

        return transition;
    }
    return nil;
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
