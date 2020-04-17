//
//  GKScanBoxView.m
//  GliKit
//
//  Created by 罗海雄 on 2020/4/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKScanBoxView.h"
#import "UIView+GKUtils.h"
#import "UIColor+GKTheme.h"

///边角位置
typedef NS_ENUM(NSInteger, GKScanCornerPosition){
    GKScanCornerPositionTopLeft,
    GKScanCornerPositionTopRight,
    GKScanCornerPositionBottomLeft,
    GKScanCornerPositionBottomRight,
};

@implementation GKScanBoxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setCornerLineWidth:(CGFloat)cornerLineWidth
{
    if(_cornerLineWidth != cornerLineWidth){
        _cornerLineWidth = cornerLineWidth;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat lineWidth = self.cornerLineWidth;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetStrokeColorWithColor(ctx, UIColor.gkThemeColor.CGColor);
    
    [self drawCornerInContext:ctx position:GKScanCornerPositionTopLeft];
    [self drawCornerInContext:ctx position:GKScanCornerPositionTopRight];
    [self drawCornerInContext:ctx position:GKScanCornerPositionBottomLeft];
    [self drawCornerInContext:ctx position:GKScanCornerPositionBottomRight];
    
    CGContextStrokePath(ctx);
}

///绘制扫描区域边角
- (void)drawCornerInContext:(CGContextRef) ctx position:(GKScanCornerPosition) position
{
    CGSize size = CGSizeMake(20, 20);
    CGPoint point = CGPointZero;
    
    switch (position){
        case GKScanCornerPositionTopLeft : {
            size.width += point.x;
            size.height += point.y;
            
            CGContextMoveToPoint(ctx, point.x, size.height);
            CGContextAddLineToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, size.width, point.y);
        }
            break;
        case GKScanCornerPositionBottomLeft : {
            point.y += self.gkHeight - size.height;
            size.height += point.y;
            size.width += point.x;
            
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x, size.height);
            CGContextAddLineToPoint(ctx, size.width, size.height);
        }
            break;
        case GKScanCornerPositionTopRight : {
            point.x += self.gkWidth - size.width;
            size.height += point.y;
            size.width += point.x;
            
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, size.width, point.y);
            CGContextAddLineToPoint(ctx, size.width, size.height);
        }
            break;
        case GKScanCornerPositionBottomRight : {
            point.y += self.gkHeight - size.height;
            point.x += self.gkWidth - size.width;
            
            size.height += point.y;
            size.width += point.x;
            
            CGContextMoveToPoint(ctx, point.x, size.height);
            CGContextAddLineToPoint(ctx, size.width, size.height);
            CGContextAddLineToPoint(ctx, size.width, point.y);
        }
            break;
    }
}

@end
