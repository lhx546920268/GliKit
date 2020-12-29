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


@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UITableView appearance] setSeparatorColor:UIColor.gkSeparatorColor];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = GKDRootViewController.new.gkCreateWithNavigationController;
    [self.window makeKeyAndVisible];
    
    [SDImageCodersManager.sharedManager addCoder:SDImageWebPCoder.sharedCoder];
    [SDImageCodersManager.sharedManager addCoder:SDImageSVGCoder.sharedCoder];
    
    dispatch_queue_t queue = dispatch_queue_create("xx", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        for(int i = 0;i < 1000;i ++){
            NSString *time = [NSDate gkCurrentTimeWithFormat:GKDateFormatYMd];
            if(time.length != 10){
                NSLog(@"10 diff %@", time);
            }
        }
    });
    
    dispatch_async(queue, ^{
        for(int i = 0;i < 1000;i ++){
            NSString *time = [NSDate gkCurrentTimeWithFormat:GKDateFormatYMdHm];
            if(time.length != 16){
                NSLog(@"16 diff %@", time);
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
