//
//  UIBezierPath+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2022/2/10.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIBezierPath (GKUtils)


/// 添加一个箭头，箭头添加在起点
/// @param start 线起点
/// @param end 线终点
/// @param angle 箭头角度，不是度数，是圆周率相关的pi，比如90度，就是pi / 2
/// @param length 箭头长度
- (void)gkAddArrowWithStart:(CGPoint) start end:(CGPoint) end angle:(CGFloat) angle length:(CGFloat) length;

@end

