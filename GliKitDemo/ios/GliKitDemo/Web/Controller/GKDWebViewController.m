//
//  GKDWebViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/11/4.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDWebViewController.h"

@interface GKDWebViewController ()

@end

@implementation GKDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.URL = [NSURL URLWithString:@"https://www.baidu.com"];
    [self loadWebContent];
}

- (NSString *)customUserAgent
{
    return @"GliKitDemo.iPhone";
}

@end
