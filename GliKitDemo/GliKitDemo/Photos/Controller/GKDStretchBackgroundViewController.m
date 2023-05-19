//
//  GKDStretchBackgroundViewController.m
//  GliKitDemo
//
//  Created by zhai on 2023/5/19.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDStretchBackgroundViewController.h"
#import <GKContainer.h>
#import <GKNavigationBar.h>

@interface GKDStretchBackgroundViewController ()<UIScrollViewDelegate>

///
@property(nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation GKDStretchBackgroundViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"/photos/stretch" forHandler:^UIViewController * _Nullable(GKRouteConfig * _Nonnull config) {
        return [GKDStretchBackgroundViewController new];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.container.safeLayoutGuide = GKSafeLayoutGuideNone;
    self.navigatonBar.backgroundColor = UIColor.clearColor;
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.delegate = self;
    scrollView.contentSize = UIScreen.gkSize;
    scrollView.alwaysBounceVertical = YES;
    self.scrollView = scrollView;
    self.contentView = scrollView;
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"512x384" ofType:@"webp"]]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.backgroundImageView];
    
    self.backgroundImageView.frame = CGRectMake(0, 0, UIScreen.gkWidth, 200);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    CGFloat y = MIN(scrollView.contentOffset.y, 0);
    CGFloat height = fabs(y) + 200;
    CGFloat width = UIScreen.gkWidth * height / 200;
    CGRect frame = CGRectMake((UIScreen.gkWidth - width) / 2, y, width, height);
    self.backgroundImageView.frame = frame;
}

@end
