//
//  GKProgressView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKProgressView.h"
#import "UIApplication+GKTheme.h"
#import "UIColor+GKTheme.h"
#import "UIColor+GKUtils.h"
#import "GKBaseDefines.h"

@interface GKProgressView ()

///原来的进度
@property(nonatomic,assign) float previousProgress;

///
@property(nonatomic, assign) CGSize progressSize;

@end

@implementation GKProgressView

@synthesize progressColor = _progressColor;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initParams];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initParams];
    }
    
    return self;
}

- (void)initParams
{
    NSAssert(![self isMemberOfClass:GKProgressView.class], @"You must use GKProgressView subclass");
    _openProgress = YES;
    self.clipsToBounds = YES;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.hideAfterFinish = YES;
    self.hideWidthAnimated = YES;
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.fillColor = UIColor.clearColor.CGColor;
    _progressLayer.lineJoin = kCALineJoinRound;
    _progressLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_progressLayer];
    
    [self updateProgressStyle];
}

- (void)updateProgressStyle
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.progressSize, self.frame.size)) {
        self.progressSize = self.frame.size;
        [self onProgressSizeChange:self.progressSize];
        [self updateProgressInternalWithAnimated:NO];
    }
}

- (void)onProgressSizeChange:(CGSize)size
{
    
}

// MARK: - property setup

- (void)setOpenProgress:(BOOL)openProgress
{
    if(_openProgress != openProgress){
        _openProgress = openProgress;
        self.hidden = !_openProgress;
        if(!_openProgress){
            [self reset];
        }
    }
}

- (void)setProgressColor:(UIColor *)progressColor
{
    if(![_progressColor isEqualToColor:progressColor]){
        _progressColor = progressColor;
        [self updateProgressStyle];
    }
}

- (UIColor *)progressColor
{
    return _progressColor ?: UIColor.greenColor;
}

- (void)setProgress:(CGFloat)progress
{
    if(!_openProgress)
        return;
    if(_progress != progress){
        if(self.hidden){
            self.hidden = NO;
            self.layer.opacity = 1.0;
        }
        if(progress > 1.0){
            progress = 1.0;
        }else if(progress < 0){
            progress = 0;
        }
        
        self.previousProgress = _progress;
        _progress = progress;
        
        if(self.previousProgress > _progress){
            self.previousProgress = 0;
        }
        
        [self updateProgressInternalWithAnimated:YES];
    }
}

///更新进度条
- (void)updateProgressInternalWithAnimated:(BOOL) animated
{
    [self.layer removeAllAnimations];
    [self.progressLayer removeAllAnimations];
    
    [self updateProgress:self.progress previousProgress:self.previousProgress animated:animated];
    
    if(_progress >= 1.0){
        WeakObj(self)
        CATransaction.completionBlock = ^{
            [selfWeak hideProgressIfNeeded];
        };
    }
    [CATransaction commit];
}

- (void)updateProgress:(CGFloat)progress previousProgress:(CGFloat)previousProgress animated:(BOOL)animated
{
    self.progressLayer.strokeEnd = progress;
    if (animated) {
        //动画显示进度条
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pathAnimation.duration = 0.25;
        pathAnimation.fromValue = @(previousProgress);
        pathAnimation.toValue = @(progress);
        pathAnimation.removedOnCompletion = YES;

        [self.progressLayer addAnimation:pathAnimation forKey:@"progress"];
    }
}

///动画结束，隐藏进度条
- (void)hideProgressIfNeeded
{
    if(self.hideAfterFinish){
        if(self.hideWidthAnimated){
            
            [CATransaction begin];
            CATransaction.completionBlock = ^{
                self.hidden = YES;
                [self reset];
            };
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = @(1.0);
            animation.toValue = @(0);
            animation.duration = 0.25;
            [self.layer addAnimation:animation forKey:@"opacity"];
            
            [CATransaction commit];
        }else{
            self.hidden = YES;
            [self reset];
        }
    }
}

///重新设置
- (void)reset
{
    _previousProgress = 0;
    _progress = 0;
}

@end

@implementation GKStraightLineProgressView

- (void)initParams
{
    [super initParams];
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
}

- (void)onProgressSizeChange:(CGSize)size
{
    self.progressLayer.frame = self.bounds;
    self.progressLayer.lineWidth = size.height;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, size.height / 2.0)];
    [path addLineToPoint:CGPointMake(size.width, size.height / 2.0)];
    self.progressLayer.path = path.CGPath;
}

- (void)updateProgressStyle
{
    self.progressLayer.strokeColor = self.progressColor.CGColor;
}

@end

@implementation GKCircleProgressView

@synthesize trackColor = _trackColor;

- (void)initParams
{
    CAShapeLayer *layer = (CAShapeLayer*)self.layer;
    layer.fillColor = UIColor.clearColor.CGColor;
    _trackColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    _progressLineWidth = 10.0;
    [super initParams];
}

+ (Class)layerClass
{
    return CAShapeLayer.class;
}

