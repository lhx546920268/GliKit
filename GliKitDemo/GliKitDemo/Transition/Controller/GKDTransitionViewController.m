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
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.partialContentSize = CGSizeMake(UIScreen.gkScreenWidth, 400);
    [nav partialPresentFromBottom];
}


@end
