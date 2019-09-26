//
//  GKDCollectionEmptyViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDCollectionEmptyViewController.h"

@interface GKDCollectionEmptyViewController ()

@end

@implementation GKDCollectionEmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
    self.collectionView.gkShouldShowEmptyView = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
