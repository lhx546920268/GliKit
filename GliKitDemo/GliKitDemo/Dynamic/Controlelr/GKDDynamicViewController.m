//
//  GKDDynamicViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2022/9/22.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import "GKDDynamicViewController.h"
#import "GKDDynamicBannerCell.h"
#import "GKDDynamicCell.h"

@implementation GKDDynamicCollectionViewFlowLayout


@end

@interface GKDDynamicViewController ()

@end

@implementation GKDDynamicViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"/app/dynimic" forHandler:^UIViewController * _Nullable(GKRouteConfig * _Nonnull config) {
        return [GKDDynamicViewController new];;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews
{
    self.collectionView.backgroundColor = UIColor.gkGrayBackgroundColor;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.minimumInteritemSpacing = 10;
    
    [self registerClass:GKDDynamicCell.class];
    [self registerClass:GKDDynamicBannerCell.class];
    
    [super initViews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        return GKDDynamicBannerCell.gkItemSize;
    } else {
        return GKDDynamicCell.gkItemSize;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        GKDDynamicBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDDynamicBannerCell.gkNameOfClass forIndexPath:indexPath];
        return cell;
    } else {
        GKDDynamicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDDynamicCell.gkNameOfClass forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Item %ld", indexPath.item];
        return cell;
    }
}

@end
