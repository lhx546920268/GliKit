//
//  GKRouter.m
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKRouter.h"
#import "NSObject+GKUtils.h"
#import "NSDictionary+GKUtils.h"
#import "NSString+GKUtils.h"
#import "UIViewController+GKUtils.h"
#import "UIViewController+GKPush.h"
#import "GKBaseDefines.h"
#import "GKBaseNavigationController.h"
#import "UIViewController+GKTransition.h"
#import "GKAppUtils.h"

///路由属性
@interface GKRouteConfig(GKRoutePrivate)

///路由参数
@property(nonatomic, strong) NSDictionary *routeParams;

@end

@interface UIViewController (GKRoutePrivate)

///当前路由配置，只有通过路由的方式打开的才有
@property(nonatomic, strong) GKRouteConfig *routeConfig;

@end

@interface GKRouter ()

//已注册的
@property(nonatomic, readonly) NSMutableDictionary<NSString*, GKRouteHandler> *registrations;

///拦截器
@property(nonatomic, readonly) NSMutableArray *interceptors;

///当前需要关闭的界面
@property(nonatomic, strong) NSMutableArray *toClosedViewControllers;

@end

@implementation GKRouter

@synthesize registrations = _registrations;
@synthesize interceptors = _interceptors;

+ (GKRouter *)sharedRouter
{
    static dispatch_once_t onceToken;
    static GKRouter *sharedRouter = nil;
    
    dispatch_once(&onceToken, ^{
        
        sharedRouter = [self.class new];
    });
    
    return sharedRouter;
}

- (NSMutableArray *)toClosedViewControllers
{
    if (!_toClosedViewControllers) {
        _toClosedViewControllers = [NSMutableArray array];
    }
    return _toClosedViewControllers;
}

- (NSMutableDictionary<NSString *, GKRouteHandler> *)registrations
{
    if(!_registrations){
        _registrations = [NSMutableDictionary new];
    }
    return _registrations;
}

- (NSMutableArray *)interceptors
{
    if(!_interceptors){
        _interceptors = [NSMutableArray array];
    }
    return _interceptors;
}

- (void)addInterceptor:(id<GKRouteInterceptor>)interceptor
{
    NSParameterAssert(interceptor != nil);
    [self.interceptors addObject:interceptor];
}

- (void)removeInterceptor:(id<GKRouteInterceptor>)interceptor
{
    NSParameterAssert(interceptor != nil);
    [self.interceptors removeObject:interceptor];
}

- (void)registerPath:(NSString *)path forHandler:(GKRouteHandler)handler
{
    NSParameterAssert(path != nil);
    NSParameterAssert(handler != nil);
    
    self.registrations[path] = handler;
}

- (void)unregisterPath:(NSString *)path
{
    _registrations[path] = nil;
}

