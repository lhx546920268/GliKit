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

@interface AppDelegate ()



@end

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
    
    int a = ({
             NSString *c = @"1";
        c.intValue;
    });
    
    NSTimeInterval time = 0;
    for(NSDictionary *dic in GKDLoadMonitor.executeTimes){
        time += [dic[@"time"] doubleValue];
    }
    
    NSLog(@"timeIntervalSince1970 %f", NSDate.date.timeIntervalSinceReferenceDate);
    NSLog(@"CFAbsoluteTimeGetCurrent %f", CFAbsoluteTimeGetCurrent());
    NSLog(@"mach_absolute_time %lld", mach_absolute_time());
    NSLog(@"mach_approximate_time %lld", mach_approximate_time());
    NSLog(@"mach_continuous_time %lld", mach_continuous_time());
    NSLog(@"mach_continuous_approximate_time %lld", mach_continuous_approximate_time());
    
    NSLog(@"load ms %f", time * 1000);
    
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
