//
//  GKCountDownTimer.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKCountDownTimer.h"
#import <UIKit/UIKit.h>
#import "GKWeakProxy.h"
#import "GKLock.h"

@interface GKCountDownTimer()

///倒计时停止时间
@property(nonatomic, assign) NSTimeInterval timeToStop;

///倒计时是否已取消
@property(nonatomic, assign) BOOL isCancelled;

///倒计时
@property(nonatomic, strong) NSTimer *timer;

///app 停止时间
@property(nonatomic, strong) NSDate *date;

///代理
@property(nonatomic, strong) GKWeakProxy *weakProxy;

///锁
@property(nonatomic, strong) GKLock *lock;

@end

@implementation GKCountDownTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [GKLock new];
    }
    return self;
}

+ (instancetype)timerWithTime:(NSTimeInterval) timeToCountDown interval:(NSTimeInterval) timeInterval
{
    GKCountDownTimer *timer = [GKCountDownTimer new];
    timer.timeToCountDown = timeToCountDown;
    timer.timeInterval = timeInterval;
    
    return timer;
}

+ (instancetype)foreverTimerWithInterval:(NSTimeInterval)timeInterval
{
    return [self timerWithTime:GKCountDownInfinite interval:timeInterval];
}

- (void)dealloc
{
    [self stopTimer];
    [self removeNotifications];
}

// MARK: - property

- (void)setTimeToCountDown:(NSTimeInterval)timeToCountDown
{
    if(_timeToCountDown != timeToCountDown){
        _timeToCountDown = timeToCountDown;
        [self stop];
    }
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    if(_timeInterval != timeInterval){
        _timeInterval = timeInterval;
        [self stop];
    }
}

// MARK: - timer

- (void)start
{
    [self.lock lock];
    if(!_isExcuting){
        _isCancelled = NO;
        _ongoingTimeInterval = 0;
        if(self.timeToCountDown <= 0 || self.timeInterval <= 0){
            [self finish];
        }else{
            self.timeToStop = self.timeToCountDown;
            _isExcuting = YES;
            if(self.shouldStartImmediately){
                [self timerFired];
            }
            
            if(_isExcuting){
                [self startTimer];
            }
        }
    }
    [self.lock unlock];
}

///开始计时器
- (void)startTimer
{
    [self stopTimer];
    [self addNotifications];
    
    if(!self.weakProxy){
        self.weakProxy = [GKWeakProxy weakProxyWithTarget:self];
    }
    self.timer = [NSTimer timerWithTimeInterval:self.timeInterval target:self.weakProxy selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop
{
    [self.lock lock];
    if(_isExcuting && !_isCancelled){
        _isCancelled = YES;
        [self stopTimer];
    }
    [self.lock unlock];
}

///停止计时器
- (void)stopTimer
{
    if(self.timer && [self.timer isValid]){
        [self removeNotifications];
        [self.timer invalidate];
        self.timer = nil;
        _isExcuting = NO;
    }
}

///计时器触发
- (void)timerFired
{
    if(_isExcuting){
        _ongoingTimeInterval += self.timeInterval;
        if(self.timeToCountDown == GKCountDownInfinite){
            !self.tickHandler ?: self.tickHandler(GKCountDownInfinite);
        }else{
            self.timeToStop = self.timeToStop - self.timeInterval;
            if(self.timeToStop <= 0){
                [self finish];
            }else{
                !self.tickHandler ?: self.tickHandler(self.timeToStop);
            }
        }
    }
}

///倒计时完成
- (void)finish
{
    [self removeNotifications];
    [self stopTimer];
    !self.completionHandler ?: self.completionHandler();
}

// MARK: - 通知

///添加通知 app进入后台 手机锁屏后 来电 计时器会停止
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

///移除通知
- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(NSNotification*) notification
{
    self.date = [NSDate date];
}

- (void)applicationDidBecomeActive:(NSNotification*) notification
{
    ///app 唤醒
    if(self.date){
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.date];
        
        if(self.timeToCountDown == GKCountDownInfinite){
            if(timeInterval >= self.timeInterval){
                !self.tickHandler ?: self.tickHandler(GKCountDownInfinite);
            }
        }else{
            self.timeToStop -= timeInterval;
            if(self.timeToStop <= 0){
                [self finish];
            }else if(timeInterval >= self.timeInterval){
                !self.tickHandler ?: self.tickHandler(self.timeToStop);
            }
        }
        self.date = nil;
    }
}

@end
