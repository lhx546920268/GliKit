//
//  GKCountDownButton.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/16.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKCountDownButton.h"
#import "GKCountDownTimer.h"

@interface GKCountDownButton ()

///计时器
@property(nonatomic, strong) GKCountDownTimer *timer;

@end

@implementation GKCountDownButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialization];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self initialization];
    }
    return self;
}

- (void)dealloc
{
    [self.timer stop];
}

/**
 初始化
 */
- (void)initialization
{
    self.countdownTimeInterval = 60;
    self.normalBackgroundColor = [UIColor clearColor];
    self.disableBackgroundColor = [UIColor clearColor];
    [self setTitleColor:UIColor.appThemeColor forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont appFontWithSize:14];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.layer.borderColor = UIColor.appThemeColor.CGColor;
    
    [self setTitle:@"get_sms_code".zegoLocalizedString forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
}

//MARK:- property

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor
{
    if(![_normalBackgroundColor isEqualToColor:normalBackgroundColor]){
        if(normalBackgroundColor == nil)
            normalBackgroundColor = UIColor.appThemeColor;
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
            disableBackgroundColor = UIColor.appThemeColor;
        _disableBackgroundColor = disableBackgroundColor;
        if(self.timing){
            self.backgroundColor = _disableBackgroundColor;
        }
    }
}

//MARK:- 计时器

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

/**
 停止计时
 */
- (void)stopTimer
{
    if(self.timing){
        [self.timer stop];
        [self onFinish];
    }
}

- (void)countDown:(NSTimeInterval) timeLeft
{
    [self setTitle:[NSString stringWithFormat:@"%@(%ds)", @"reacquire".zegoLocalizedString, (int)timeLeft] forState:UIControlStateDisabled];
    !self.countDownHandler ?: self.countDownHandler(timeLeft);
}

///倒计时开始
- (void)onStart
{
    self.enabled = NO;
    self.backgroundColor = self.disableBackgroundColor;
    self.layer.borderColor = self.currentTitleColor.CGColor;
}

///倒计时完成
- (void)onFinish
{
    [self setTitle:@"reacquire".zegoLocalizedString forState:UIControlStateNormal];
    self.enabled = YES;
    self.backgroundColor = self.normalBackgroundColor;
    self.layer.borderColor = self.currentTitleColor.CGColor;
    !self.completionHandler ?: self.completionHandler();
}

@end
