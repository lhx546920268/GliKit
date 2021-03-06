//
//  UICollectionView+GKSkeleton.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/8.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UICollectionView+GKSkeleton.h"
#import "NSObject+GKUtils.h"
#import "UIView+GKSkeleton.h"
#import <objc/runtime.h>
#import "GKSkeletonHelper.h"

@implementation UICollectionView (GKSkeleton)

+ (void)load
{
    [self gkExchangeImplementations:@selector(setDelegate:) prefix:@"gkSkeleton_"];
    [self gkExchangeImplementations:@selector(setDataSource:) prefix:@"gkSkeleton_"];
}

- (void)gkSkeleton_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    if(delegate){
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:didSelectItemAtIndexPath:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:shouldHighlightItemAtIndexPath:) owner:delegate implementer:self];
    }
    
    [self gkSkeleton_setDelegate:delegate];
}

- (void)gkSkeleton_setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    if(dataSource){
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:cellForItemAtIndexPath:) owner:dataSource implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:) owner:dataSource implementer:self];
    }
    
    [self gkSkeleton_setDataSource:dataSource];
}

- (void)gkShowSkeletonWithDuration:(NSTimeInterval)duration completion:(GKShowSkeletonCompletionHandler)completion
{
    if(self.gkSkeletonStatus == GKSkeletonStatusNone){
        self.gkSkeletonStatus = GKSkeletonStatusShowing;
        [self reloadData];
        
        if(duration > 0 && completion){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), completion);
        }
    }
}

- (void)gkHideSkeletonWithAnimate:(BOOL)animate completion:(void (^)(BOOL))completion
{
    GKSkeletonStatus status = self.gkSkeletonStatus;
    if(status == GKSkeletonStatusShowing){
        self.gkSkeletonStatus = GKSkeletonStatusWillHide;
        self.gkSkeletonHideAnimate = YES;
        [self reloadData];
    }
}

// MARK: - UICollectionViewDelegate

- (BOOL)gkSkeletonAdd_collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.gkSkeletonStatus == GKSkeletonStatusNone;
}

- (BOOL)gkSkeleton_collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.gkSkeletonStatus != GKSkeletonStatusNone){
        return NO;
    }
    return [self gkSkeleton_collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
}

- (UICollectionViewCell*)gkSkeleton_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self gkSkeleton_collectionView:collectionView cellForItemAtIndexPath:indexPath];
    [collectionView gkSkeletonProcessView:cell inContainer:collectionView];
    
    return cell;
}

- (UICollectionReusableView *)gkSkeleton_collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [self gkSkeleton_collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    [collectionView gkSkeletonProcessView:view inContainer:collectionView];
    
    return view;
}

- (void)gkSkeleton_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.gkSkeletonStatus != GKSkeletonStatusNone){
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [self gkSkeleton_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

@end
