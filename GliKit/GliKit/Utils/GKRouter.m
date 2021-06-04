//
//  GKRouter.m
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKRouter.h"
#import "GKBaseViewController.h"
#import "GKObject.h"
#import "NSObject+GKUtils.h"
#import "NSDictionary+GKUtils.h"
#import "NSString+GKUtils.h"
#import "UIViewController+GKUtils.h"
#import "GKBaseWebViewController.h"
#import "UIViewController+GKPush.h"
#import "GKBaseDefines.h"
#import "GKBaseNavigationController.h"
#import "UIViewController+GKTransition.h"
#import "GKAppUtils.h"
#import <objc/runtime.h>

static char CARouteConfigKey;

@implementation UIViewController (GKRouteUtils)

- (GKRouteConfig *)routeConfig
{
    return objc_getAssociatedObject(self, &CARouteConfigKey);
}

- (void)setRouteConfig:(GKRouteConfig*) config
{
    objc_setAssociatedObject(self, &CARouteConfigKey, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)routePath
{
    return self.routeConfig.path;
}

- (void)configRoute:(GKRouteConfig *)config
{
    //子类重写
}

@end

///路由属性
@interface GKRouteConfig()

///路由参数
@property(nonatomic, strong) NSDictionary *routeParams;

///是否是弹出来
@property(nonatomic, readonly) BOOL isPresent;

@end

@implementation GKRouteConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.animated = YES;
    }
    return self;
}

- (BOOL)isPresent
{
    return self.style == GKRouteStylePresent || self.style == GKRouteStylePresentWithoutNavigationBar;
}

- (NSString *)URLString
{
    if(_URLString){
        return _URLString;
    }
    
    return self.URLComponents.string;
}

- (NSString *)path
{
    if(_path){
        return _path;
    }
    
    NSURLComponents *components = self.URLComponents;
    if(!components && self.URLString){
        components = [NSURLComponents componentsWithString:self.URLString];
    }
    
    if(components){
        _path = components.path;
    }
    
    return _path;
}

- (NSDictionary *)mExtras
{
    if(!_extras){
        _extras = [NSMutableDictionary dictionary];
    }
    NSAssert([_extras isKindOfClass:NSMutableDictionary.class], @"CARouteConfig.mExtras must be NSMutableDictionary");
    
    return _extras;
}

@end

///注册的信息
@interface GKRouteRegistration : NSObject

///类
@property(nonatomic, strong) Class cls;

///回调
@property(nonatomic, copy) GKRouteHandler handler;

@end

@implementation GKRouteRegistration

@end

@interface GKRouter ()

//已注册的
@property(nonatomic, readonly) NSMutableDictionary<NSString*, GKRouteRegistration*> *registrations;

///拦截器
@property(nonatomic, readonly) NSMutableArray *interceptors;

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

- (NSMutableDictionary<NSString *,GKRouteRegistration *> *)registrations
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

- (void)registerPath:(NSString *)path forClass:(Class)cls
{
    NSParameterAssert(path != nil);
    NSAssert([cls isKindOfClass:UIViewController.class], @"the class for %@ must be a UIViewController", path);
    
    GKRouteRegistration *registration = [GKRouteRegistration new];
    registration.cls = cls;
    self.registrations[path] = registration;
}

- (void)registerPath:(NSString *)path forHandler:(GKRouteHandler)handler
{
    NSParameterAssert(path != nil);
    NSParameterAssert(handler != nil);
    
    GKRouteRegistration *registration = [GKRouteRegistration new];
    registration.handler = handler;
    self.registrations[path] = registration;
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
        
        GKRouteRegistration *registration = _registrations[path];
        if(registration.handler){
            viewController = registration.handler(config);
            processBySelf = YES;
        }else if(registration.cls){
            Class cls = registration.cls;
            viewController = [cls new];
        }else{
            Class cls = NSClassFromString(path);
            viewController = [cls new];
        }
        
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
                config.completion(GKRouteResultSuccess);
            };
        }
        if(nav){
            NSArray *toReplacedViewControlelrs = nil;
            switch (config.style) {
                case GKRouteStyleReplace : {
                    if(nav.viewControllers.count > 0){
                        toReplacedViewControlelrs = @[nav.viewControllers.lastObject];
                    }
                }
                    break;
                case GKRouteStyleOnlyOne : {
                    NSMutableArray *viewControllers = [NSMutableArray array];
                    for(UIViewController *vc in nav.viewControllers){
                        if([vc isKindOfClass:viewController.class]){
                            [viewControllers addObject:vc];
                        }
                    }
                    toReplacedViewControlelrs = viewControllers;
                }
                    break;
                case  GKRouteStylePresent :
                case GKRouteStylePush :
                case GKRouteStylePresentWithoutNavigationBar :
                case GKRouteStyleBackIfEnabled :
                    break;
            }
            
            if(config.routesToClosed.count > 0){
                NSMutableArray *viewControllers = [NSMutableArray array];
                for(UIViewController *vc in nav.viewControllers){
                    NSString *path = vc.routePath;
                    if(path && [config.routesToClosed containsObject:path]){
                        [viewControllers addObject:vc];
                    }
                }
                if(toReplacedViewControlelrs.count > 0){
                    [viewControllers addObjectsFromArray:toReplacedViewControlelrs];
                }
                toReplacedViewControlelrs = viewControllers;
            }
            
            if(![NSString isEmpty:config.closeUntilRoute]){
                NSMutableArray *viewControllers = [NSMutableArray array];
                NSArray *vcs = nav.viewControllers;
                for(NSInteger i = vcs.count - 1;i >= 0;i --){
                    UIViewController *vc = vcs[i];
                    if([vc.routePath isEqualToString:config.closeUntilRoute]){
                        [viewControllers addObjectsFromArray:[vcs subarrayWithRange:NSMakeRange(i, vcs.count - i)]];
                        if(toReplacedViewControlelrs.count > 0){
                            [viewControllers addObjectsFromArray:toReplacedViewControlelrs];
                        }
                        toReplacedViewControlelrs = viewControllers;
                        break;
                    }
                }
            }
            
            if(toReplacedViewControlelrs.count > 0){
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
                [viewControllers removeObjectsInArray:toReplacedViewControlelrs];
                [viewControllers addObject:viewController];
                
                [nav setViewControllers:viewControllers animated:config.animated];
            }else{
                [nav pushViewController:viewController animated:config.animated];
            }
        }else{
            [parentViewControlelr gkPushViewControllerUseTransitionDelegate:viewController];
        }
    }
    
}

///找不到对应的页面
- (void)cannotFoundWithConfig:(GKRouteConfig*) config
{
    NSString *URLString = config.URLString ? config.URLString : config.path;
#ifdef DEBUG
    NSLog(@"Can not found viewControlelr for %@", URLString);
#endif
    !self.failureHandler ?: self.failureHandler(URLString, config.extras);
}

@end
