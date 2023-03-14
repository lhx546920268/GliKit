//
//  GKPopover.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKPopover.h"
#import "UIView+GKUtils.h"
#import "UIColor+GKUtils.h"

@implementation GKPopoverOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.userInteractionEnabled = YES;
    }
    return self;
}

@end

@interface GKPopover()<UIGestureRecognizerDelegate>

///动画起始位置
@property(nonatomic, assign) CGPoint originalPoint;

///气泡出现的位置
@property(nonatomic, assign) CGRect relatedRect;

@end

@implementation GKPopover

@synthesize overlay = _overlay;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clipsToBounds = YES;
        
        _fillColor = [UIColor whiteColor];
        _strokeColor = [UIColor clearColor];
        _strokeWidth = 0;
        _arrowSize = CGSizeMake(15, 10);
        _mininumMargin = 10;
        _cornerRadius = 5.0;
        _contentInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        _arrowMargin = 3.0;
    }
    return self;
}

- (void)showInView:(UIView*) view relatedRect:(CGRect) rect animated:(BOOL) animated
{
    [self showInView:view relatedRect:rect animated:animated overlay:YES];
}

- (void)showInView:(UIView*) view relatedRect:(CGRect) rect animated:(BOOL) animated overlay:(BOOL) overlay
{
    if(_isShowing)
        return;
    self.relatedRect = rect;
    
    if([self.delegate respondsToSelector:@selector(popoverWillShow:)]){
        [self.delegate popoverWillShow:self];
    }
    
    if(!self.contentView){
        [self initContentView];
    }
    
    CGRect toFrame = [self setupFrameFromView:view relateRect:rect];
    CGPoint anchorPoint = CGPointZero;
    
    switch (self.arrowDirection){
        case GKPopoverArrowDirectionTop :{
            anchorPoint.x = (self.originalPoint.x - toFrame.origin.x) / toFrame.size.width;
        }
            break;
        case GKPopoverArrowDirectionLeft :{
            anchorPoint.y = (self.originalPoint.y - toFrame.origin.y) / toFrame.size.height;
        }
            break;
        case GKPopoverArrowDirectionRight :{
            anchorPoint.y = (self.originalPoint.y - toFrame.origin.y) / toFrame.size.height;
            anchorPoint.x = 1.0;
        }
            break;
        case GKPopoverArrowDirectionBottom :{
            anchorPoint.x = (self.originalPoint.x - toFrame.origin.x) / toFrame.size.width;
            anchorPoint.y = 1.0;
        }
            break;
    }
    
    self.layer.anchorPoint = anchorPoint;
    self.transform = CGAffineTransformIdentity;
    self.frame = toFrame;
    
    if(overlay){
        
        CGRect frame = view.bounds;
        frame.origin.y += self.offset;
        self.overlay.frame = frame;
        [view addSubview:self.overlay];
    }
    
    if(animated){
        self.alpha = 0;
        _overlay.alpha = 0;
    }
    [view addSubview:self];
    
    _isShowing = YES;
    if(animated){
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.25 animations:^(void){
             self->_overlay.alpha = 1.0;
             self.alpha = 1.0;
             self.transform = CGAffineTransformMakeScale(1.0, 1.0);
         }completion:^(BOOL finish){
             if([self.delegate respondsToSelector:@selector(popoverDidShow:)]){
                 [self.delegate popoverDidShow:self];
             }
         }];
    }else{
        self.alpha = 1.0;
        _overlay.alpha = 1.0;
        if([self.delegate respondsToSelector:@selector(popoverDidShow:)]){
            [self.delegate popoverDidShow:self];
        }
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if(!_isShowing)
        return;
    
    _isShowing = NO;
    if([self.delegate respondsToSelector:@selector(popoverWillDismiss:)]){
        [self.delegate popoverWillDismiss:self];
    }
    
    if(animated){
        [UIView animateWithDuration:0.25 animations:^(void){
            self.alpha = 0;
            self->_overlay.alpha = 0;
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
         }completion:^(BOOL finish){
             if([self.delegate respondsToSelector:@selector(popoverDidDismiss:)]){
                 [self.delegate popoverDidDismiss:self];
             }
             [self->_overlay removeFromSuperview];
             [self removeFromSuperview];
         }];
    }else{
        if([self.delegate respondsToSelector:@selector(popoverDidDismiss:)]){
            [self.delegate popoverDidDismiss:self];
        }
        
        [_overlay removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (GKPopoverOverlay*)overlay
{
    if(!_overlay){
        _overlay = [GKPopoverOverlay new];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.delegate = self;
        [_overlay addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        [_overlay addGestureRecognizer:pan];
    }
    
    return _overlay;
}

- (void)initContentView
{
    
}

- (void)setContentView:(UIView *)contentView
{
    if(_contentView != contentView){
        [_contentView removeFromSuperview];
        _contentView = contentView;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = _cornerRadius;
        [self addSubview:_contentView];
    }
}

///设置菜单的位置
- (CGRect)setupFrameFromView:(UIView*) view relateRect:(CGRect) rect
{
    CGSize contentSize = self.contentView.bounds.size;
    contentSize.width += self.contentInsets.left + self.contentInsets.right;
    contentSize.height += self.contentInsets.top + self.contentInsets.bottom;
    
    CGFloat relateX = rect.origin.x;
    CGFloat relateY = rect.origin.y;
    CGFloat relateWidth = rect.size.width;
    CGFloat relateHeight = rect.size.height;
    
    CGFloat superWidth = view.frame.size.width;
    CGFloat superHeight = view.frame.size.height - self.offset;
    
    CGFloat margin = _mininumMargin;
    CGFloat scale = 2.0 / 3.0;
    
    CGRect resultRect;
    
    //尖角宽度
    CGFloat arrowWidth = _arrowSize.width;
    CGFloat arrowHeight = _arrowSize.height;
    
    if((superHeight - (relateY + relateHeight)) * scale > contentSize.height){
        _arrowDirection = GKPopoverArrowDirectionTop;

        CGFloat x = relateX + relateWidth * 0.5 - contentSize.width * 0.5;
        x = x < margin ? margin - 10 : x;
        x = x + margin + contentSize.width > superWidth ? superWidth - contentSize.width - margin : x;
        CGFloat y = relateY + relateHeight + _arrowMargin;

        resultRect = CGRectMake(x, y, contentSize.width, contentSize.height + arrowHeight);
        _arrowPoint = CGPointMake(MIN(relateX - x + relateWidth * 0.5, resultRect.origin.x + resultRect.size.width - _cornerRadius - _arrowSize.width), 0);
        self.originalPoint = CGPointMake(x + _arrowPoint.x, y);
    }else if(relateY * scale > contentSize.height){
        _arrowDirection = GKPopoverArrowDirectionBottom;

        CGFloat x = relateX + relateWidth * 0.5 - contentSize.width * 0.5;
        x = x < margin ? margin - 10 : x;
        x = x + margin + contentSize.width > superWidth ? superWidth - contentSize.width - margin : x;
        CGFloat y = relateY - _arrowMargin - contentSize.height - arrowHeight;

        resultRect = CGRectMake(x, y, contentSize.width, contentSize.height + arrowHeight);
        _arrowPoint = CGPointMake(MIN(relateX - x + relateWidth * 0.5, resultRect.origin.x + resultRect.size.width - _cornerRadius - _arrowSize.width), resultRect.size.height);
        self.originalPoint = CGPointMake(x + _arrowPoint.x, y + resultRect.size.height);
    }else{
        if(superWidth - (relateX + relateWidth) < contentSize.width){
            _arrowDirection = GKPopoverArrowDirectionRight;

            CGFloat x = relateX - _arrowMargin - contentSize.width - arrowWidth;
            CGFloat y = relateY + relateHeight * 0.5 - contentSize.height * 0.5;
            y = y < margin ? margin : y;
            y = y + margin + contentSize.height > superHeight ? superHeight - contentSize.height - margin : y;

            resultRect = CGRectMake(x, y, contentSize.width + arrowHeight, contentSize.height);
            _arrowPoint = CGPointMake(resultRect.size.width, MIN(relateY - y + relateHeight * 0.5, resultRect.origin.y + resultRect.size.height - _cornerRadius - _arrowSize.width));
            self.originalPoint = CGPointMake(x + resultRect.size.width, y + _arrowPoint.y);
        }else{
            _arrowDirection = GKPopoverArrowDirectionLeft;
            
            CGFloat x = relateX + relateWidth + _arrowMargin;
            CGFloat y = relateY + relateHeight * 0.5 - contentSize.height * 0.5;
            y = y < margin ? margin : y;
            y = y + margin + contentSize.height > superHeight ? superHeight - contentSize.height - margin : y;
            
            resultRect = CGRectMake(x, y, contentSize.width + arrowHeight, contentSize.height);
            _arrowPoint = CGPointMake(0, MIN(relateY - y + relateHeight * 0.5, resultRect.origin.y + resultRect.size.height - _cornerRadius - _arrowSize.width));
            self.originalPoint = CGPointMake(x, y + _arrowPoint.y);
        }
    }
    
    [self adjustContentView];
    
    return resultRect;
}

// MARK: - Action

//点击透明部位
- (void)handleTap:(UITapGestureRecognizer*) sender
{
    [self dismissAnimated:YES];
}

- (void)handlePan:(UIPanGestureRecognizer*) sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self dismissAnimated:YES];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:_overlay];
    if(CGRectContainsPoint(self.contentView.frame, point)){
        return NO;
    }
    
    return YES;
}

// MARK: - Property

- (void)setFillColor:(UIColor *)fillColor
{
    if(![_fillColor isEqualToColor:fillColor]){
        if(fillColor == nil)
            fillColor = [UIColor whiteColor];
        _fillColor = fillColor;
        [self setNeedsDisplay];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if(![_strokeColor isEqualToColor:strokeColor]){
        if(strokeColor == nil)
            strokeColor = [UIColor clearColor];
        _strokeColor = strokeColor;
        [self setNeedsDisplay];
    }
}

- (void)setStrokeWidth:(CGFloat)strokeWidth
{
    if(_strokeWidth != strokeWidth){
        if(strokeWidth < 0)
            strokeWidth = 0;
        _strokeWidth = strokeWidth;
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    if(!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)){
        _contentInsets = contentInsets;
        if(self.contentView){
            CGRect frame = self.frame;
            frame.size.width = self.contentView.gkWidth + _contentInsets.left + _contentInsets.right;
            frame.size.height = self.contentView.gkHeight + _contentInsets.right + _contentInsets.left;
            self.frame = frame;
            
            [self adjustContentView];
        }
    }
}

- (void)setArrowSize:(CGSize)arrowSize
{
    if(!CGSizeEqualToSize(arrowSize, _arrowSize)){
        _arrowSize = arrowSize;
        [self redraw];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if(_cornerRadius != cornerRadius){
        _cornerRadius = cornerRadius;
        self.contentView.layer.cornerRadius = _cornerRadius;
        [self setNeedsDisplay];
    }
}

- (void)setMininumMargin:(CGFloat)mininumMargin
{
    if(_mininumMargin != mininumMargin){
        _mininumMargin = mininumMargin;
        [self redraw];
    }
}

- (void)setArrowMargin:(CGFloat)arrowMargin
{
    if(_arrowMargin != arrowMargin){
        _arrowMargin = arrowMargin;
        [self redraw];
    }
}

///调整contentView rect
- (void)adjustContentView
{
    CGRect frame = self.contentView.frame;
    frame.origin.x = self.contentInsets.left;
    frame.origin.y = self.contentInsets.top;
    
    switch (_arrowDirection) {
        case GKPopoverArrowDirectionLeft :
            frame.origin.x += _arrowSize.height;
            break;
        case GKPopoverArrowDirectionTop :
            frame.origin.y += _arrowSize.height;
            break;
        default:
            break;
    }
    
    self.contentView.frame = frame;
}

// MARK: - Draw

- (void)redraw
{
    if(self.superview){
        self.frame = [self setupFrameFromView:self.superview relateRect:self.relatedRect];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    //尖角宽度
    CGFloat arrowWidth = _arrowSize.width;
    CGFloat arrowHeight = _arrowSize.height;
    
    CGRect rectangular;
    CGFloat lineWidth = _strokeWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //设置绘制属性
    CGFloat cornerRadius = _cornerRadius;//矩形圆角
    CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, _fillColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    //设置位置
    CGPoint arrowPoint;
    CGPoint arrowPoint1;
    CGPoint arrowPoint2;
    
    switch(self.arrowDirection){
        case GKPopoverArrowDirectionTop : {
            arrowPoint = CGPointMake(_arrowPoint.x, _arrowPoint.y + lineWidth / 2.0);
            arrowPoint1 = CGPointMake(_arrowPoint.x - arrowWidth * 0.5, _arrowPoint.y + arrowHeight);
            arrowPoint2 = CGPointMake(_arrowPoint.x + arrowWidth * 0.5, _arrowPoint.y + arrowHeight);
            rectangular = CGRectMake(lineWidth, arrowHeight, self.bounds.size.width - lineWidth * 2.0, self.bounds.size.height - arrowHeight - lineWidth);
            
            CGFloat rectangularBottom = rectangular.size.height + rectangular.origin.y;///矩形 height + y
            CGFloat rectangularRight = rectangular.origin.x + rectangular.size.width; ///矩形 width + x
            
            
            //绘制尖角左边
            CGContextMoveToPoint(context, _arrowPoint.x, _arrowPoint.y + lineWidth);
            CGContextAddLineToPoint(context, arrowPoint1.x, arrowPoint1.y);
            
            //绘制圆角矩形
            //向左边连接
            CGContextAddLineToPoint(context, rectangular.origin.x + cornerRadius, rectangular.origin.y);
            
            //绘制左边圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangular.origin.y, rectangular.origin.x, cornerRadius + rectangular.origin.y, cornerRadius);
            
            //向下连接
            CGContextAddLineToPoint(context, rectangular.origin.x, rectangularBottom - cornerRadius);
            //绘制左下角圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangularBottom, rectangular.origin.x + cornerRadius, rectangularBottom, cornerRadius);
            
            //向右边连接
            CGContextAddLineToPoint(context, rectangularRight - cornerRadius, rectangularBottom);
            //绘制右下角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangularBottom, rectangularRight, rectangularBottom - cornerRadius, cornerRadius);
            
            //向上连接
            CGContextAddLineToPoint(context, rectangularRight, rectangular.origin.y + cornerRadius);
            //绘制右上角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangular.origin.y, rectangularRight - cornerRadius, rectangular.origin.y, cornerRadius);
            
            //向尖角右下角连接
            CGContextAddLineToPoint(context, arrowPoint2.x, arrowPoint2.y);
            CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y);
        }
            break;
        case GKPopoverArrowDirectionBottom : {
            arrowPoint = CGPointMake(_arrowPoint.x, _arrowPoint.y - lineWidth / 2.0);
            arrowPoint1 = CGPointMake(_arrowPoint.x - arrowWidth * 0.5, _arrowPoint.y - arrowHeight);
            arrowPoint2 = CGPointMake(_arrowPoint.x + arrowWidth * 0.5, _arrowPoint.y - arrowHeight);
            rectangular = CGRectMake(lineWidth, 0, self.bounds.size.width - lineWidth * 2.0, self.bounds.size.height - arrowHeight - lineWidth);
            
            CGFloat rectangularBottom = rectangular.size.height + rectangular.origin.y;///矩形 height + y
            CGFloat rectangularRight = rectangular.origin.x + rectangular.size.width; ///矩形 width + x
            
            
            //绘制尖角 左边
            CGContextMoveToPoint(context, arrowPoint.x, arrowPoint.y);
            CGContextAddLineToPoint(context, arrowPoint1.x, arrowPoint1.y);
            
            //绘制圆角矩形
            //向左边连接
            CGContextAddLineToPoint(context, rectangular.origin.x + cornerRadius, rectangularBottom);
            
            //绘制左下角圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangularBottom, rectangular.origin.x, rectangularBottom - cornerRadius, cornerRadius);
            
            //向上连接
            CGContextAddLineToPoint(context, rectangular.origin.x, rectangular.origin.y + cornerRadius);
            //绘制左上角角圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangular.origin.y, rectangular.origin.x + cornerRadius, rectangular.origin.y, cornerRadius);
            
            //向右边连接
            CGContextAddLineToPoint(context, rectangularRight - cornerRadius, rectangular.origin.y);
            //绘制右上角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangular.origin.y, rectangularRight, rectangular.origin.y + cornerRadius, cornerRadius);
            
            //向下连接
            CGContextAddLineToPoint(context, rectangularRight, rectangularBottom - cornerRadius);
            //绘制右下角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangularBottom, rectangularRight - cornerRadius, rectangularBottom, cornerRadius);
            
            //向尖角右上角连接
            CGContextAddLineToPoint(context, arrowPoint2.x, arrowPoint2.y);
            CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y);
        }
            break;
        case GKPopoverArrowDirectionLeft : {
            arrowPoint = CGPointMake(_arrowPoint.x + lineWidth / 2.0, _arrowPoint.y);
            arrowPoint1 = CGPointMake(arrowPoint.x + arrowHeight, arrowPoint.y + arrowWidth * 0.5);
            arrowPoint2 = CGPointMake(arrowPoint.x + arrowHeight, arrowPoint.y - arrowWidth * 0.5);
            rectangular = CGRectMake(arrowHeight, lineWidth, self.bounds.size.width - lineWidth - arrowHeight, self.bounds.size.height - lineWidth);
            
            CGFloat rectangularBottom = rectangular.size.height + rectangular.origin.y;///矩形 height + y
            CGFloat rectangularRight = rectangular.origin.x + rectangular.size.width; ///矩形 width + x
            
            //绘制尖角下面
            CGContextMoveToPoint(context, arrowPoint.x, arrowPoint.y);
            CGContextAddLineToPoint(context, arrowPoint1.x, arrowPoint1.y);
            
            //绘制圆角矩形
            //向下连接
            CGContextAddLineToPoint(context, rectangular.origin.x , rectangularBottom - cornerRadius);
            
            //绘制左下角圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangularBottom, rectangular.origin.x + cornerRadius, rectangularBottom, cornerRadius);

            //向右连接
            CGContextAddLineToPoint(context, rectangularRight - cornerRadius, rectangularBottom);
            //绘制右下角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangularBottom, rectangularRight, rectangularBottom - cornerRadius, cornerRadius);

            //向上连接
            CGContextAddLineToPoint(context, rectangularRight, rectangular.origin.y + cornerRadius);
            //绘制右上角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangular.origin.y, rectangularRight - cornerRadius, rectangular.origin.y, cornerRadius);

            //向左连接
            CGContextAddLineToPoint(context, rectangular.origin.x + cornerRadius, rectangular.origin.y);
            //绘制左上角圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangular.origin.y, rectangular.origin.x, rectangular.origin.y + cornerRadius, cornerRadius);

            //向尖角上面连接
            CGContextAddLineToPoint(context, arrowPoint2.x, arrowPoint2.y);
            CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y);
        }
            break;
        case GKPopoverArrowDirectionRight : {
            arrowPoint = CGPointMake(_arrowPoint.x - lineWidth / 2.0, _arrowPoint.y);
            arrowPoint1 = CGPointMake(arrowPoint.x - arrowHeight, arrowPoint.y + arrowWidth * 0.5);
            arrowPoint2 = CGPointMake(arrowPoint.x - arrowHeight, arrowPoint.y - arrowWidth * 0.5);
            rectangular = CGRectMake(0, lineWidth, self.bounds.size.width - lineWidth - arrowHeight, self.bounds.size.height - lineWidth * 2);
            
            CGFloat rectangularBottom = rectangular.size.height + rectangular.origin.y;///矩形 height + y
            CGFloat rectangularRight = rectangular.origin.x + rectangular.size.width; ///矩形 width + x
            
            //绘制尖角下面
            CGContextMoveToPoint(context, arrowPoint.x, arrowPoint.y);
            CGContextAddLineToPoint(context, arrowPoint1.x, arrowPoint.y);
            
            //绘制圆角矩形
            //向右下连接
            CGContextAddLineToPoint(context, rectangularRight, rectangularBottom - cornerRadius);
            //绘制右下角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangularBottom, rectangularRight - cornerRadius, rectangularBottom, cornerRadius);

            //向左连接
            CGContextAddLineToPoint(context, rectangular.origin.x - cornerRadius, rectangularBottom);

            //绘制左下角圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangularBottom, rectangular.origin.x, rectangularBottom - cornerRadius, cornerRadius);

            //向左上连接
            CGContextAddLineToPoint(context, rectangular.origin.x, rectangular.origin.y - cornerRadius);
            //绘制左上角圆角
            CGContextAddArcToPoint(context, rectangular.origin.x, rectangular.origin.y, rectangular.origin.x + cornerRadius, rectangular.origin.y, cornerRadius);

            //向上连接
            CGContextAddLineToPoint(context, rectangularRight - cornerRadius, rectangular.origin.y);
            //绘制右上角圆角
            CGContextAddArcToPoint(context, rectangularRight, rectangular.origin.y, rectangularRight, rectangular.origin.y - cornerRadius, cornerRadius);

            //向尖角上面连接
            CGContextAddLineToPoint(context, arrowPoint2.x, arrowPoint2.y);
            CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y);
        }
            break;
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
