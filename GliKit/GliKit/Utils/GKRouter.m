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

@interface GKRouter ()

//已注册的类
@property(nonatomic, strong) NSMutableDictionary<NSString*, Class> *registeredClasses;

@end

@implementation GKRouter

+ (GKRouter *)sharedRouter
{
    static dispatch_once_t onceToken;
    static GKRouter *sharedRouter = nil;
    
    dispatch_once(&onceToken, ^{
        
        sharedRouter = [GKRouter new];
    });
    
    return sharedRouter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appScheme = @"app://";
        self.registeredClasses = [NSMutableDictionary dictionary];
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

- (void)registerName:(NSString *)name forClass:(Class)cls
{
    if(name && cls){
        self.registeredClasses[name] = cls;
    }else{
        @throw [NSException exceptionWithName:@"GKRouterNullException" reason:@"name and class can not be nil" userInfo:nil];
    }
}

- (void)unregisterName:(NSString *)name
{
    if(name){
        [self.registeredClasses removeObjectForKey:name];
    }
}

// MARK: - Push

- (void)pushApp:(NSString *)URLString
{
    [self pushApp:URLString params:nil];
}

- (void)pushApp:(NSString*) URLString params:(NSDictionary*) params
{
    [self push:[self.appScheme stringByAppendingString:URLString] params:params];
}

- (void)push:(NSString *)URLString
{
    [self push:URLString params:nil];
}

- (void)push:(NSString *)URLString params:(NSDictionary *)params
{
    [self open:URLString params:params isPresent:NO withNavigationBar:NO completion:nil];
}

// MARK: - Replace

- (void)replace:(NSString *)URLString
{
    [self replace:URLString params:nil];
}

- (void)replace:(NSString *)URLString params:(NSDictionary *)params
{
    NSArray *viewControllers = nil;
    UIViewController *viewController = self.gkCurrentViewController;
    if(viewController){
        viewControllers = @[viewController];
    }
    [self replace:URLString params:params toReplacedViewControlelrs:viewControllers];
}

- (void)replace:(NSString *)URLString params:(NSDictionary *)params toReplacedViewControlelrs:(NSArray<UIViewController *> *)toReplacedViewControlelrs
{
    [self open:URLString params:params isPresent:NO withNavigationBar:NO toReplacedViewControlelrs:toReplacedViewControlelrs completion:nil];
}

- (void)replaceApp:(NSString *)URLString
{
    [self replaceApp:URLString params:nil];
}

- (void)replaceApp:(NSString *)URLString params:(NSDictionary *)params
{
    [self replace:[self.appScheme stringByAppendingString:URLString] params:params];
}

- (void)replaceApp:(NSString *)URLString params:(NSDictionary *)params toReplacedViewControlelrs:(NSArray<UIViewController *> *)toReplacedViewControlelrs
{
    [self replace:[self.appScheme stringByAppendingString:URLString] params:params toReplacedViewControlelrs:toReplacedViewControlelrs];
}

// MARK: - Present

- (void)presentApp:(NSString *)URLString
{
    [self presentApp:URLString params:nil];
}

- (void)presentApp:(NSString *)URLString params:(NSDictionary *)params
{
    [self presentApp:URLString params:params completion:nil];
}

- (void)presentApp:(NSString *)URLString params:(NSDictionary *)params completion:(GKRounterOpenCompletion)completion
{
    [self presentApp:URLString params:params withNavigationBar:YES completion:completion];
}

- (void)presentApp:(NSString *)URLString params:(NSDictionary *)params withNavigationBar:(BOOL)withNavigationBar completion:(GKRounterOpenCompletion)completion
{
    [self present:[self.appScheme stringByAppendingString:URLString] params:params withNavigationBar:withNavigationBar completion:completion];
}

- (void)present:(NSString *)URLString
{
    [self present:URLString params:nil];
}

- (void)present:(NSString *)URLString params:(NSDictionary *)params
{
    [self present:URLString params:params completion:nil];
}

- (void)present:(NSString *)URLString params:(NSDictionary *)params completion:(GKRounterOpenCompletion)completion
{
    [self present:URLString params:params withNavigationBar:YES completion:completion];
}

- (void)present:(NSString *)URLString params:(NSDictionary *)params withNavigationBar:(BOOL)withNavigationBar completion:(GKRounterOpenCompletion)completion
{
    [self open:URLString params:params isPresent:YES withNavigationBar:withNavigationBar completion:completion];
}

// MARK: - ViewController

- (UIViewController *)get:(NSString *)URLString params:(NSMutableDictionary *)params
{
    NSURLComponents *components = [NSURLComponents componentsWithString:URLString];
    return [self viewControllerForComponents:components params:params];
}

- (UIViewController *)viewControllerForComponents:(NSURLComponents *) components params:(NSMutableDictionary *)params
{
    UIViewController *viewController = nil;
    if(components){
        NSString *scheme = [components.scheme stringByAppendingString:@"://"];
        if([scheme isEqualToString:self.appScheme]){
            NSString *clsName = components.host;
            if(![NSString isEmpty:clsName]){
                Class cls = self.registeredClasses[clsName];
                if(!cls){
                    cls = NSClassFromString(clsName);
                }
                
                viewController = [cls new];
                if(![viewController isKindOfClass:UIViewController.class]){
                    viewController = nil;
                }
            }
        }else if([scheme isEqualToString:@"http://"] || [scheme isEqualToString:@"https://"]){
            GKBaseWebViewController *web = [[GKBaseWebViewController alloc] initWithURLString:components.string];
            [web setRouterParams:params];
            viewController = web;
        }
    }
    
    if(!viewController){
        [self cannotFound:components.string];
    }else if(![viewController isKindOfClass:GKBaseWebViewController.class]){
        for(NSURLQueryItem *item in components.queryItems){
            if(![NSString isEmpty:item.name] && ![NSString isEmpty:item.value]){
                params[item.name] = item.value;
            }
        }
        [self setPropertyForViewController:viewController data:params];
        if([viewController isKindOfClass:GKBaseViewController.class]){
            GKBaseViewController *baseViewController = (GKBaseViewController*)viewController;
            [baseViewController setRouterParams:params];
        }
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
            if([vc.gkNameOfClass isEqualToString:name]){
                return i;
            }else if ([vc isKindOfClass:UINavigationController.class]){
                UINavigationController *nav = (UINavigationController*)vc;
                if([nav.viewControllers.firstObject.gkNameOfClass isEqualToString:name]){
                    return i;
                }
            }
        }
    }
    
    return NSNotFound;
}

