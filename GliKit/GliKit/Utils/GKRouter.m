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

- (void)configRoute:(GKRouteConfig *)config
{
    //子类重写
}

@end

///路由属性
@interface GKRouteConfig()

///路由参数
@property(nonatomic, strong) NSDictionary *routeParams;

///完成回调
@property(nonatomic, copy) GKRouteCompletion completion;

///是否是弹出来
@property(nonatomic, readonly) BOOL isPresent;

@end

@implementation GKRouteConfig

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
        NSString *host = components.host;
        NSString *path = components.path;
        if([NSString isEmpty:host]){
            host = path;
        }else if(![NSString isEmpty:path]){
            host = [NSString stringWithFormat:@"%@%@", host, path];
        }
        _path = host;
    }
    
    return _path;
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.openURLWhileSchemeNotSupport = YES;
    }
    return self;
}

- (NSString *)appScheme
{
    if(!_appScheme){
        return @"app://";
    }
    
    return _appScheme;
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
                config.URLComponents = [NSURLComponents componentsWithString:[self.appScheme stringByAppendingString:config.path]];
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
    
    NSURLComponents *components = config.URLComponents;
    NSString *scheme = [components.scheme stringByAppendingString:@"://"];
    if([scheme isEqualToString:self.appScheme]){
        NSString *host = components.host;
        NSString *path = components.path;
        if([NSString isEmpty:host]){
            host = path;
        }else if(![NSString isEmpty:path]){
            host = [NSString stringWithFormat:@"%@%@", host, path];
        }
        
        if(![NSString isEmpty:host]){
            
            GKRouteRegistration *registration = _registrations[host];
            if(registration.handler){
                viewController = registration.handler(config);
                processBySelf = YES;
            }else if(registration.cls){
                Class cls = registration.cls;
                viewController = [cls new];
            }else{
                Class cls = NSClassFromString(host);
                viewController = [cls new];
            }
            
            if(![viewController isKindOfClass:UIViewController.class]){
                viewController = nil;
            }
        }
    }else if([scheme isEqualToString:@"http://"] || [scheme isEqualToString:@"https://"]){
        GKBaseWebViewController *web = [[GKBaseWebViewController alloc] initWithURLString:components.string];
        viewController = web;
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

///获取在tabBar上面对应的下标
- (NSInteger)tabBarIndexForName:(NSString*) name
{
    UITabBarController *controller = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
    if([controller isKindOfClass:UITabBarController.class]){
        for(NSInteger i = 0;i < controller.viewControllers.count;i ++){
            UIViewController *vc = controller.viewControllers[i];
            if ([vc isKindOfClass:UINavigationController.class]){
                UINavigationController *nav = (UINavigationController*)vc;
                vc = nav.viewControllers.firstObject;
            }
            
            if([vc.gkNameOfClass isEqualToString:name]){
                return i;
            }
        }
    }
    
    return NSNotFound;
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
    NSURLComponents *components = config.URLComponents;
    NSInteger tabBarIndex = [self tabBarIndexForName:components.host];
    if(tabBarIndex != NSNotFound){
        [self.gkCurrentViewController gkBackAnimated:NO completion:^{
            UITabBarController *controller = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
            controller.selectedIndex = tabBarIndex;
            !config.completion ?: config.completion(GKRouteResultSuccess);
        }];
        return;
    }
    
    UIViewController *viewController = [self viewControllerForConfig:config];
    if(!viewController){
        if(self.openURLWhileSchemeNotSupport && ![self isSupportScheme:components.scheme]){
            [GKAppUtils openCompatURL:components.URL];
        }
        return;
    }
    
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    if(config.isPresent){
        if(config.style == GKRouteStylePresent){
            viewController = viewController.gkCreateWithNavigationController;
        }
        [parentViewControlelr.gkTopestPresentedViewController presentViewController:viewController animated:YES completion:^{
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
                }
                    break;
                case  GKRouteStylePresent :
                case GKRouteStylePush :
                case GKRouteStylePresentWithoutNavigationBar :
                    break;
            }
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

///判断scheme是否支持
- (BOOL)isSupportScheme:(NSString*) scheme
{
    scheme = [scheme stringByAppendingString:@"://"];
    return [scheme isEqualToString:self.appScheme] || [scheme isEqualToString:@"http://"] || [scheme isEqualToString:@"https://"];
}

@end
