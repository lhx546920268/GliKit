//
//  GKPhotosCheckBox.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/2.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosCheckBox.h"
#import "UIColor+GKUtils.h"
#import "NSString+GKUtils.h"
#import "UIScreen+GKUtils.h"
#import "UIColor+GKTheme.h"

@interface GKPhotosCheckBox()

///文字大小
@property(nonatomic, assign) CGSize checkedTextSize;

@end

@implementation GKPhotosCheckBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initParams];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initParams];
    }
    return self;
}

- (void)initParams
{
    self.opaque = NO;
    self.font = [UIFont systemFontOfSize:12];
    _contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)setCheckedText:(NSString *)checkedText
{
    if(![_checkedText isEqualToString:checkedText]){
        _checkedText = checkedText;
        self.checkedTextSize = [_checkedText gkStringSizeWithFont:self.font contraintWith:UIScreen.gkScreenWidth];
        [self setNeedsDisplay];
    }
}

- (void)setChecked:(BOOL)checked
{
    if(_checked != checked){
        _checked = checked;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetShadowWithColor(context, CGSizeZero, 1, [UIColor colorWithWhite:0.8 alpha:0.5].CGColor);
    CGFloat lineWidth = 1.0;
    CGContextSetLineWidth(context, lineWidth);
    
    CGFloat radius = MIN(rect.size.width - _contentInsets.left - _contentInsets.right, rect.size.height - _contentInsets.top - _contentInsets.bottom) / 2.0;
    CGPoint center = CGPointMake(_contentInsets.left + radius, _contentInsets.top + radius);
    
    if(self.checked){
        CGContextSetFillColorWithColor(context, UIColor.gkThemeColor.CGColor);
        CGContextAddArc(context, center.x, center.y, radius, 0, M_PI * 2, NO);
        CGContextFillPath(context);
        
        [self.checkedText drawAtPoint:CGPointMake(center.x - self.checkedTextSize.width / 2.0, center.y - self.checkedTextSize.height / 2.0) withAttributes:@{NSFontAttributeName : self.font, NSForegroundColorAttributeName : UIColor.gkThemeTintColor}];
    }else{
        CGContextAddArc(context, center.x, center.y, radius - lineWidth / 2.0, 0, M_PI * 2, NO);
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    self.checked = checked;
    if(checked && animated){
        CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
        animation.fromValue = @0.7;
        animation.toValue = @1.0;
        animation.duration = 0.5;
        [self.layer addAnimation:animation forKey:@"scale"];
    }
}

@end
