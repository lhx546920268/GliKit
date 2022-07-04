//
//  GKDCollectionViewSkeletonViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDCollectionViewSkeletonViewController.h"
#import "GKDCollectionViewSkeletonCell.h"
#import "GKDCollectionViewSkeletonHeader.h"
#import <UIView+GKSkeleton.h>

@interface GKDCollectionViewSkeletonViewController ()

@property(nonatomic, strong) NSArray *datas;

///
@property(nonatomic, assign) NSInteger expandIndex;

///
@property(nonatomic, strong) NSArray<UIColor*> *colors;

@end

@implementation GKDCollectionViewSkeletonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colors = @[UIColor.redColor, UIColor.orangeColor, UIColor.greenColor, UIColor.greenColor, UIColor.cyanColor, UIColor.blueColor, UIColor.purpleColor];
    
    self.navigationItem.title = @"UICollectionView";
    self.expandIndex = NSNotFound;
    
    NSMutableArray *datas = [NSMutableArray array];
    for(NSInteger i = 0;i < 30;i ++){
        [datas addObject:@(i)];
    }
    
    self.datas = datas;
    [self initViews];
    
    WeakObj(self)
    [self.collectionView gkShowSkeletonWithDuration:2.0 completion:^{
        [selfWeak.collectionView gkHideSkeletonWithAnimate:YES];
    }];
}

- (void)initViews
{
    CGFloat size = floor((UIScreen.gkWidth - 10 * 4) / 3);
    self.flowLayout.itemSize = CGSizeMake(size, size + 30);
    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.minimumInteritemSpacing = 10;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.flowLayout.headerReferenceSize = CGSizeMake(UIScreen.gkWidth, 40);
    
    [self registerClass:GKDCollectionViewSkeletonCell.class];
    [self registerHeaderNib:GKDCollectionViewSkeletonHeader.class];
    self.collectionView.backgroundColor = UIColor.gkGrayBackgroundColor;
    
    [super initViews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.gkWidth - 20, self.expandIndex == indexPath.item ? 120 : 70);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKDCollectionViewSkeletonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDCollectionViewSkeletonCell.gkNameOfClass forIndexPath:indexPath];
    cell.animatedView.backgroundColor = self.colors[indexPath.item % self.colors.count];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    GKDCollectionViewSkeletonHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GKDCollectionViewSkeletonHeader.gkNameOfClass forIndexPath:indexPath];
    
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    self.expandIndex = indexPath.item;
    [UIView animateWithDuration:3 animations:^{
        [collectionView performBatchUpdates:^{
        } completion:nil];
    }];
}

@end
