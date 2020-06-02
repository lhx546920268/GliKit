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
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [self.container addSubview:btn];
    self.container.layer.cornerRadius = 10;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
    }];
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
        make.size.equalTo(CGSizeMake(240, 100));
    }];
}



@end
