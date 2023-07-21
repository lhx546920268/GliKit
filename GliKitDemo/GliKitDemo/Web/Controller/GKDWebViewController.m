//
//  GKDWebViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/11/4.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDWebViewController.h"
#import <GliKitDemo-Swift.h>


@interface GKDWebViewController ()

@end


@implementation GKDWebViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"app/web" forHandler:^UIViewController * _Nullable(GKRouteConfig * _Nonnull config) {
        return [GKDWebViewController new];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.URL = [NSURL URLWithString:@"https://www.baidu.com"]; //[NSBundle.mainBundle URLForResource:@"test" withExtension:@"html"];
    [self loadWebContent];
}

- (void)test:(const int *) a
{
    
}

@end
