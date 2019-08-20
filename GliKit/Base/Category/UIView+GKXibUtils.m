//
//  UIView+GKXibUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 xiaozhai. All rights reserved.
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
    return [UIColor colorWithCGColor:self.layer.borderColor];
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
