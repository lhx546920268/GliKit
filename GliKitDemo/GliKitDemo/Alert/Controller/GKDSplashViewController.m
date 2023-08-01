//
//  GKDSplashViewController.m
//  GliKitDemo
//
//  Created by xiaozhai on 2023/8/1.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDSplashViewController.h"

@interface GKDSplashViewController ()

@end

@implementation GKDSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dialog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.dialog.backgroundColor = UIColor.redColor;
    UILabel *label = [UILabel new];
    label.text = @"开屏广告 3秒后消失";
    label.textAlignment = NSTextAlignmentCenter;
    [self.dialog addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    dispatch_main_after(3, ^ {
        [self dismissDialogAnimated:YES];
    })
}

- (void)onDialogInitialize
{
    self.dialogPriority = NSNotFound;
    self.dialogShouldUseNewWindow = YES;
    self.dialogDismissAnimate = GKDialogAnimateScale;
}

- (void)show
{
    [self showAsDialog];
}

- (NSTimeInterval)dismissDurationForDialogAnimate:(GKDialogAnimate)animate
{
    return 2;
}

@end
