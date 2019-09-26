//
//  UIView+GKOptimize.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/12.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///性能优化
@interface UIView (GKOptimize)

///避免颜色混合 会设置成父视图的背景颜色
- (void)gkAvoidColorBlended;

///避免颜色混合 设置对应颜色
- (void)gkAvoidColorBlendedForColor:(UIColor*) color;

@end

NS_ASSUME_NONNULL_END

