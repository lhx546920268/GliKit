//
//  GKCountDownButton.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKCountDownButton.h"
#import "GKCountDownTimer.h"
#import "UIApplication+GKTheme.h"
#import "UIColor+GKTheme.h"
#import "UIColor+GKUtils.h"
#import "GKBaseDefines.h"

@interface GKCountDownButton ()

///计时器
@property(nonatomic, strong) GKCountDownTimer *timer;

@end

@implementation GKCountDownButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initProps];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self initProps];
    }
    return self;
}

- (void)dealloc
{
    [self.timer stop];
}

- (void)initProps
{
    self.countdownTimeInterval = 60;
    self.normalBackgroundColor = [UIColor clearColor];
    self.disableBackgroundColor = [UIColor clearColor];
    [self setTitleColor:UIColor.gkThemeColor forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.layer.borderColor = UIColor.gkThemeColor.CGColor;
    
    [self setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
}

// MARK: - property

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor
{
    if(![_normalBackgroundColor isEqualToColor:normalBackgroundColor]){
        if(normalBackgroundColor == nil)
            normalBackgroundColor = UIColor.gkThemeColor;
        _normalBackgroundColor = normalBackgroundColor;
        if(!self.timing){
            self.backgroundColor = _normalBackgroundColor;
        }
    }
}

- (void)setDisableBackgroundColor:(UIColor *)disableBackgroundColor
{
    if(![_disableBackgroundColor isEqualToColor:disableBackgroundColor]){
        if(disableBackgroundColor == nil)
            disableBackgroundColor = UIColor.gkThemeColor;
        _disableBackgroundColor = disableBackgroundColor;
        if(self.timing){
            self.backgroundColor = _disableBackgroundColor;
        }
    }
}

// MARK: - 计时器

- (BOOL)timing
{
    return self.timer.isExcuting;
}

- (void)startTimer
{
    if(!self.timer){
        WeakObj(self);
        self.timer = [GKCountDownTimer timerWithTime:self.countdownTimeInterval interval:1];
        self.timer.shouldStartImmediately = YES;
        self.timer.completionHandler = ^(void){
            [selfWeak onFinish];
        };
        self.timer.tickHandler = ^(NSTimeInterval timeLeft){
            [selfWeak countDown:timeLeft];
        };
    }
    [self.timer start];
    [self onStart];
}

- (void)stopTimer
{
    if(self.timing){
        [self.timer stop];
        [self onFinish];
    }
}

- (void)countDown:(NSTimeInterval) timeLeft
{
    [self setTitle:[NSString stringWithFormat:@"重新获取(%ds)", (int)timeLeft] forState:UIControlStateDisabled];
    !self.countDownHandler ?: self.countDownHandler(timeLeft);
}

- (void)onStart
{
    self.enabled = NO;
    self.backgroundColor = self.disableBackgroundColor;
    self.layer.borderColor = self.currentTitleColor.CGColor;
}

- (void)onFinish
{
    [self setTitle:@"重新获取" forState:UIControlStateNormal];
    self.enabled = YES;
    self.backgroundColor = self.normalBackgroundColor;
    self.layer.borderColor = self.currentTitleColor.CGColor;
    !self.completionHandler ?: self.completionHandler();
}

@end
