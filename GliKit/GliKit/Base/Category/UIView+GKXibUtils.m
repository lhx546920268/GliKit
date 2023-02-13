//
//  UIView+GKXibUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKXibUtils.h"

@implementation UIView (GKXibUtils)

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor
{
    return self.layer.borderColor ? [UIColor colorWithCGColor:self.layer.borderColor] : nil;
}

- (void)setMaskToBounds:(BOOL)maskToBounds
{
    self.layer.masksToBounds = maskToBounds;
}

- (BOOL)maskToBounds
{
    return self.layer.masksToBounds;
}

@end
