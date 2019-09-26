//
//  UIView+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/25.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKUtils.h"
#import "NSObject+GKUtils.h"

@implementation UIView (GKUtils)

// MARK: - 坐标

- (CGFloat)gkTop
{
    return self.frame.origin.y;
}

- (void)setGkTop:(CGFloat) top
{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)gkRight
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setGkRight:(CGFloat) right
{
    CGRect frame = self.frame;
    frame.origin.x = right - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)gkBottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setGkBottom:(CGFloat) bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - self.frame.size.height;
    self.frame = frame;
}

- (CGFloat)gkLeft
{
    return self.frame.origin.x;
}

- (void)setGkLeft:(CGFloat) left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)gkWidth
{
    return self.frame.size.width;
}

- (void)setGkWidth:(CGFloat) width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)gkHeight
{
    return self.frame.size.height;
}

- (void)setGkHeight:(CGFloat) height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)gkSize
{
    return self.frame.size;
}

- (void)setGkSize:(CGSize) size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)gkCenterX
{
    return self.center.x;
}

- (void)setGkCenterX:(CGFloat) centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)gkCenterY
{
    return self.center.y;
}

- (void)setGkCenterY:(CGFloat) centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

+ (instancetype)loadFromNib
{
    return [[NSBundle.mainBundle loadNibNamed:[self gkNameOfClass] owner:nil options:nil] lastObject];
}

- (void)gkRemoveAllSubviews
{
    NSArray *subviews = self.subviews;
    for(UIView *view in subviews){
        [view removeFromSuperview];
    }
}

- (UIEdgeInsets)gkSafeAreaInsets
{
    if(@available(iOS 11, *)){
        return self.safeAreaInsets;
    }else{
        return UIEdgeInsetsZero;
    }
}

@end
