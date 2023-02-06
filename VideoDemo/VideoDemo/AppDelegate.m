//
//  AppDelegate.m
//  VideoDemo
//
//  Created by 罗海雄 on 2023/2/2.
//

#import "AppDelegate.h"
#import "CameraViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [CameraViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
