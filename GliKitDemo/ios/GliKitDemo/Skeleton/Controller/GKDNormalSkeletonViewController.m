//
//  GKDNormalSkeletonViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNormalSkeletonViewController.h"
#import <UIView+GKSkeleton.h>

@interface GKDNormalSkeletonViewController ()

@end

@implementation GKDNormalSkeletonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"普通骨架";
    self.imageView.layer.cornerRadius = 50;
    self.imageView.layer.masksToBounds = YES;
    
    WeakObj(self)
    [self.view gkShowSkeletonWithDuration:0.5 completion:^{
        [selfWeak hideSkeleton];
    }];
}


- (void)hideSkeleton
{
    [self.view gkHideSkeletonWithAnimate:YES completion:nil];
}

@end