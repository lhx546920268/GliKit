//
//  GKAlertButton.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKAlertButton.h"

@implementation GKAlertButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        
        _highlightView = [[UIView alloc] initWithFrame:self.bounds];
        _highlightView.userInteractionEnabled = NO;
        _highlightView.hidden = YES;
        [self addSubview:_highlightView];
        
        
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _titleLabel.frame = self.bounds;
    _highlightView.frame = self.bounds;
}

- (void)dealloc
{
    self.selector = nil;
}

#pragma mark- public method

/**开始点击 当手势为UITapGestureRecognizer时， 在处理手势的方法中调用该方法
 */
- (void)touchBegan
{
    _highlightView.hidden = NO;
}

/**结束点击 当手势为UITapGestureRecognizer时， 在处理手势的方法中调用该方法
 */
- (void)touchEnded
{
    _highlightView.hidden = YES;
}

/**添加单击手势
 */
- (void)addTarget:(id)target action:(SEL)selector
{
    self.target = target;
    self.selector = selector;
}


#pragma mark- touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchBegan];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTap];
    [self touchEnded];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTap];
    [self touchEnded];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    
    if(!CGRectContainsPoint(self.frame, point)){
        [self touchEnded];
    }else{
        [self touchBegan];
    }
}

///点击事件
- (void)handleTap
{
    if(!self.highlightView.hidden)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:self];
#pragma clang diagnostic pop
    }
}

@end
