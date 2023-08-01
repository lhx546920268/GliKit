//
//  GKDTabBarController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2020/5/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKDTabBarController.h"
#import "GKDRootViewController.h"
#import "GKDSplashViewController.h"

@interface GKDTabBarController ()

@end

@implementation GKDTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedColor = [UIColor gkColorFromHex:@"0FD7C8"];
    self.items = @[[GKTabBarItem itemWithTitle:@"首页" normalImage:[UIImage imageNamed:@"tab_home_n"] selectedImage:[UIImage imageNamed:@"tab_home_s"] viewController:[GKDRootViewController new].gkCreateWithNavigationController],
                       [GKTabBarItem itemWithTitle:@"我的" normalImage:[UIImage imageNamed:@"tab_me_n"] selectedImage:[UIImage imageNamed:@"tab_me_s"] viewController:[UIViewController new].gkCreateWithNavigationController]];
    
    [[GKDSplashViewController new] show];
}


@end
