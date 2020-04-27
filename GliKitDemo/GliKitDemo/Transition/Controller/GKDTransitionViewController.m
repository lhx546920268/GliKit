//
//  GKDTransitionViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/5.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDTransitionViewController.h"

@interface GKDTransitionViewController ()

@end

@implementation GKDTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)handleFromBottom:(UIButton*)sender
{
    UIViewController *vc = [UIViewController new];
    vc.navigationItem.title = sender.currentTitle;
    vc.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"显示" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.partialPresentProps.contentSize = CGSizeMake(UIScreen.gkWidth, 400);
    nav.partialPresentProps.cornerRadius = 10;
    [nav partialPresentFromBottom];
}

- (void)handleTap:(UIButton*) sender
{
    UIViewController *vc = [UIViewController new];
    vc.navigationItem.title = sender.currentTitle;
    vc.view.backgroundColor = UIColor.whiteColor;
    vc.gkShowBackItem = YES;
    
    [self.gkTopestPresentedViewController presentViewController:vc.gkCreateWithNavigationController animated:YES completion:nil];
}

@end
