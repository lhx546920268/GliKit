//
//  UIViewController+GKPush.m
//  AFNetworking
//
//  Created by 罗海雄 on 2020/3/27.
//

#import "UIViewController+GKPush.h"
#import "UIViewController+GKUtils.h"
#import "UIViewController+GKTransition.h"
#import "GKPartialPresentTransitionDelegate.h"


@implementation NSObject (GKUIViewControllerUtils)

+ (UIViewController*)gkCurrentViewController
{
    //刚开始启动 不一定是tabBar
    if(![UIApplication.sharedApplication.delegate.window.rootViewController isKindOfClass:[UITabBarController class]]){
        return UIApplication.sharedApplication.delegate.window.rootViewController;
    }
    
    UITabBarController *tab = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *parentViewControlelr = tab.gkTopestPresentedViewController;
    if(parentViewControlelr == tab){
        parentViewControlelr = tab.selectedViewController;
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

- (UIViewController*)gkCurrentViewController
{
    return NSObject.gkCurrentViewController;
}

+ (UINavigationController*)gkCurrentNavigationController
{
    //刚开始启动 不一定是tabBar
    if(![UIApplication.sharedApplication.delegate.window.rootViewController isKindOfClass:[UITabBarController class]]){
        return UIApplication.sharedApplication.delegate.window.rootViewController.navigationController;
    }
    
    UITabBarController *tab = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *parentViewControlelr = tab.gkTopestPresentedViewController;
    
    if([parentViewControlelr.gkTransitioningDelegate isKindOfClass:[GKPartialPresentTransitionDelegate class]]){
        parentViewControlelr = parentViewControlelr.presentingViewController;
    }
    
    if(parentViewControlelr == tab){
        parentViewControlelr = tab.selectedViewController;
    }

    
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        return (UINavigationController*)parentViewControlelr;
    }else{
        return parentViewControlelr.navigationController;
    }
}

- (UINavigationController*)gkCurrentNavigationController
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
        viewController.gkShowBackItem = YES;
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
    if(!viewController)
        return;
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    
    UINavigationController *nav = parentViewControlelr.navigationController;
    if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController*)parentViewControlelr;
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

- (void)gkPushViewController:(UIViewController *)viewController toReplacedViewControlelrs:(NSArray<UIViewController *> *)toReplacedViewControlelrs
{
    [self.class gkPushViewController:viewController toReplacedViewControlelrs:toReplacedViewControlelrs];
}

@end
