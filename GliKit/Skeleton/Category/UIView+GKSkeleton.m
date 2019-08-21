//
//  UIView+GKSkeleton.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKSkeleton.h"
#import <objc/runtime.h>
#import <NSObject+Utils.h>
#import "GKSkeletonHelper.h"
#import "GKSkeletonLayer.h"
#import "GKSkeletonAnimationHelper.h"

static char GKShouldBecomeSkeletonKey;
static char GKSkeletonLayerKey;
static char GKSkeletonStatusKey;
static char GKSkeletonAnimationHelperKey;

@implementation UIView (GKSkeleton)

+ (void)load
{
    [self gk_exchangeImplementations:@selector(layoutSubviews) prefix:@"gk_skeleton_"];
}

- (void)gk_skeleton_layoutSubviews
{
    [self gk_skeleton_layoutSubviews];
    
    if([self shouldAddSkeletonLayer] && self.gk_skeletonStatus == GKSkeletonStatusWillShow){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gk_skeletonStatus = GKSkeletonStatusShowing;
            
            GKSkeletonLayer *layer = [GKSkeletonLayer layer];
            NSMutableArray *layers = [NSMutableArray array];
            [GKSkeletonHelper createLayers:layers fromView:self rootView:self];
            layer.skeletonSubLayers = layers;
            
            [self.layer addSublayer:layer];
            self.gk_skeletonLayer = layer;
        });
    }
}

- (void)setGk_shouldBecomeSkeleton:(BOOL)gk_shouldBecomeSkeleton
{
    objc_setAssociatedObject(self, &GKShouldBecomeSkeletonKey, @(GKShouldBecomeSkeletonKey), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)gk_shouldBecomeSkeleton
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldBecomeSkeletonKey);
    if(number){
        return number.boolValue;
    }else{
        return [GKSkeletonHelper shouldBecomeSkeleton:self];
    }
}

- (GKSkeletonStatus)gk_skeletonStatus
{
    return [objc_getAssociatedObject(self, &GKSkeletonStatusKey) integerValue];
}

- (void)setGk_skeletonStatus:(GKSkeletonStatus)gk_skeletonStatus
{
    objc_setAssociatedObject(self, &GKSkeletonStatusKey, @(gk_skeletonStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setGk_skeletonLayer:(GKSkeletonLayer *)gk_skeletonLayer
{
    GKSkeletonLayer *layer = self.gk_skeletonLayer;
    if(layer){
        [layer removeFromSuperlayer];
    }
    if(!gk_skeletonLayer){
        self.userInteractionEnabled = YES;
        self.gk_skeletonStatus = GKSkeletonStatusNone;
        [self setGk_skeletonAnimationHelper:nil];
    }
    objc_setAssociatedObject(self, &GKSkeletonLayerKey, gk_skeletonLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GKSkeletonLayer *)gk_skeletonLayer
{
    return objc_getAssociatedObject(self, &GKSkeletonLayerKey);
}

- (void)gk_showSkeleton
{
    [self gk_showSkeletonWithDuration:0 completion:nil];
}

- (void)gk_showSkeletonWithCompletion:(GKShowSkeletonCompletionHandler) completion
{
    [self gk_showSkeletonWithDuration:0.5 completion:completion];
}

- (void)gk_showSkeletonWithDuration:(NSTimeInterval) duration completion:(GKShowSkeletonCompletionHandler) completion
{
    if(self.gk_skeletonStatus == GKSkeletonStatusNone){
        self.gk_skeletonStatus = GKSkeletonStatusWillShow;
        if([self shouldAddSkeletonLayer]){
            self.userInteractionEnabled = NO;
            [self setNeedsLayout];
        }
        
        if(duration > 0 && completion){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }
}

- (void)gk_hideSkeletonWithAnimate:(BOOL)animate
{
    [self gk_hideSkeletonWithAnimate:animate completion:nil];
}

- (void)gk_hideSkeletonWithAnimate:(BOOL) animate completion:(void(^)(BOOL finished)) completion
{
    GKSkeletonStatus status = self.gk_skeletonStatus;
    if(status == GKSkeletonStatusShowing || status == GKSkeletonStatusWillShow){
        self.gk_skeletonStatus = GKSkeletonStatusWillHide;
        
        if(animate){
            
            __weak UIView *weakSelf = self;
            [self.gk_skeletonAnimationHelper executeOpacityAnimationForLayer:self.gk_skeletonLayer completion:^(BOOL finished) {
                weakSelf.gk_skeletonLayer = nil;
                !completion ?: completion(finished);
            }];
            
        }else{
            self.gk_skeletonLayer = nil;
            !completion ?: completion(YES);
        }
    }
}

- (GKSkeletonAnimationHelper*)gk_skeletonAnimationHelper
{
    GKSkeletonAnimationHelper *helper = objc_getAssociatedObject(self, &GKSkeletonAnimationHelperKey);
    if(!helper){
        helper = [GKSkeletonAnimationHelper new];
        [self setGk_skeletonAnimationHelper:helper];
    }
    
    return helper;
}

- (void)setGk_skeletonAnimationHelper:(GKSkeletonAnimationHelper*) helper
{
    objc_setAssociatedObject(self, &GKSkeletonAnimationHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldAddSkeletonLayer
{
    //列表 和 集合视图 使用他们的cell header footer 来生成
    if([self isKindOfClass:UITableView.class] || [self isKindOfClass:UICollectionView.class])
        return NO;
    
    return YES;
}

@end
