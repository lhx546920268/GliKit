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

@end

@implementation GKDCollectionViewSkeletonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"UICollectionView";
    
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
    CGFloat size = floor((UIScreen.gkScreenWidth - 10 * 4) / 3);
    self.flowLayout.itemSize = CGSizeMake(size, size + 30);
    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.minimumInteritemSpacing = 10;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.flowLayout.headerReferenceSize = CGSizeMake(UIScreen.gkScreenWidth, 40);
    
    [self registerClass:GKDCollectionViewSkeletonCell.class];
    [self registerHeaderNib:GKDCollectionViewSkeletonHeader.class];
    self.collectionView.backgroundColor = UIColor.gkGrayBackgroundColor;
    
    [super initViews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKDCollectionViewSkeletonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDCollectionViewSkeletonCell.gkNameOfClass forIndexPath:indexPath];
    
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
}

@end
