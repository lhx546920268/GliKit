//
//  AppDelegate.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "AppDelegate.h"
#import "GKDTabBarController.h"
#import <GKBaseNavigationController.h>
#import <GKHttpTask.h>
#import <SDImageWebPCoder.h>
#import <SDImageCodersManager.h>
#import <SDWebImageSVGCoder.h>
#import "GKDRootViewController.h"
#import <NSDate+GKUtils.h>
#import "GKDLoadMonitor.h"
#import <mach/mach.h>
#import <objc/runtime.h>

@interface NSObject (Text)



@end

@implementation NSObject(Text)



@end

@interface TestOne : NSObject

@property(nonatomic, copy) NSString *aa;

@end

@implementation TestOne

+ (BOOL)resolveClassMethod:(SEL)sel
{
    NSLog(@"resolveClassMethod %@", NSStringFromSelector(sel));
    return [super resolveClassMethod:sel];
}


+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSLog(@"resolveInstanceMethod %@", NSStringFromSelector(sel));
    return [super resolveInstanceMethod:sel];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"methodSignatureForSelector %@", NSStringFromSelector(aSelector));
    return [super methodSignatureForSelector:aSelector];;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    id target = [super forwardingTargetForSelector:aSelector];
    NSLog(@"forwardingTargetForSelector %@, %@", NSStringFromSelector(aSelector), target);

    return target;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"forwardInvocation %@", anInvocation);
    [super forwardInvocation:anInvocation];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    NSLog(@"doesNotRecognizeSelector %@", NSStringFromSelector(aSelector));
    [super doesNotRecognizeSelector:aSelector];
}

@end

@interface AppDelegate ()



@end

void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    
    switch (activity) {
        case kCFRunLoopEntry :
            NSLog(@"kCFRunLoopEntry");
            break;
        case kCFRunLoopBeforeTimers :
            NSLog(@"kCFRunLoopBeforeTimers");
            break;
        case kCFRunLoopBeforeSources :
            NSLog(@"kCFRunLoopBeforeSources");
            break;
        case kCFRunLoopBeforeWaiting :
            NSLog(@"kCFRunLoopBeforeWaiting");
            break;
        case kCFRunLoopAfterWaiting :
            NSLog(@"kCFRunLoopAfterWaiting");
            break;
        case kCFRunLoopExit :
            NSLog(@"kCFRunLoopExit");
            break;
        default:
            break;
    }
}

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"AppDelegate init");
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"did finish");
    [[UITableView appearance] setSeparatorColor:UIColor.gkSeparatorColor];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = GKDRootViewController.new.gkCreateWithNavigationController;
    [self.window makeKeyAndVisible];
    
    [SDImageCodersManager.sharedManager addCoder:SDImageWebPCoder.sharedCoder];
    [SDImageCodersManager.sharedManager addCoder:SDImageSVGCoder.sharedCoder];

    [UIView animateWithDuration:0 delay:0 options:0 animations:^{
            
        } completion:^(BOOL finished) {
            
        }];
//    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(NULL, kCFRunLoopAllActivities, YES, 0, runLoopObserverCallBack, NULL);
//    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
//    CFRelease(observer);
    
//    int a = ({
//             NSString *c = @"1";
//        c.intValue;
//    });
//
//    NSTimeInterval time = 0;
//    for(NSDictionary *dic in GKDLoadMonitor.executeTimes){
//        time += [dic[@"time"] doubleValue];
//    }
//
//    NSLog(@"timeIntervalSince1970 %f", NSDate.date.timeIntervalSinceReferenceDate);
//    NSLog(@"CFAbsoluteTimeGetCurrent %f", CFAbsoluteTimeGetCurrent());
//    NSLog(@"mach_absolute_time %lld", mach_absolute_time());
//    NSLog(@"mach_approximate_time %lld", mach_approximate_time());
//    NSLog(@"mach_continuous_time %lld", mach_continuous_time());
//    NSLog(@"mach_continuous_approximate_time %lld", mach_continuous_approximate_time());
//
//    NSLog(@"load ms %f", time * 1000);
    
//    NSNumber *number = @NO;
//    if(number){
//        NSLog(@"number is no");
//    }
  
    
//    Class cls = [TestOne class];
//    void *obj = &cls;
//    TestOne *one = (__bridge_transfer id)obj;
//    one.aa = @"is aa";
//    [one print];
//
//    Class cls1 = [TestOne class];
//    void *obj1 = &cls1;
//
//    TestOne *one1 = CFBridgingRelease(obj1);
//    [one1 print];
    
    dispatch_queue_t queue = dispatch_queue_create("xx", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10000; i ++) {
            NSString *time = [NSDate gkCurrentTimeWithFormat:GKDateFormatYMd];
            if (time.length != 10) {
                NSLog(@"10 diff");
            }
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10000; i ++) {
            NSString *time = [NSDate gkCurrentTimeWithFormat:GKDateFormatYMdHm];
            if (time.length != 16) {
                NSLog(@"16 diff");
            }
        }
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    
}

@end
