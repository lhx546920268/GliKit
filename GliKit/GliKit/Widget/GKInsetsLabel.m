//
//  GKInsetsLabel.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/17.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKInsetsLabel.h"

@implementation GKInsetsLabel

- (void)setPaddingTop:(CGFloat)paddingTop
{
    if(_paddingTop != paddingTop){
        _paddingTop = paddingTop;
        [self setNeedsDisplay];
    }
}

- (void)setPaddingLeft:(CGFloat)paddingLeft
{
    if(_paddingLeft != paddingLeft){
        _paddingLeft = paddingLeft;
        [self setNeedsDisplay];
    }
}

- (void)setPaddingRight:(CGFloat)paddingRight
{
    if(_paddingRight != paddingRight){
        _paddingRight = paddingRight;
        [self setNeedsDisplay];
    }
}

- (void)setPaddingBottom:(CGFloat)paddingBottom
{
    if(_paddingBottom != paddingBottom){
        _paddingBottom = paddingBottom;
        [self setNeedsDisplay];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _paddingLeft = contentInsets.left;
    _paddingTop = contentInsets.top;
    _paddingRight = contentInsets.right;
    _paddingBottom = contentInsets.bottom;
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    
    if(size.width < 2777777){
        size.width += _paddingLeft + _paddingRight;
    }
    
    if(size.height < 2777777){
        size.height += _paddingTop + _paddingBottom;
    }
    
    
    return size;
}

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = UIEdgeInsetsMake(_paddingTop, _paddingLeft, _paddingBottom, _paddingRight);
    CGRect drawRect = UIEdgeInsetsInsetRect(rect, insets);
    [super drawTextInRect:drawRect];
}


@end
