//
//  AppDelegate.m
//  GliKitApp
//
//  Created by 罗海雄 on 2019/11/27.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "AppDelegate.h"
#import "GKDRootViewController.h"
#import <GKBaseNavigationController.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
     [[UITableView appearance] setSeparatorColor:UIColor.gkSeparatorColor];
       
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[GKBaseNavigationController alloc] initWithRootViewController:GKDRootViewController.new];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
