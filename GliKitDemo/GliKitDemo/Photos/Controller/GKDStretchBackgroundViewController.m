//
//  GKDStretchBackgroundViewController.m
//  GliKitDemo
//
//  Created by zhai on 2023/5/19.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDStretchBackgroundViewController.h"
#import <GKContainer.h>
#import <GKBannerView.h>

@interface GKDStretchBackgroundCell : UICollectionViewCell

@end

@implementation GKDStretchBackgroundCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end

@interface GKDStretchBackgroundViewController ()<UIScrollViewDelegate, GKBannerViewDelegate>

///
@property(nonatomic, strong) UIImageView *backgroundImageView;

///
@property(nonatomic, strong) GKBannerView *bannerView;

@property(nonatomic, strong) NSArray<UIColor*> *colors;

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
    
    self.colors = @[UIColor.redColor, UIColor.orangeColor, UIColor.blueColor];
    
    self.bannerView = [[GKBannerView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.gkWidth, 200)];
    self.bannerView.delegate = self;
    self.bannerView.enableScrollCircularly = YES;
    [self.bannerView registerClass:GKDStretchBackgroundCell.class];
    self.bannerView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    [scrollView addSubview:self.bannerView];
    
    
//    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"512x384" ofType:@"webp"]]];
//    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.backgroundImageView.clipsToBounds = YES;
//    [self.scrollView addSubview:self.backgroundImageView];
//
//    self.backgroundImageView.frame = CGRectMake(0, 0, UIScreen.gkWidth, 200);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    CGFloat y = MIN(scrollView.contentOffset.y, 0);
    CGFloat height = fabs(y) + 200;
    CGFloat width = UIScreen.gkWidth * height / 200;
    
    if (width > UIScreen.gkWidth) {
        CGFloat scale = width / UIScreen.gkWidth;
        NSLog(@"%f", scale);
        self.bannerView.transform = CGAffineTransformMakeScale(scale, scale);
    } else {
        self.bannerView.transform = CGAffineTransformIdentity;
    }
}

- (NSInteger)numberOfCellsInBannerView:(GKBannerView *)bannerView
{
    return self.colors.count;
}

- (UICollectionViewCell *)bannerView:(GKBannerView *)bannerView cellForIndexPath:(NSIndexPath *)indexPath atIndex:(NSInteger)index
{
    GKDStretchBackgroundCell *cell = [bannerView dequeueReusableCellWithClass:GKDStretchBackgroundCell.class forIndexPath:indexPath];
    cell.contentView.backgroundColor = self.colors[index];
    return cell;
}

@end
