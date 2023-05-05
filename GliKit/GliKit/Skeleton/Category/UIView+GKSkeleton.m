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
static char GKSkeletonHideAnimateKey;

@implementation UIView (GKSkeleton)

+ (void)load
{
    [self gkExchangeImplementations:@selector(layoutSubviews) prefix:@"gkSkeleton_"];
}

- (void)gkSkeleton_layoutSubviews
{
    [self gkSkeleton_layoutSubviews];
    
    if(self.gkSkeletonStatus == GKSkeletonStatusWillShow && self.gkShouldAddSkeletonLayer){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gkSkeletonStatus = GKSkeletonStatusShowing;
            
            GKSkeletonLayer *layer = [GKSkeletonLayer layer];
            NSMutableArray *layers = [NSMutableArray array];
            [GKSkeletonHelper createLayers:layers fromView:self rootView:self];
            layer.skeletonSubLayers = layers;
            layer.frame = self.bounds;
            
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
    if(number != nil){
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

- (BOOL)gkShouldAddSkeletonLayer
{
    //列表 和 集合视图 使用他们的cell header footer 来生成
    if([self isKindOfClass:UITableView.class] || [self isKindOfClass:UICollectionView.class])
        return NO;
    
    return YES;
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), completion);
        }
    }
}

- (void)gkHideSkeletonWithAnimate:(BOOL)animate
{
    [self gkHideSkeletonWithAnimate:animate completion:nil];
}

- (void)gkHideSkeletonWithAnimate:(BOOL) animate completion:(void(^)(void)) completion
{
    GKSkeletonStatus status = self.gkSkeletonStatus;
    if(status == GKSkeletonStatusShowing || status == GKSkeletonStatusWillShow){
        
        if(animate){
            
            self.gkSkeletonStatus = GKSkeletonStatusWillHide;
            __weak UIView *weakSelf = self;
            [self.gkSkeletonAnimationHelper executeOpacityAnimationForLayer:self.gkSkeletonLayer completion:^ {
                weakSelf.gkSkeletonLayer = nil;
                !completion ?: completion();
            }];
            
        }else{
            self.gkSkeletonLayer = nil;
            !completion ?: completion();
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

- (void)setGkSkeletonHideAnimate:(BOOL) animate
{
    objc_setAssociatedObject(self, &GKSkeletonHideAnimateKey, @(animate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkSkeletonHideAnimate
{
    return [objc_getAssociatedObject(self, &GKSkeletonHideAnimateKey) boolValue];
}

- (void)gkSkeletonProcessView:(UIView*) view inContainer:(UIView*) container
{
    if(view != nil){
        GKSkeletonStatus status = container.gkSkeletonStatus;
        switch (status) {
            case GKSkeletonStatusShowing : {
                
                [view gkShowSkeleton];
            }
                break;
            case GKSkeletonStatusWillHide: {
                
                __weak UIView *weakSelf = container;
                [view gkHideSkeletonWithAnimate:container.gkSkeletonHideAnimate completion:^ {
                    if(weakSelf.gkSkeletonStatus == GKSkeletonStatusWillHide){
                        weakSelf.gkSkeletonLayer = nil;
                    }
                }];
            }
                break;
            case GKSkeletonStatusNone : {
                [view gkHideSkeletonWithAnimate:NO];
            }
                break;
            default:
                break;
        }
    }
}

@end
