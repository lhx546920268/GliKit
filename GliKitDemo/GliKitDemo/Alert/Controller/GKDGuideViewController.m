//
//  GKDGuideViewController.m
//  GliKitDemo
//
//  Created by xiaozhai on 2023/8/1.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDGuideViewController.h"

@interface GKDGuideViewController ()

@end

@implementation GKDGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(dismissDialog) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"引导" forState:UIControlStateNormal];
    [self.dialog addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
    }];
    
    [self.dialog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.dialog.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
}

- (void)onDialogInitialize
{
    self.dialogShouldUseNewWindow = YES;
}

@end
