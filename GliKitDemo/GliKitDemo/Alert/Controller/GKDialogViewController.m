//
//  GKDialogViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2020/4/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKDialogViewController.h"
#import <GKContainer.h>

@interface GKDialogViewController ()

@end

@implementation GKDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(dismissDialog) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"广告弹窗" forState:UIControlStateNormal];
    [self.dialog addSubview:btn];
    self.dialog.layer.cornerRadius = 10;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
    }];
    
    [self.dialog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(240, 100));
    }];
}

- (void)onDialogInitialize
{
    self.dialogShouldUseNewWindow = YES;
    self.dialogShowAnimate = GKDialogAnimateScale;
    self.dialogDismissAnimate = GKDialogAnimateScale;
}

@end
