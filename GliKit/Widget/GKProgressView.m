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

@interface GKProgressView ()<CAAnimationDelegate>

///原来的进度
@property(nonatomic,assign) float previousProgress;

///进度条layer
@property(nonatomic,strong) CAShapeLayer *progressLayer;

@end

@implementation GKProgressView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        _style = GKProgressViewStyleStraightLine;
        [self initialization];
    }
    
    return self;
}

- (instancetype)initWithStyle:(GKProgressViewStyle) style
{
    return [self initWithFrame:CGRectZero style:style];
}

- (instancetype)initWithFrame:(CGRect)frame style:(GKProgressViewStyle) style
{
    self = [super initWithFrame:frame];
    if(self){
        _style = style;
        [self initialization];
    }
    
    return self;
}

- (void)initialization
{
    _openProgress = YES;
    _progressColor = [UIColor greenColor];
    _trackColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    switch (_style){
        case GKProgressViewStyleCircle : {
            _progressLineWidth = 10.0;
        }
            break;
        case GKProgressViewStyleRoundCakesFromEmpty : {
            _progressLineWidth = 3.0;
        }
            break;
        default:
            break;
    }
    
    self.clipsToBounds = YES;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.hideAfterFinish = YES;
    self.hideWidthAnimated = YES;
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.progressLayer];
    
    [(CAShapeLayer*)self.layer setFillColor:[UIColor clearColor].CGColor];
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupStyle];
    [self updateProgressLayer];
}

//MARK:- property setup

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
        if(progressColor == nil)
            progressColor = [UIColor greenColor];
        
        _progressColor = progressColor;
        
        [self setupStyle];
        [self updateProgressLayer];
    }
}

- (void)setTrackColor:(UIColor *)trackColor
{
    if(![_trackColor isEqualToColor:trackColor]){
        if(trackColor == nil)
            trackColor = [UIColor clearColor];
        
        _trackColor = trackColor;
        
        [self setupStyle];
        [self updateProgressLayer];
    }
}

- (void)setProgressLineWidth:(CGFloat)progressLineWidth
{
    if(_progressLineWidth != progressLineWidth){
        _progressLineWidth = progressLineWidth;
        [self setupStyle];
        [self updateProgressLayer];
    }
}

