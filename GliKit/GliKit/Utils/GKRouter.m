//
//  GKRouter.m
//  GliKit
//
//  Created by 罗海雄 on 2019/6/6.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKRouter.h"
#import <objc/runtime.h>
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

@implementation UIViewController (GKRouterUtils)

- (void)setRouterParams:(NSDictionary*) params
{
    //子类重写
}

@end

///路由属性
@interface GKRouteProps()

///页面原始链接
@property(nonatomic, strong) NSURLComponents *URLComponents;

///路由参数
@property(nonatomic, strong) NSDictionary *routeParams;

///完成回调
@property(nonatomic, copy) GKRouteCompletion completion;

///是否是弹出来
@property(nonatomic, readonly) BOOL isPresent;

@end

@implementation GKRouteProps

- (BOOL)isPresent
{
    return self.style == GKRouteStylePresent || self.style == GKRouteStylePresentWithoutNavigationBar;
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

- (void)open:(void (NS_NOESCAPE ^)(GKRouteProps*))block
{
    NSParameterAssert(block != nil);
    
    GKRouteProps *props = [GKRouteProps new];
    block(props);

    if(props.URLString){
        props.URLComponents = [NSURLComponents componentsWithString:props.URLString];
    }else if(props.path){
        props.URLComponents = [NSURLComponents componentsWithString:[self.appScheme stringByAppendingString:props.path]];
    }
    
    [self openWithProps:props];
}

// MARK: - ViewController


- (UIViewController *)viewControllerForProps:(GKRouteProps*) props
{
    UIViewController *viewController = nil;
    
    BOOL processBySelf = NO;
    
    NSURLComponents *components = props.URLComponents;
    NSString *scheme = [components.scheme stringByAppendingString:@"://"];
    if([scheme isEqualToString:self.appScheme]){
        NSString *host = components.host;
        if(![NSString isEmpty:host]){
            
            GKRouteRegistration *registration = _registrations[host];
            if(registration.handler){
                viewController = registration.handler(props.routeParams);
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
            [self cannotFoundWithProps:props];
        }
    }else if(props.routeParams.count > 0){
        
        [self setPropertyForViewController:viewController data:props.routeParams];
        [viewController setRouterParams:props.routeParams];
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
- (void)openWithProps:(GKRouteProps*) props
{
    NSURLComponents *components = props.URLComponents;
    if(!components){
        [self cannotFoundWithProps:props];
        !props.completion ?: props.completion(GKRouteResultFailed);
        return;
    }
    
    NSMutableDictionary *params = nil;
    NSArray *queryItems = components.queryItems;
    if(props.extras.count > 0 || queryItems.count > 0){
        params = [NSMutableDictionary dictionary];
        //添加URL上的参数
        for(NSURLQueryItem *item in queryItems){
            if(![NSString isEmpty:item.name] && ![NSString isEmpty:item.value]){
                params[item.name] = item.value;
            }
        }
        [params addEntriesFromDictionary:props.extras];
    }
    
    props.routeParams = params;
    
    if(_interceptors.count > 0){
        [self interceptRoute:props forIndex:0];
    }else{
        [self continueRoute:props];
    }
}

///拦截器处理
- (void)interceptRoute:(GKRouteProps*) props forIndex:(NSInteger) index
{
    [self.interceptors[index] processRoute:props interceptHandler:^(GKRouteInterceptPolicy policy) {
        if(policy == GKRouteInterceptPolicyAllow){
            if(index + 1 < self.interceptors.count){
                [self interceptRoute:props forIndex:index + 1];
            }else{
                [self continueRoute:props];
            }
        }else{
            !props.completion ?: props.completion(GKRouteResultCancelled);
        }
    }];
}

///跳转
- (void)continueRoute:(GKRouteProps*) props
{
    NSURLComponents *components = props.URLComponents;
    NSInteger tabBarIndex = [self tabBarIndexForName:components.host];
    if(tabBarIndex != NSNotFound){
        [self.gkCurrentViewController gkBackAnimated:NO completion:^{
            UITabBarController *controller = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
            controller.selectedIndex = tabBarIndex;
            !props.completion ?: props.completion(GKRouteResultSuccess);
        }];
        return;
    }
    
    UIViewController *viewController = [self viewControllerForProps:props];
    if(!viewController){
        if(self.openURLWhileSchemeNotSupport && ![self isSupportScheme:components.scheme]){
            [GKAppUtils openCompatURL:components.URL];
        }
        return;
    }
    
    UIViewController *parentViewControlelr = self.gkCurrentViewController;
    if(props.isPresent){
        if(props.style == GKRouteStylePresent){
            viewController = viewController.gkCreateWithNavigationController;
        }
        [parentViewControlelr.gkTopestPresentedViewController presentViewController:viewController animated:YES completion:^{
            !props.completion ?: props.completion(GKRouteResultSuccess);
        }];
    }else{
        
        GKBaseNavigationController *nav = (GKBaseNavigationController*)parentViewControlelr.navigationController;
        if([parentViewControlelr isKindOfClass:[UINavigationController class]]){
            nav = (GKBaseNavigationController*)parentViewControlelr;
        }
        
        if(props.completion != nil && [nav isKindOfClass:GKBaseNavigationController.class]){
            nav.transitionCompletion = ^{
                props.completion(GKRouteResultSuccess);
            };
        }
        if(nav){
            NSArray *toReplacedViewControlelrs = nil;
            switch (props.style) {
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
- (void)cannotFoundWithProps:(GKRouteProps*) props
{
    NSString *URLString = props.URLString ? props.URLString : props.path;
#ifdef DEBUG
    NSLog(@"Can not found viewControlelr for %@", URLString);
#endif
    !self.failureHandler ?: self.failureHandler(URLString, props.extras);
}

///判断scheme是否支持
- (BOOL)isSupportScheme:(NSString*) scheme
{
    scheme = [scheme stringByAppendingString:@"://"];
    return [scheme isEqualToString:self.appScheme] || [scheme isEqualToString:@"http://"] || [scheme isEqualToString:@"https://"];
}

// MARK: - Property

- (void)setPropertyForViewController:(UIViewController*) vc data:(NSDictionary*) data
{
    [self setPropertyForViewController:vc data:data clazz:vc.class];
}

- (void)setPropertyForViewController:(UIViewController*) vc data:(NSDictionary*) data clazz:(Class) clazz
{
    if(clazz == UIViewController.class){
        return;
    }
    
    //获取当前类的所有属性，该方法无法获取父类或者子类的属性
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    for(int i = 0;i < count;i ++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        id value = [data objectForKey:name];
        if(value){
            //类型地址 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
            NSString *attr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            
            NSArray *attrs = [attr componentsSeparatedByString:@","];
            
            //判断是否是只读属性
            if(attrs.count > 0 && ![attrs containsObject:@"R"]){
                if([attr containsString:@"NSString"]){
                    [vc setValue:[data gkStringForKey:name] forKey:name];
                }else{
                    [vc setValue:value forKey:name];
                }
            }
        }
    }
    
    //递归获取父类的属性
    [self setPropertyForViewController:vc data:data clazz:[clazz superclass]];
}


@end
