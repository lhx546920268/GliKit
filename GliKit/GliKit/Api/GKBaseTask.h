//
//  GKBaseTask.h
//  GliKit
//
//  Created by xiaozhai on 2023/8/10.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKCancelableTask.h"

NS_ASSUME_NONNULL_BEGIN

///基础任务
@interface GKBaseTask : NSObject<GKCancelableTask>

// MARK: - Loading

///提示的信息
@property(nonatomic, copy, nullable) NSString *message;

///关联的view，用来显示 错误信息，loading
@property(nonatomic, weak, nullable) UIView *view;

///loading 显示延迟 default `0.5`
@property(nonatomic, assign) NSTimeInterval loadingToastDelay;

///是否要显示loading default `NO`
@property(nonatomic, assign) BOOL shouldShowloadingToast;

///是否提示错误信息，default `NO`
@property(nonatomic, assign) BOOL shouldAlertErrorMessage;

// MARK: - 状态

///是否正在执行
@property(nonatomic, readonly) BOOL isExecuting;

///是否是自己取消
@property(nonatomic, readonly) BOOL isCancelled;

///是否已完成
@property(nonatomic, readonly) BOOL isCompleted;

// MARK: - 回调

///成功回调
@property(nonatomic, copy, nullable) void(^successHandler)(__kindof GKBaseTask *task);

///将要调用失败回调
@property(nonatomic, copy, nullable) void(^willFailHandler)(__kindof GKBaseTask *task);

///失败回调
@property(nonatomic, copy, nullable) void(^failHandler)(__kindof GKBaseTask *task);

// MARK: - 其他

///请求标识 默认返回类的名称
@property(nonatomic, copy, null_resettable) NSString *name;

///额外信息，用来传值的
@property(nonatomic, strong, nullable) NSDictionary *userInfo;

///是否是数据解析失败
@property(nonatomic, readonly) BOOL isDataParseFail;

// MARK: - 子类重写 回调

///请求开始
- (void)onStart NS_REQUIRES_SUPER;

///请求失败 保证在主线程回调
- (void)onFail NS_REQUIRES_SUPER;

///请求完成 无论是 失败 成功 或者取消
- (void)onComplete NS_REQUIRES_SUPER;

///请求成功 在这里解析数据，可能在异步线程调用的
- (void)onSuccess NS_REQUIRES_SUPER;

///子类重写这个来开始子类的任务
- (void)startSafe;
- (void)cancelSafe;

// MARK: - 外部调用方法

///开始
- (void)start NS_REQUIRES_SUPER;

///取消
- (void)cancel NS_REQUIRES_SUPER;

///使用锁
- (void)runWithLock:(void(^)(void)) block;

// MARK: - 以下方法仅供子类使用，用来改变任务的状态，外部调用要谨慎

///请求成功
- (void)requestDidSuccess;

///数据解析失败了 一般是onSuccess 那里抛出异常 这里是在可能在异步线程调用的
- (void)onDataParseFail;

///请求失败
- (void)requestDidFail;

@end

NS_ASSUME_NONNULL_END
