//
//  GKDNormalSkeletonViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNormalSkeletonViewController.h"
#import <UIView+GKSkeleton.h>

@interface GKDNormalSkeletonViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;

@end

@implementation GKDNormalSkeletonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"普通骨架";
    
    WeakObj(self)
    [self.view gkShowSkeletonWithDuration:0.5 completion:^{
        [selfWeak hideSkeleton];
    }];
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    self.textField3.delegate = self;
    
    [self.imageView gkSetCornerRadius:20 corners:UIRectCornerTopRight rect:self.imageView.frame];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)]];
}


- (void)hideSkeleton
{
    [self.view gkHideSkeletonWithAnimate:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *view = UIScreen.mainScreen.focusedView;
    NSLog(@"%@", view);
}

- (void)handleTap
{
    [self.imageView gkSetCornerRadius:10 corners:UIRectCornerBottomRight rect:self.imageView.frame];
}

@end
