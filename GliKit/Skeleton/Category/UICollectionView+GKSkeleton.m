//
//  UICollectionView+GKSkeleton.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/8.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UICollectionView+GKSkeleton.h"
#import <NSObject+Utils.h>
#import "UIView+GKSkeleton.h"
#import <objc/runtime.h>
#import "GKSkeletonHelper.h"

static char GKSkeletonHideAnimateKey;

@implementation UICollectionView (GKSkeleton)

+ (void)load
{
    [self gk_exchangeImplementations:@selector(setDelegate:) prefix:@"gk_skeleton_"];
    [self gk_exchangeImplementations:@selector(setDataSource:) prefix:@"gk_skeleton_"];
}

- (void)gk_skeleton_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    if(delegate){
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:didSelectItemAtIndexPath:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:shouldHighlightItemAtIndexPath:) owner:delegate implementer:self];
    }
    
    [self gk_skeleton_setDelegate:delegate];
}

- (void)gk_skeleton_setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    if(dataSource){
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:cellForItemAtIndexPath:) owner:dataSource implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:) owner:dataSource implementer:self];
    }
    
    [self gk_skeleton_setDataSource:dataSource];
}

- (void)gk_showSkeletonWithDuration:(NSTimeInterval)duration completion:(GKShowSkeletonCompletionHandler)completion
{
    if(self.gk_skeletonStatus == GKSkeletonStatusNone){
        self.gk_skeletonStatus = GKSkeletonStatusShowing;
        [self reloadData];
        
        if(duration > 0 && completion){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }
}

- (void)setGk_skeletonHideAnimate:(BOOL) animate
{
    objc_setAssociatedObject(self, &GKSkeletonHideAnimateKey, @(animate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_skeletonHideAnimate
{
    return [objc_getAssociatedObject(self, &GKSkeletonHideAnimateKey) boolValue];
}

- (void)gk_hideSkeletonWithAnimate:(BOOL)animate completion:(void (^)(BOOL))completion
{
    GKSkeletonStatus status = self.gk_skeletonStatus;
    if(status == GKSkeletonStatusShowing){
        self.gk_skeletonStatus = GKSkeletonStatusWillHide;
        [self setGk_skeletonHideAnimate:animate];
        [self reloadData];
    }
}

//MARK: UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.gk_skeletonStatus == GKSkeletonStatusNone;
}

- (BOOL)gk_skeleton_collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.gk_skeletonStatus != GKSkeletonStatusNone){
        return NO;
    }
    return [self gk_skeleton_collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
}

- (UICollectionViewCell*)gk_skeleton_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self gk_skeleton_collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    GKSkeletonStatus status = collectionView.gk_skeletonStatus;
    switch (status) {
        case GKSkeletonStatusShowing : {
            
            [cell gk_showSkeleton];
        }
            break;
        case GKSkeletonStatusWillHide: {
            
            __weak UICollectionView *weakSelf = collectionView;
            [cell gk_hideSkeletonWithAnimate:collectionView.gk_skeletonHideAnimate completion:^(BOOL finished) {
                if(weakSelf.gk_skeletonStatus == GKSkeletonStatusWillHide){
                    weakSelf.gk_skeletonLayer = nil;
                }
            }];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (UICollectionReusableView *)gk_skeleton_collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [self gk_skeleton_collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    
    GKSkeletonStatus status = collectionView.gk_skeletonStatus;
    switch (status) {
        case GKSkeletonStatusShowing : {
            
            [view gk_showSkeleton];
        }
            break;
        case GKSkeletonStatusWillHide: {
            
            __weak UICollectionView *weakSelf = collectionView;
            [view gk_hideSkeletonWithAnimate:collectionView.gk_skeletonHideAnimate completion:^(BOOL finished) {
                if(weakSelf.gk_skeletonStatus == GKSkeletonStatusWillHide){
                    weakSelf.gk_skeletonLayer = nil;
                }
            }];
        }
            break;
        default:
            break;
    }
    
    return view;
}

- (void)gk_skeleton_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.gk_skeletonStatus != GKSkeletonStatusNone){
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [self gk_skeleton_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

@end
