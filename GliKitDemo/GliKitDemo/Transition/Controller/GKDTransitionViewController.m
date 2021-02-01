//
//  GKDTransitionViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/5.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDTransitionViewController.h"
#import "GKDRootViewController.h"
#import "GKDRowModel.h"

@interface GKDLabel : UILabel

@end

@implementation GKDLabel

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [super drawLayer:layer inContext:ctx];
    NSLog(@"drawLayer %@", layer);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    NSLog(@"layoutSublayersOfLayer %@", layer);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSLog(@"sizeThatFits");
    return [super sizeThatFits:size];
}

@end

@interface GKDTransitionViewController ()

@property(nonatomic, strong) GKDLabel *label;

@end

@implementation GKDTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view from its nib.
//    myStaticTest = @"xxx";
    GKDLabel *label = [GKDLabel new];
    label.text = @"demo";
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change)]];
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(0);
            make.top.equalTo(200);
    }];
    self.label = label;
}

- (void)change
{
//    self.label.text = @"change";
    NSLog(@"%@", NSStringFromCGRect(self.label.frame));
    self.label.layer.anchorPoint = CGPointMake(0.4, 0.4);
    NSLog(@"%@", NSStringFromCGRect(self.label.frame));
}

- (IBAction)handleFromBottom:(UIButton*)sender
{
//    UIViewController *vc = [UIViewController new];
//    vc.navigationItem.title = sender.currentTitle;
//    vc.view.backgroundColor = UIColor.whiteColor;
//
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn setTitle:@"显示" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
//    [vc.view addSubview:btn];
//
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(0);
//    }];

    
    GKDRootViewController *vc = [GKDRootViewController new];
    vc.navigationItem.title = sender.currentTitle;
    vc.view.backgroundColor = UIColor.whiteColor;
    vc.gkShowBackItem = YES;
    UINavigationController *nav = vc.gkCreateWithNavigationController;
    
    nav.partialPresentProps.contentSize = CGSizeMake(UIScreen.gkWidth, 400);
    nav.partialPresentProps.cornerRadius = 10;
    nav.partialPresentProps.dismissCallback = ^{
        NSLog(@"dialogDismissCompletionHandler");
    };
    [nav partialPresentFromBottom];
}

- (void)handleTap:(UIButton*) sender
{
    GKDRootViewController *vc = [GKDRootViewController new];
    vc.navigationItem.title = sender.currentTitle;
    vc.view.backgroundColor = UIColor.whiteColor;
    vc.gkShowBackItem = YES;
    UINavigationController *nav = vc.gkCreateWithNavigationController;
    if(@available(iOS 13, *)){
        nav.modalPresentationStyle = UIModalPresentationAutomatic;
    }
    
    [self.gkTopestPresentedViewController presentViewController:nav animated:YES completion:nil];
}

@end
