//
//  UIView+GKSkeleton.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKSkeleton.h"
#import <objc/runtime.h>
#import "NSObject+GKUtils.h"
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
    [self gkExchangeImplementations:@selector(layoutSubviews) prefix:@"gkSkeleton_"];
}

- (void)gkSkeleton_layoutSubviews
{
    [self gkSkeleton_layoutSubviews];
    
    if([self gkShouldAddSkeletonLayer] && self.gkSkeletonStatus == GKSkeletonStatusWillShow){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gkSkeletonStatus = GKSkeletonStatusShowing;
            
            GKSkeletonLayer *layer = [GKSkeletonLayer layer];
            NSMutableArray *layers = [NSMutableArray array];
            [GKSkeletonHelper createLayers:layers fromView:self rootView:self];
            layer.skeletonSubLayers = layers;
            
            [self.layer addSublayer:layer];
            self.gkSkeletonLayer = layer;
        });
    }
}

- (void)setGkShouldBecomeSkeleton:(BOOL)gkShouldBecomeSkeleton
{
    objc_setAssociatedObject(self, &GKShouldBecomeSkeletonKey, @(gkShouldBecomeSkeleton), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)gkShouldBecomeSkeleton
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldBecomeSkeletonKey);
    if(number){
        return number.boolValue;
    }else{
        return [GKSkeletonHelper shouldBecomeSkeleton:self];
    }
}

- (GKSkeletonStatus)gkSkeletonStatus
{
    return [objc_getAssociatedObject(self, &GKSkeletonStatusKey) integerValue];
}

- (void)setGkSkeletonStatus:(GKSkeletonStatus)gkSkeletonStatus
{
    objc_setAssociatedObject(self, &GKSkeletonStatusKey, @(gkSkeletonStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setGkSkeletonLayer:(GKSkeletonLayer *)gkSkeletonLayer
{
    GKSkeletonLayer *layer = self.gkSkeletonLayer;
    if(layer){
        [layer removeFromSuperlayer];
    }
    if(!gkSkeletonLayer){
        self.userInteractionEnabled = YES;
        self.gkSkeletonStatus = GKSkeletonStatusNone;
        [self setGkSkeletonAnimationHelper:nil];
    }
    objc_setAssociatedObject(self, &GKSkeletonLayerKey, gkSkeletonLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GKSkeletonLayer *)gkSkeletonLayer
{
    return objc_getAssociatedObject(self, &GKSkeletonLayerKey);
}

- (void)gkShowSkeleton
{
    [self gkShowSkeletonWithDuration:0 completion:nil];
}

- (void)gkShowSkeletonWithCompletion:(GKShowSkeletonCompletionHandler) completion
{
    [self gkShowSkeletonWithDuration:0.5 completion:completion];
}

- (void)gkShowSkeletonWithDuration:(NSTimeInterval) duration completion:(GKShowSkeletonCompletionHandler) completion
{
    if(self.gkSkeletonStatus == GKSkeletonStatusNone){
        self.gkSkeletonStatus = GKSkeletonStatusWillShow;
        if([self gkShouldAddSkeletonLayer]){
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

- (void)gkHideSkeletonWithAnimate:(BOOL)animate
{
    [self gkHideSkeletonWithAnimate:animate completion:nil];
}

- (void)gkHideSkeletonWithAnimate:(BOOL) animate completion:(void(^)(BOOL finished)) completion
{
    GKSkeletonStatus status = self.gkSkeletonStatus;
    if(status == GKSkeletonStatusShowing || status == GKSkeletonStatusWillShow){
        self.gkSkeletonStatus = GKSkeletonStatusWillHide;
        
        if(animate){
            
            __weak UIView *weakSelf = self;
            [self.gkSkeletonAnimationHelper executeOpacityAnimationForLayer:self.gkSkeletonLayer completion:^(BOOL finished) {
                weakSelf.gkSkeletonLayer = nil;
                !completion ?: completion(finished);
            }];
            
        }else{
            self.gkSkeletonLayer = nil;
            !completion ?: completion(YES);
        }
    }
}

- (GKSkeletonAnimationHelper*)gkSkeletonAnimationHelper
{
    GKSkeletonAnimationHelper *helper = objc_getAssociatedObject(self, &GKSkeletonAnimationHelperKey);
    if(!helper){
        helper = [GKSkeletonAnimationHelper new];
        [self setGkSkeletonAnimationHelper:helper];
    }
    
    return helper;
}

- (void)setGkSkeletonAnimationHelper:(GKSkeletonAnimationHelper*) helper
{
    objc_setAssociatedObject(self, &GKSkeletonAnimationHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldAddSkeletonLayer
{
    //列表 和 集合视图 使用他们的cell header footer 来生成
    if([self isKindOfClass:UITableView.class] || [self isKindOfClass:UICollectionView.class])
        return NO;
    
    return YES;
}

@end
