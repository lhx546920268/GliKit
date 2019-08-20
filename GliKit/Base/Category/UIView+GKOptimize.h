//
//  UIView+GKOptimize.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/8/12.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///性能优化
@interface UIView (GKOptimize)

///避免颜色混合 会设置成父视图的背景颜色
- (void)gk_avoidColorBlended;

///避免颜色混合 设置对应颜色
- (void)gk_avoidColorBlendedForColor:(UIColor*) color;

@end