- (void)open:(NSString *)URLString params:(NSDictionary *)params isPresent:(BOOL) isPresent withNavigationBar:(BOOL) withNavigationBar completion:(void (^)(void))completion
{
    [self open:URLString params:params isPresent:isPresent withNavigationBar:withNavigationBar toReplacedViewControlelrs:nil completion:completion];
}

///打开一个页面
- (void)open:(NSString *)URLString params:(NSDictionary *)params isPresent:(BOOL) isPresent withNavigationBar:(BOOL) withNavigationBar toReplacedViewControlelrs:(NSArray<UIViewController*> *) toReplacedViewControlelrs completion:(void (^)(void))completion
{
    NSURLComponents *components = [NSURLComponents componentsWithString:URLString];
    if(!components){
        [self cannotFound:components.string];
        return;
    }
    
    NSInteger tabBarIndex = [self tabBarIndexForName:components.host];
    if(tabBarIndex != NSNotFound){
        [self.gkCurrentViewController gkBackAnimated:NO completion:^{
            UITabBarController *controller = (UITabBarController*)UIApplication.sharedApplication.delegate.window.rootViewController;
            controller.selectedIndex = tabBarIndex;
        }];
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    UIViewController *viewController = [self viewControllerForComponents:components params:dic];
    if(!viewController){
        if(self.openURLWhileSchemeNotSupport && ![self isSupportScheme:components.scheme]){
            [UIApplication.sharedApplication openURL:components.URL];
        }
        return;
    }
    
    if(withNavigationBar){
        viewController = viewController.gkCreateWithNavigationController;
    }
    if(isPresent){
        [self.gkCurrentViewController.gkTopestPresentedViewController presentViewController:viewController animated:YES completion:completion];
    }else{
        [self.class gkPushViewController:viewController toReplacedViewControlelrs:toReplacedViewControlelrs];
    }
}
       

///找不到对应的页面
- (void)cannotFound:(NSString*) URLString
{
#ifdef DEBUG
    NSLog(@"Can not found viewControlelr for %@", URLString);
#endif
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
