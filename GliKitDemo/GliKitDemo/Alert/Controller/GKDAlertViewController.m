//
//  GKDAlertViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/12/10.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDAlertViewController.h"
#import <GKAlertUtils.h>

@interface GKDAlertViewController ()

@end

@implementation GKDAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.label.highlightedTextColor = [UIColor redColor];
    self.label.enabled = NO;
    
    [self.imageView gkSetTintColor:UIColor.grayColor forState:UIControlStateHighlighted];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView)]];
    
    [self.label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapLabel)]];
}

- (void)handleTapImageView
{
    
}

- (void)handleTapLabel
{
    
}

- (IBAction)handleAlert:(id)sender
{
    WeakObj(self)
    [GKAlertUtils showAlertWithTitle:@"这是一个Alert标题" message:@"这是一个Alert副标题" icon:[UIImage imageNamed:@"swift"] buttonTitles:@[@"取消", @"确定"] destructiveButtonIndex:1 handler:^(NSInteger buttonIndex, NSString * _Nonnull title) {
       
        [selfWeak gkShowSuccessWithText:[NSString stringWithFormat:@"点击%@了", title]];
    }];
    
    [self handleActionSheet:nil];
}

- (IBAction)handleActionSheet:(id)sender
{
    WeakObj(self)
    [GKAlertUtils showActionSheetWithTitle:@"这是一个Alert标题" message:@"这是一个Alert副标题" icon:[UIImage imageNamed:@"swift"] buttonTitles:@[@"取消", @"确定"] cancelButtonTitle:@"取消" handler:^(NSInteger buttonIndex, NSString * _Nonnull title) {
       
        [selfWeak gkShowSuccessWithText:[NSString stringWithFormat:@"点击%@了", title]];
    }];
}

@end
