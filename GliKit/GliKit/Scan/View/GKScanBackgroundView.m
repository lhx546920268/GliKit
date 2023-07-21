//
//  GKScanBackgroundView.m
//  GliKit
//
//  Created by 罗海雄 on 2020/4/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKScanBackgroundView.h"
#import "GKScanBoxView.h"
#import "UIView+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "UIFont+GKTheme.h"
#import "UIScreen+GKUtils.h"
#import "GKBaseDefines.h"

@interface GKScanBackgroundView ()

///扫描动画视图
@property(nonatomic, strong) UIView *animationView;

///部分控制图层，不被扫描的部分会覆盖黑色半透明
@property(nonatomic, strong) UIView *overlayView;

///扫描框
@property(nonatomic, strong) GKScanBoxView *boxView;

@end

@implementation GKScanBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.cornerLineWidth = 5.0;
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.overlayView = UIView.new;
        self.overlayView.alpha = .5f;
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.userInteractionEnabled = NO;
        self.overlayView.opaque = NO;
        [self addSubview:self.overlayView];
        [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        //扫描框大小
        CGFloat x = UIScreen.gkWidth / 6;
        CGFloat width = UIScreen.gkWidth - x * 2;
        _scanBoxSize = CGSizeMake(width, width);
        
        self.boxView = GKScanBoxView.new;
        self.boxView.cornerLineWidth = self.cornerLineWidth;
        [self addSubview:self.boxView];
        [self.boxView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
            make.size.mas_equalTo(CGSizeMake(width + self.cornerLineWidth * 2, width + self.cornerLineWidth * 2));
        }];
        
        CGFloat margin = 10;
        _animationView = UIView.new;
        _animationView.backgroundColor = UIColor.gkThemeColor;
        _animationView.hidden = YES;
        [self.boxView addSubview:_animationView];
        
        [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.mas_equalTo(margin);
            make.trailing.mas_equalTo(-margin);
            make.height.equalTo(@2);
        }];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectMake((self.gkWidth - self.scanBoxSize.width) / 2, (self.gkHeight - self.scanBoxSize.height) / 2, self.scanBoxSize.width, self.scanBoxSize.height);
    if(!CGRectEqualToRect(rect, _scanBoxRect)){
        _scanBoxRect = rect;
        [self overlayClipping];
        !self.scanBoxRectDidChange ?: self.scanBoxRectDidChange(_scanBoxRect);
    }
}

- (void)setCornerLineWidth:(CGFloat)cornerLineWidth
{
    if(_cornerLineWidth != cornerLineWidth){
        _cornerLineWidth = cornerLineWidth;
        self.boxView.cornerLineWidth = cornerLineWidth;
        [self.boxView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
            make.size.mas_equalTo(CGSizeMake(self.scanBoxSize.width + self.cornerLineWidth * 2, self.scanBoxSize.height + self.cornerLineWidth * 2));
        }];
    }
}

- (void)setScanBoxSize:(CGSize)scanBoxSize
{
    if(!CGSizeEqualToSize(_scanBoxSize, scanBoxSize)){
        _scanBoxSize = scanBoxSize;
        _scanBoxRect = CGRectMake((self.gkWidth - self.scanBoxSize.width) / 2, (self.gkHeight - self.scanBoxSize.height) / 2, self.scanBoxSize.width, self.scanBoxSize.height);
        
        [self.boxView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
            make.size.mas_equalTo(CGSizeMake(self.scanBoxSize.width + self.cornerLineWidth * 2, self.scanBoxSize.height + self.cornerLineWidth * 2));
        }];
        [self overlayClipping];
        !self.scanBoxRectDidChange ?: self.scanBoxRectDidChange(_scanBoxRect);
    }
}

- (void)startAnimating
{
    self.backgroundColor = [UIColor clearColor];
    _animationView.hidden = NO;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.repeatCount = HUGE_VALF;
    animation.duration = 1.8;
    animation.fromValue = @(10);
    animation.toValue = @(self.scanBoxSize.height - _animationView.gkHeight);

    [_animationView.layer addAnimation:animation forKey:@"poitionAnimation"];
}

- (void)stopAnimating
{
    self.backgroundColor = [UIColor blackColor];
     _animationView.hidden = YES;
    [_animationView.layer removeAllAnimations];
}

//绘制裁剪区分图层
- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    
    //左边
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.scanBoxRect.origin.x,
                                        self.gkHeight));
    //右边
    CGFloat right = CGRectGetMaxX(self.scanBoxRect);
    CGPathAddRect(path, nil, CGRectMake(right, 0,
                                        self.gkWidth - right,
                                        self.gkHeight));
    //上面
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.gkWidth,
                                        self.scanBoxRect.origin.y));
    //下面
    CGFloat bottom = CGRectGetMaxY(self.scanBoxRect);
    CGPathAddRect(path, nil, CGRectMake(0, bottom,
                                        self.gkWidth,
                                        self.gkHeight - bottom));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}



@end
