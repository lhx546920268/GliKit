//
//  GKSkeletonLayer.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKSkeletonSubLayer;

///骨架图层
@interface GKSkeletonLayer : CALayer

///骨架背景
@property(nonatomic, strong) UIColor *skeletonBackgroundColor;

///设置骨架子图层
@property(nonatomic, copy) NSArray<GKSkeletonSubLayer*> *skeletonSubLayers;

@end

NS_ASSUME_NONNULL_END
