//
//  GKCollectionViewConfig.m
//  GliKit
//
//  Created by 罗海雄 on 2021/2/23.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKCollectionViewConfig.h"

@implementation GKCollectionViewConfig

@dynamic viewController;

- (UICollectionView *)collectionView
{
    return self.viewController.collectionView;
}

- (void)registerNib:(Class)clazz
{
    [self.viewController registerNib:clazz];
}

- (void)registerClass:(Class) clazz
{
    [self.viewController registerClass:clazz];
}

- (void)registerHeaderClass:(Class) clazz
{
    [self.viewController registerHeaderClass:clazz];
}

- (void)registerHeaderNib:(Class) clazz
{
    [self.viewController registerHeaderNib:clazz];
}

- (void)registerFooterClass:(Class) clazz
{
    [self.viewController registerFooterClass:clazz];
}

- (void)registerFooterNib:(Class) clazz
{
    [self.viewController registerFooterNib:clazz];
}

// MARK: - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    //防止挡住滚动条
    if(@available(iOS 11, *)){
        view.layer.zPosition = 0;
    }
}


@end
