//
//  GKCountDownTimer.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 倒计时没有限制
 */
static const NSTimeInterval GKCountDownInfinite = DBL_MAX;

/**
 倒计时 单位（秒）
 当不使用倒计时，需要自己手动停止倒计时，或者在时间到后会自己停止
 UIView 可在 - (void)willMoveToWindow:newWindow 中，newWindow不为空时开始倒计时，空时结束倒计时
 UIViewController dealloc 时结束倒计时
 */
@interface GKCountDownTimer : NSObject

/**
 倒计时总时间长度，如果为 GKCountDownInfinite 则 没有限制，倒计时不会停止 必须自己手动停止
 设置不同的时间会导致倒计时结束 且不会有回调
 */
@property(nonatomic, assign) NSTimeInterval timeToCountDown;

/**
 倒计时是否马上开始 默认 是 timeInterval 后只需第一次回调
 */
@property(nonatomic, assign) BOOL shouldStartImmediately;

/**
 倒计时间隔
 设置不同的时间会导致倒计时结束 且不会有回调
 */
@property(nonatomic, assign) NSTimeInterval timeInterval;

/**
 当前已进行的倒计时秒数
 */
@property(nonatomic, readonly) NSTimeInterval ongoingTimeInterval;

/**
 倒计时是否正在执行
 */
@property(nonatomic, readonly) BOOL isExcuting;

/**
 触发倒计时回调，timeLeft 剩余倒计时时间
 */
@property(nonatomic, copy) void(^tickHandler)(NSTimeInterval timeLeft);

/**
 倒计时完成回调
 */
@property(nonatomic, copy) void(^completionHandler)(void);

/**
 创建一个倒计时
 
 @param timeToCountDown 倒计时总时间长度
 @param timeInterval 倒计时间隔
 @return 一个实例
 */
+ (instancetype)timerWithTime:(NSTimeInterval) timeToCountDown interval:(NSTimeInterval) timeInterval;

/**
 开始倒计时
 */
- (void)start;

/**
 结束倒计时
 */
- (void)stop;

@end
