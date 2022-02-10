//
//  UIBezierPath+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2022/2/10.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import "UIBezierPath+GKUtils.h"

@implementation UIBezierPath (GKUtils)

- (void)gkAddArrowWithStart:(CGPoint)start end:(CGPoint)end angle:(CGFloat)angle length:(CGFloat)length
{
    //不一定是直线
    CGFloat extraAngle = atan((end.y - start.y) / (end.x - start.x));
    
    CGFloat angle1 = angle - extraAngle;
    [self moveToPoint:start];
    [self addLineToPoint:CGPointMake(start.x + cos(angle1) * length, start.y - sin(angle1) * length)];
    
    CGFloat angle2 = angle + extraAngle;
    [self moveToPoint:start];
    [self addLineToPoint:CGPointMake(start.x + cos(angle2) * length, start.y + sin(angle2) * length)];
}

@end
