//
//  GKCountDownButton.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/16.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///倒计时按钮
@interface GKCountDownButton : UIButton

/**
 正常时 UIControlStateNormal 按钮背景颜色
 */
@property(nonatomic,strong) UIColor *normalBackgroundColor;

/**
 倒计时 UIControlStateDisable 按钮背景颜色
 */
@property(nonatomic,strong) UIColor *disableBackgroundColor;

/**
 倒计时结束回调
 */
@property(nonatomic,copy) void(^completionHandler)(void);

/**
 倒计时回调 timeLeft 剩余时间
 */
@property(nonatomic,copy) void(^countDownHandler)(NSTimeInterval timeLeft);

/**
 倒计时长 单位秒，default is '60'
 */
@property(nonatomic,assign) int countdownTimeInterval;

/**
 是否正在计时
 */
@property(nonatomic,readonly) BOOL timing;

/**
 开始计时
 */
- (void)startTimer;

/**
 停止计时
 */
- (void)stopTimer;

/**
 初始化
 */
- (void)initialization NS_REQUIRES_SUPER;

///倒计时开始
- (void)onStart NS_REQUIRES_SUPER;

///倒计时完成
- (void)onFinish NS_REQUIRES_SUPER;

@end