- (void)onProgressSizeChange:(CGSize)size
{
    self.progressLayer.frame = self.bounds;
    
    CGPoint center = CGPointMake(size.width / 2.0, size.height / 2.0);
    CGFloat radius = MIN(size.width / 2.0, size.height / 2.0) - _progressLineWidth / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center radius:radius startAngle:-M_PI_2 endAngle:3 * M_PI_2 clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    CAShapeLayer *layer = (CAShapeLayer*)self.layer;
    layer.path = path.CGPath;
}

- (void)updateProgressStyle
{
    self.progressLayer.strokeColor = self.progressColor.CGColor;
    self.progressLayer.lineWidth = self.progressLineWidth;
    
    CAShapeLayer *layer = (CAShapeLayer*)self.layer;
    layer.lineWidth = self.progressLineWidth;
    layer.strokeColor = self.trackColor.CGColor;
}

- (void)setProgressLineWidth:(CGFloat)progressLineWidth
{
    if(_progressLineWidth != progressLineWidth){
        _progressLineWidth = progressLineWidth;
        [self updateProgressStyle];
    }
}

- (void)setTrackColor:(UIColor *)trackColor
{
    if(![_trackColor isEqualToColor:trackColor]){
        _trackColor = trackColor;
        CAShapeLayer *layer = (CAShapeLayer*)self.layer;
        layer.strokeColor = self.trackColor.CGColor;
    }
}

- (UIColor *)trackColor
{
    return _trackColor ?: UIColor.clearColor;
}

- (void)setShowPercent:(BOOL)showPercent
{
    if(_showPercent != showPercent){
        _showPercent = showPercent;
        
        if(_showPercent){
            if(!self.percentLabel){
                _percentLabel = [UILabel new];
                _percentLabel.textColor = [UIColor blackColor];
                _percentLabel.font = [UIFont systemFontOfSize:20];
                _percentLabel.textAlignment = NSTextAlignmentCenter;
                [self addSubview:_percentLabel];
                
                [_percentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(self);
                }];
            }
        }else if(self.percentLabel){
            [self.percentLabel removeFromSuperview];
            _percentLabel = nil;
        }
    }
}

- (void)updateProgress:(CGFloat)progress previousProgress:(CGFloat)previousProgress
{
    if(self.percentLabel){
        self.percentLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
    }
}

@end

@implementation GKRoundCakesProgressView

- (void)initParams
{
    _fromZero = YES;
    [super initParams];
    self.progressLayer.lineJoin = kCALineJoinMiter;
    self.progressLayer.lineCap = kCALineCapButt;
}

- (void)onProgressSizeChange:(CGSize)size
{
    [self updateProgressPath];
}

- (void)setFromZero:(BOOL)fromZero
{
    if (_fromZero != fromZero) {
        _fromZero = fromZero;
        self.progressLayer.strokeEnd = _fromZero ? self.progress : 1.0;
        self.progressLayer.strokeStart = _fromZero ? 0 : self.progress;
    }
}

- (void)setInnerMargin:(CGFloat)innerMargin
{
    if (_innerMargin != innerMargin) {
        _innerMargin = innerMargin;
        [self updateProgressPath];
    }
}

- (void)updateProgressPath
{
    CGSize size = self.progressSize;
    if (!CGSizeEqualToSize(CGSizeZero, size)) {
        CGFloat min = MIN(size.width, size.height);
        CGFloat radius = min / 2.0 - self.innerMargin;
        NSAssert(radius > 0, @"%@ size - innerMargin must be greater 0", NSStringFromClass(self.class));
        
        self.progressLayer.position = CGPointMake(size.width / 2, size.height / 2);
        self.progressLayer.bounds = CGRectMake(0, 0, min - self.innerMargin * 2, min - self.innerMargin * 2);
        self.progressLayer.lineWidth = radius;
        
        size = self.progressLayer.bounds.size;
        CGPoint center = CGPointMake(size.width / 2, size.height / 2);

        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:center radius:radius / 2 startAngle:-M_PI_2 endAngle:3 * M_PI_2 clockwise:YES];
        self.progressLayer.path = path.CGPath;
    }
}

- (void)updateProgressStyle
{
    self.progressLayer.strokeColor = self.progressColor.CGColor;
}

- (void)updateProgress:(CGFloat)progress previousProgress:(CGFloat)previousProgress animated:(BOOL)animated
{
    if (self.fromZero) {
        self.progressLayer.strokeEnd = progress;
        self.progressLayer.strokeStart = 0;
        if (animated) {
            //动画显示进度条
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            pathAnimation.duration = 0.25;
            pathAnimation.fromValue = @(previousProgress);
            pathAnimation.toValue = @(progress);
            pathAnimation.removedOnCompletion = YES;

            [self.progressLayer addAnimation:pathAnimation forKey:@"progress"];
        }
    } else {
        self.progressLayer.strokeStart = progress;
        self.progressLayer.strokeEnd = 1.0;
        if (animated) {
            //动画显示进度条
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            pathAnimation.duration = 0.25;
            pathAnimation.fromValue = @(previousProgress);
            pathAnimation.toValue = @(progress);
            pathAnimation.removedOnCompletion = YES;

            [self.progressLayer addAnimation:pathAnimation forKey:@"progress"];
        }
    }
}

@end
