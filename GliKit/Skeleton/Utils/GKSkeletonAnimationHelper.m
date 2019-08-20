//
//  GKSkeletonAnimationHelper.m
//  IOSLibrary
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKSkeletonAnimationHelper.h"

@implementation GKSkeletonAnimationHelper

- (void)executeOpacityAnimationForLayer:(GKLayer*) layer completion:(GKSkeletonAnimationCompletion) completion
{
    self.completion = completion;
    GKBasicAnimation *animation = [GKBasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(1.0);
    animation.toValue = @(0);
    animation.duration = 0.25;
    animation.timingFunction = [GKMediaTimingFunction functionWithName:kGKMediaTimingFunctionEaseInEaseOut];
    animation.delegate = (id<GKAnimationDelegate>)self;
    animation.fillMode = kGKFillModeForwards;
    animation.removedOnCompletion = NO;
    [layer addAnimation:animation forKey:@"opacity"];
}

//MARK: GKAnimationDelegate

- (void)animationDidStop:(GKAnimation *)anim finished:(BOOL)flag
{
    !self.completion ?: self.completion(flag);
    self.completion = nil;
}

@end
