//
//  UIViewController+GKPush.m
//  GliKit
//
//  Created by 罗海雄 on 2020/3/27.
//

#import "UIViewController+GKPush.h"
#import "UIViewController+GKUtils.h"
#import "UIViewController+GKTransition.h"
#import "GKPartialPresentTransitionDelegate.h"
#import "GKTabBarController.h"
#import "GKBaseNavigationController.h"

@implementation NSObject (GKUIViewControllerUtils)

+ (__kindof UIViewController*)gkCurrentViewController
{
    UIViewController *root = UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *parentViewControlelr = root.gkTopestPresentedViewController;
    //刚开始启动 不一定是tabBar
    if([root conformsToProtocol:@protocol(GKTabBarController)]){
        UIViewController<GKTabBarController> *tab = (UIViewController<GKTabBarController>*)root;
        if(parentViewControlelr == tab){
            parentViewControlelr = tab.selectedViewController;
        }
    }

    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        UINavigationController *nav = (UINavigationController*)parentViewControlelr;
        if(nav.viewControllers.count > 0){
            return [nav.viewControllers lastObject];
        }else{
            return nav;
        }
    }else{
        return parentViewControlelr;
    }
}

- (__kindof UIViewController*)gkCurrentViewController
{
    return NSObject.gkCurrentViewController;
}

+ (__kindof UINavigationController*)gkCurrentNavigationController
{
    UIViewController *root = UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *parentViewControlelr = root.gkTopestPresentedViewController;
    //刚开始启动 不一定是tabBar
    if([root conformsToProtocol:@protocol(GKTabBarController)]){
        UIViewController<GKTabBarController> *tab = (UIViewController<GKTabBarController>*)root;
        if(parentViewControlelr == tab){
            parentViewControlelr = tab.selectedViewController;
        }
    }
    
    if([parentViewControlelr.gkTransitioningDelegate isKindOfClass:[GKPartialPresentTransitionDelegate class]]){
        parentViewControlelr = parentViewControlelr.presentingViewController;
    }
    
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        return (UINavigationController*)parentViewControlelr;
    }else{
        return parentViewControlelr.navigationController;
    }
}

- (__kindof UINavigationController*)gkCurrentNavigationController
{
    return NSObject.gkCurrentNavigationController;
}

// MARK: - push

+ (void)gkPushViewController:(UIViewController*) viewController
{
    [self gkPushViewController:viewController toReplacedViewControlelrs:nil];
}

- (void)gkPushViewController:(UIViewController *)viewController
{
    [self.class gkPushViewController:viewController];
}

+ (void)gkPushViewControllerReplaceLastSameIfNeeded:(UIViewController*) viewController
{
    [self gkPushViewController:viewController shouldReplace:YES shouldSame:YES];
}

- (void)gkPushViewControllerReplaceLastSameIfNeeded:(UIViewController *)viewController
{
    [self.class gkPushViewControllerReplaceLastSameIfNeeded:viewController];
}

+ (void)gkReplaceCurrentWithViewController:(UIViewController *)viewController
{
    [self gkPushViewController:viewController shouldReplace:YES shouldSame:NO];
}

- (void)gkReplaceCurrentWithViewController:(UIViewController *)viewController
{
    [self.class gkReplaceCurrentWithViewController:viewController];
}

+ (void)gkPushViewController:(UIViewController*) viewController shouldReplace:(BOOL) replace shouldSame:(BOOL) shouldSame
{
    if(!viewController)
        return;
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    
    UINavigationController *nav = parentViewControlelr.navigationController;
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController*)parentViewControlelr;
    }
    
    if(nav){
        if(shouldSame && replace){
            replace = [parentViewControlelr isKindOfClass:[viewController class]];
        }
        if(replace){
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
            [viewControllers removeLastObject];
            [viewControllers addObject:viewController];
            
            [nav setViewControllers:viewControllers animated:YES];
        }else{
            [nav pushViewController:viewController animated:YES];
        }
           
    }else{
        [parentViewControlelr gkPushViewControllerUseTransitionDelegate:viewController];
    }
}

+ (void)gkPushViewControllerRemoveSameIfNeeded:(UIViewController*) viewController;
{
    if(!viewController)
        return;
    viewController.hidesBottomBarWhenPushed = YES;
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    
    UINavigationController *nav = parentViewControlelr.navigationController;
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController*)parentViewControlelr;
    }
    if(nav){
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
        NSMutableArray *removedViewControlelrs = [NSMutableArray array];
        for(UIViewController *vc in viewControllers){
            if([vc isKindOfClass:[viewController class]]){
                [removedViewControlelrs addObject:vc];
            }
        }
        [viewControllers removeObjectsInArray:removedViewControlelrs];
        if ([viewController isKindOfClass:GKBaseViewController.class]) {
            GKBaseViewController *vc = (GKBaseViewController*)viewController;
            vc.showBackItem = YES;
        }
        [viewControllers addObject:viewController];
        
        [nav setViewControllers:viewControllers animated:YES];
    }else{
        [parentViewControlelr gkPushViewControllerUseTransitionDelegate:viewController];
    }
}

- (void)gkPushViewControllerRemoveSameIfNeeded:(UIViewController *)viewController
{
    [self.class gkPushViewControllerRemoveSameIfNeeded:viewController];
}

+ (void)gkPushViewController:(UIViewController *)viewController toReplacedViewControlelrs:(NSArray<UIViewController *> *)toReplacedViewControlelrs
{
    [self gkPushViewController:viewController toReplacedViewControlelrs:toReplacedViewControlelrs completion:nil];
}

- (void)gkPushViewController:(UIViewController *)viewController toReplacedViewControlelrs:(NSArray<UIViewController *> *)toReplacedViewControlelrs
{
    [self.class gkPushViewController:viewController toReplacedViewControlelrs:toReplacedViewControlelrs completion:nil];
}

- (void)gkPushViewController:(UIViewController *)viewController toReplacedViewControlelrs:(NSArray<UIViewController *> *)toReplacedViewControlelrs completion:(void (^)(void))completion
{
    [self.class gkPushViewController:viewController toReplacedViewControlelrs:toReplacedViewControlelrs completion:completion];
}


+ (void)gkPushViewController:(UIViewController*) viewController toReplacedViewControlelrs:(nullable NSArray<UIViewController*> *) toReplacedViewControlelrs completion:(void(^)(void)) completion
{
    if(!viewController)
        return;
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    
    GKBaseNavigationController *nav = (GKBaseNavigationController*)parentViewControlelr.navigationController;
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        nav = (GKBaseNavigationController*)parentViewControlelr;
    }
    
    if(completion != nil && [nav isKindOfClass:GKBaseNavigationController.class]){
        nav.transitionCompletion = completion;
    }
    
    if(nav){
        if(toReplacedViewControlelrs.count > 0){
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
            [viewControllers removeObjectsInArray:toReplacedViewControlelrs];
            [viewControllers addObject:viewController];
            
            [nav setViewControllers:viewControllers animated:YES];
        }else{
            [nav pushViewController:viewController animated:YES];
        }
           
    }else{
        [parentViewControlelr gkPushViewControllerUseTransitionDelegate:viewController];
    }
}

@end