- (void)open:(void (NS_NOESCAPE ^)(GKRouteConfig*))block
{
    NSParameterAssert(block != nil);
    
    GKRouteConfig *config = [GKRouteConfig new];
    @try {
        block(config);
        if(!config.URLComponents){
            if(config.URLString){
                config.URLComponents = [NSURLComponents componentsWithString:config.URLString];
            }else if(config.path){
                config.URLComponents = [NSURLComponents componentsWithString:config.path];
            }
        }
        
        [self openWithConfig:config];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

// MARK: - ViewController


- (UIViewController *)viewControllerForConfig:(GKRouteConfig*) config
{
    UIViewController *viewController = nil;
    
    BOOL processBySelf = NO;
    
    NSString *path = config.path;
    if(![NSString isEmpty:path]){
        
        GKRouteHandler handler = _registrations[path];
        if (handler != nil) {
            viewController = handler(config);
        }
        processBySelf = YES;
        
        if(![viewController isKindOfClass:UIViewController.class]){
            viewController = nil;
        }
    }
    
    if(!viewController){
        if(!processBySelf){
            [self cannotFoundWithConfig:config];
        }
    }else{
        [viewController configRoute:config];
    }
    
    return viewController;
}

///打开一个页面
- (void)openWithConfig:(GKRouteConfig*) config
{
    NSURLComponents *components = config.URLComponents;
    if(!components){
        [self cannotFoundWithConfig:config];
        !config.completion ?: config.completion(GKRouteResultFailed);
        return;
    }
    
    NSMutableDictionary *params = nil;
    NSArray *queryItems = components.queryItems;
    if(config.extras.count > 0 || queryItems.count > 0){
        params = [NSMutableDictionary dictionary];
        //添加URL上的参数
        for(NSURLQueryItem *item in queryItems){
            if(![NSString isEmpty:item.name] && ![NSString isEmpty:item.value]){
                params[item.name] = item.value;
            }
        }
        [params addEntriesFromDictionary:config.extras];
    }
    
    config.routeParams = params;
    
    if(_interceptors.count > 0){
        [self interceptRoute:config forIndex:0];
    }else{
        [self continueRoute:config];
    }
}

///拦截器处理
- (void)interceptRoute:(GKRouteConfig*) config forIndex:(NSInteger) index
{
    [self.interceptors[index] processRoute:config interceptHandler:^(GKRouteInterceptPolicy policy) {
        if(policy == GKRouteInterceptPolicyAllow){
            if(index + 1 < self.interceptors.count){
                [self interceptRoute:config forIndex:index + 1];
            }else{
                [self continueRoute:config];
            }
        }else{
            !config.completion ?: config.completion(GKRouteResultCancelled);
        }
    }];
}

///跳转
- (void)continueRoute:(GKRouteConfig*) config
{
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    GKBaseNavigationController *nav = (GKBaseNavigationController*)parentViewControlelr.navigationController;
    NSString *path = config.path;
    
    if(config.style == GKRouteStyleBackIfEnabled && [nav isKindOfClass:UINavigationController.class]){
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
        if(viewControllers.count >= 2){
            UIViewController *vc = viewControllers[viewControllers.count - 2];
            if([vc.routePath isEqualToString:path]){
                [parentViewControlelr gkBack];
                return;
            }
        }
    }
    
    UIViewController *viewController = [self viewControllerForConfig:config];
    if(!viewController){
        
        //重定向
        if(![path isEqualToString:config.path]){
            [self continueRoute:config];
            return;
        }
        return;
    }
    viewController.routeConfig = config;
    !config.willRoute ?: config.willRoute(viewController);
    
    if(config.isPresent){
        if(config.style == GKRouteStylePresent){
            viewController = viewController.gkCreateWithNavigationController;
        }
        [parentViewControlelr.gkTopestPresentedViewController presentViewController:viewController animated:config.animated completion:^{
            !config.completion ?: config.completion(GKRouteResultSuccess);
        }];
    }else{
        
        GKBaseNavigationController *nav = (GKBaseNavigationController*)parentViewControlelr.navigationController;
        if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
            nav = (GKBaseNavigationController*)parentViewControlelr;
        }
        
        if(config.completion != nil && [nav isKindOfClass:GKBaseNavigationController.class]){
            nav.transitionCompletion = ^{
                //防止动画过程中被改变
                !config.completion ?: config.completion(GKRouteResultSuccess);
            };
        }
        if(nav){
            NSMutableArray *toReplacedViewControlelrs = self.toClosedViewControllers;
            NSArray *viewControllers = nav.viewControllers;
            switch (config.style) {
                case GKRouteStyleReplace : {
                    if(viewControllers.count > 0){
                        [toReplacedViewControlelrs addObject:nav.viewControllers.lastObject];
                    }
                }
                    break;
                case GKRouteStyleOnlyOne : {
                    for(UIViewController *vc in viewControllers){
                        if([vc isKindOfClass:viewController.class]){
                            [toReplacedViewControlelrs addObject:vc];
                        }
                    }
                }
                    break;
                case  GKRouteStylePresent :
                case GKRouteStylePush :
                case GKRouteStylePresentWithoutNavigationBar :
                case GKRouteStyleBackIfEnabled :
                    break;
            }
            
            if(config.routesToClosed.count > 0){
                for(UIViewController *vc in viewControllers){
                    NSString *path = vc.routePath;
                    if(path && [config.routesToClosed containsObject:path]){
                        [toReplacedViewControlelrs addObject:vc];
                    }
                }
            }
            
            if(config.closeRouteIfSame){
                for(UIViewController *vc in viewControllers){
                    if ([vc.routeConfig isEqual:config]) {
                        [toReplacedViewControlelrs addObject:vc];
                    }
                }
            }

            
            if(![NSString isEmpty:config.closeUntilRoute]){
                for(NSInteger i = viewControllers.count - 1;i >= 0;i --){
                    UIViewController *vc = viewControllers[i];
                    if([vc.routePath isEqualToString:config.closeUntilRoute]){
                        NSArray *subArray = [viewControllers subarrayWithRange:NSMakeRange(i, viewControllers.count - i)];
                        [toReplacedViewControlelrs addObjectsFromArray:subArray];
                        break;
                    }
                }
            }
            
            if(toReplacedViewControlelrs.count > 0){
                NSMutableArray *vcs = [NSMutableArray arrayWithArray:viewControllers];
                [vcs removeObjectsInArray:viewControllers];
                [vcs addObject:viewController];
                
                [nav setViewControllers:vcs animated:config.animated];
            }else{
                [nav pushViewController:viewController animated:config.animated];
            }
            [toReplacedViewControlelrs removeAllObjects];
        }else{
            [parentViewControlelr gkPushViewControllerUseTransitionDelegate:viewController];
        }
    }
    
}

///找不到对应的页面
- (void)cannotFoundWithConfig:(GKRouteConfig*) config
{
#ifdef DEBUG
    NSString *URLString = config.URLString ? config.URLString : config.path;
    NSLog(@"Can not found viewControlelr for %@", URLString);
#endif
    !self.failureHandler ?: self.failureHandler(config);
}

@end