- (void)setShowPercent:(BOOL)showPercent
{
    if(_style != GKProgressViewStyleCircle)
        return;
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

- (void)setProgress:(float)progress
{
    if(!_openProgress)
        return;
    if(_progress != progress){
        if(self.hidden){
            self.hidden = NO;
            self.alpha = 1.0;
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
        
        [self updateProgress];
    }
}

///设置样式
- (void)setupStyle
{
    if(CGSizeEqualToSize(self.bounds.size, CGSizeZero))
        return;
    CAShapeLayer *layer = (CAShapeLayer*)self.layer;
    
    switch (_style){
        case GKProgressViewStyleCircle : {
            self.progressLayer.lineWidth = _progressLineWidth;
            self.progressLayer.strokeColor = self.progressColor.CGColor;
            layer.lineWidth = _progressLineWidth;
            layer.strokeColor = _trackColor.CGColor;
        }
            break;
        case GKProgressViewStyleStraightLine : {
            self.progressLayer.strokeColor = self.progressColor.CGColor;
            self.progressLayer.lineWidth = self.bounds.size.width;
            layer.lineWidth = self.bounds.size.height;
            layer.strokeColor = _trackColor.CGColor;
        }
            break;
        case GKProgressViewStyleRoundCakesFromEmpty : {
            self.progressLayer.fillColor = self.progressColor.CGColor;
            layer.strokeColor = _trackColor.CGColor;
            layer.lineWidth = _progressLineWidth;
        }
            break;
        case GKProgressViewStyleRoundCakesFromFull : {
            self.progressLayer.fillColor = self.progressColor.CGColor;
            layer.strokeColor = _trackColor.CGColor;
            layer.lineWidth = _progressLineWidth;
        }
            break;
    }
}

//更新进度条
- (void)updateProgress
{
    switch (_style){
        case GKProgressViewStyleStraightLine :
        case GKProgressViewStyleCircle : {
            if(self.percentLabel){
                self.percentLabel.text = [NSString stringWithFormat:@"%d%%", (int)(_progress * 100)];
            }
            
            self.progressLayer.strokeEnd = _progress;
            
            //动画显示进度条
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            pathAnimation.duration = 0.25;
            pathAnimation.fromValue = @(_previousProgress);
            pathAnimation.toValue = @(_progress);
            pathAnimation.removedOnCompletion = YES;
            
            //进度条圆满隐藏
            if(_progress >= 1.0){
                pathAnimation.delegate = self;
            }
            
            [self.progressLayer addAnimation:pathAnimation forKey:@"progress"];
        }
            break;
        case GKProgressViewStyleRoundCakesFromEmpty : {
            //动画帧数量
            NSInteger frames = ceil(0.25 * 60);
            NSMutableArray *animatedPaths = [NSMutableArray arrayWithCapacity:frames];
            
            //起始弧度 、目标弧度
            CGFloat startAngle = - M_PI_2;
            CGFloat endAngle = - M_PI_2 +  M_PI * 2 * _progress;
            
            //当前最新的弧度
            CGFloat lastAngle = - M_PI_2 +  M_PI * 2 * _previousProgress;
            
            //圆心、半径
            CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
            CGFloat radius = MIN(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
            
            for(NSInteger i = 1;i <= frames;i ++){
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:lastAngle + ((endAngle - lastAngle) / frames * i)clockwise:YES];
                [path addLineToPoint:center];
                [path closePath];
                [animatedPaths addObject:(id)path.CGPath];
            }
            
            //添加动画
            self.progressLayer.path = (__bridge CGPathRef)[animatedPaths lastObject];
            
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
            animation.values = animatedPaths;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            animation.duration = 0.25;
            animation.removedOnCompletion = YES;
            //进度条圆满隐藏
            if(_progress >= 1.0){
                animation.delegate = self;
            }
            [self.progressLayer addAnimation:animation forKey:@"path"];
        }
            break;
        case GKProgressViewStyleRoundCakesFromFull : {
            //动画帧数量
            NSInteger frames = ceil(0.25 * 60);
            NSMutableArray *animatedPaths = [NSMutableArray arrayWithCapacity:frames];
            
            //起始弧度 、目标弧度
            CGFloat startAngle = - M_PI_2;
            CGFloat endAngle = - M_PI_2 +  M_PI * 2 * (1 - _progress);
            
            //当前最新的弧度
            CGFloat lastAngle = - M_PI_2 +  M_PI * 2 * (1 - _previousProgress);
            
            //圆心、半径
            CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
            CGFloat radius = MIN(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
            
            for(NSInteger i = 1;i <= frames;i ++) {
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:lastAngle + ((endAngle - lastAngle) / frames * i)clockwise:YES];
                [path addLineToPoint:center];
                [path closePath];
                [animatedPaths addObject:(id)path.CGPath];
            }
            
            //添加动画
            self.progressLayer.path = (__bridge CGPathRef)[animatedPaths lastObject];
            
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
            animation.values = animatedPaths;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            animation.duration = 0.25;
            animation.removedOnCompletion = YES;
            //进度条圆满隐藏
            if(_progress >= 1.0) {
                animation.delegate = self;
            }
            [self.progressLayer addAnimation:animation forKey:@"path"];
        }
            break;
        default:
            break;
    }
}

//动画结束，隐藏进度条
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(self.hideAfterFinish){
        if(self.hideWidthAnimated){
            [UIView animateWithDuration:0.25 animations:^(void){
                
                self.alpha = 0.0;
            }completion:^(BOOL finsh){
                
                self.hidden = YES;
                [self reset];
            }];
        }else{
            self.hidden = YES;
            [self reset];
        }
    }
}

//MARK:- private method

//重新设置
- (void)reset
{
    _previousProgress = 0;
    _progress = 0;
}

//更新进度条样式
- (void)updateProgressLayer
{
    CGSize size = self.bounds.size;
    if(CGSizeEqualToSize(size, CGSizeZero))
        return;
    UIBezierPath *path = nil;
    
    switch (_style){
        case GKProgressViewStyleStraightLine : {
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, size.height / 2.0)];
            [path addLineToPoint:CGPointMake(size.width, size.height / 2.0)];
        }
            break;
        case GKProgressViewStyleCircle : {
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width / 2.0, size.height / 2.0) radius:MIN(size.width / 2.0, size.height / 2.0) - _progressLineWidth / 2.0 startAngle:-M_PI_2 endAngle:3 * M_PI_2  clockwise:YES];
        }
            break;
        case GKProgressViewStyleRoundCakesFromEmpty :
        case GKProgressViewStyleRoundCakesFromFull : {
            CGPoint point = CGPointMake(size.width / 2.0, size.height / 2.0);
            
            path = [UIBezierPath bezierPath];
            [path addArcWithCenter:point radius:MIN(size.width / 2.0, size.height / 2.0) - _progressLineWidth / 2.0 startAngle:-M_PI_2 endAngle:3 * M_PI_2 clockwise:YES];
            
        }
            break;
    }
    
    if(_style != GKProgressViewStyleRoundCakesFromEmpty && _style != GKProgressViewStyleRoundCakesFromFull) {
        self.progressLayer.path = path.CGPath;
    }
    
    [(CAShapeLayer*)self.layer setPath:path.CGPath];
    [self updateProgress];
}

@end
