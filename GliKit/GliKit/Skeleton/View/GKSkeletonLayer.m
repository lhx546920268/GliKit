//
//  GKSkeletonLayer.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKSkeletonLayer.h"
#import "GKSkeletonSubLayer.h"
#import "UIColor+GKTheme.h"

@implementation GKSkeletonLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.skeletonBackgroundColor = UIColor.gkSkeletonBackgroundColor;
    }
    return self;
}

- (void)setSkeletonSubLayers:(NSArray<GKSkeletonSubLayer *> *)skeletonSubLayers
{
    if(_skeletonSubLayers != skeletonSubLayers){
        for(GKSkeletonSubLayer *layer in _skeletonSubLayers){
            [layer removeFromSuperlayer];
        }
        _skeletonSubLayers = [skeletonSubLayers copy];
        
        for(GKSkeletonSubLayer *layer in _skeletonSubLayers){
            layer.backgroundColor = self.skeletonBackgroundColor.CGColor;
            [self addSublayer:layer];
        }
    }
}

@end
