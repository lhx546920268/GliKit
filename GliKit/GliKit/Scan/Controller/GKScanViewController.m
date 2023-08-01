//
//  GKScanViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2020/4/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKScanViewController.h"
#import "GKScanBackgroundView.h"
#import "GKBaseDefines.h"

@interface GKScanViewController ()


@end

@implementation GKScanViewController

- (CGRect)previewFrame
{
    return self.scanBackgroundView.frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //添加二维码扫描背景
    _scanBackgroundView = [GKScanBackgroundView new];
    WeakObj(self)
    _scanBackgroundView.scanBoxRectDidChange = ^(CGRect rect) {
        [selfWeak setRectOfInterest];
    };
    self.contentView = _scanBackgroundView;
}

- (void)startScan
{
    [super startScan];
    [_scanBackgroundView startAnimating];
}

- (void)stopScan
{
    [super stopScan];
    [_scanBackgroundView stopAnimating];
}

@end
