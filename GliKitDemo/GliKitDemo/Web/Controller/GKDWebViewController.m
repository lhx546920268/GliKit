//
//  GKDWebViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/11/4.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDWebViewController.h"
#import <GliKitDemo-Swift.h>

NSString *const abc = @"";
const NSString  *bcd = @"xx";

@interface GKDWebViewController ()

@end


@implementation GKDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    bcd = @"";
    self.URL = [NSURL URLWithString:@"https://devtest.zegobird.com:11111/public/pages/conpun/index.html"];//[NSBundle.mainBundle URLForResource:@"test" withExtension:@"html"];
    [self loadWebContent];
}

- (void)test:(const int *) a
{
    
}

@end
