//
//  GKHttpTask.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKHttpTaskDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString* GKHttpMethod NS_EXTENSIBLE_STRING_ENUM;

///get
static GKHttpMethod const GKHttpMethodGet = @"GET";

///post
static GKHttpMethod const GKHttpMethodPost = @"POST";

///翻页起始页
static const int GKHttpFirstPage = 1;

@class UIView;

/**
 单个http请求任务 子类可重写对应的方法
 不需要添加一个属性来保持 strong ，任务开始后会添加到一个全局 队列中
 */
@interface GKHttpTask : NSObject

// MARK: - http参数

///请求超时 秒 default `15s`
@property(nonatomic, assign) NSTimeInterval timeoutInterval;

///默认get
@property(nonatomic, copy) GKHttpMethod httpMethod;

///请求链接
@property(nonatomic, readonly) NSString *requestURL;

///请求参数
@property(nonatomic, readonly, nullable) NSMutableDictionary *params;

///要上传的文件
@property(nonatomic, readonly, nullable) NSMutableDictionary *files;

// MARK: - 状态

///是否正在执行
@property(nonatomic, readonly) BOOL isExecuting;

///是否暂停
@property(nonatomic, readonly) BOOL isSuspended;

///是否是自己取消
@property(nonatomic, readonly) BOOL isCanceled;

// MARK: - 回调

///成功回调
@property(nonatomic, copy, nullable) void(^successHandler)(__kindof GKHttpTask *task);

///将要调用失败回调
@property(nonatomic, copy, nullable) void(^willFailHandler)(__kindof GKHttpTask *task);

///失败回调
@property(nonatomic, copy, nullable) void(^failHandler)(__kindof GKHttpTask *task);

///代理
@property(nonatomic, weak, nullable) id<GKHttpTaskDelegate> delegate;

// MARK: - 结果

///是否是网络错误
@property(nonatomic, readonly) BOOL isNetworkError;

///接口是否请求成功
@property(nonatomic, readonly) BOOL isApiSuccess;

///原始最外层字典
@property(nonatomic, readonly, nullable) NSDictionary *data;

///提示的信息
@property(nonatomic, copy, nullable) NSString *message;

// MARK: - 其他

///请求标识 默认返回类的名称
@property(nonatomic, copy) NSString *name;

///额外信息，用来传值的
@property(nonatomic, strong, nullable) NSDictionary *userInfo;

// MARK: - Loading

///关联的view，用来显示 错误信息，loading
@property(nonatomic, weak, nullable) UIView *view;

///loading 显示延迟 default `0.5`
@property(nonatomic, assign) NSTimeInterval loadingHUDDelay;

///是否要显示loading default `NO`
@property(nonatomic, assign) BOOL shouldShowloadingHUD;

///是否提示错误信息，default `NO`
@property(nonatomic, assign) BOOL shouldAlertErrorMsg;

// MARK: - 子类重写 回调

///请求开始
- (void)onStart NS_REQUIRES_SUPER;

/// 获取到数据
/// @param data 原始字典数据
/// @return 接口是否请求成功
- (BOOL)onLoadData:(nullable NSDictionary*) data;

///请求成功 在这里解析数据，这里是在异步线程调用的
- (void)onSuccess NS_REQUIRES_SUPER;

///请求失败 保证在主线程回调
- (void)onFail NS_REQUIRES_SUPER;

///请求完成 无论是 失败 成功 或者取消
- (void)onComplete NS_REQUIRES_SUPER;

// MARK: - 外部调用方法

///开始
- (void)start NS_REQUIRES_SUPER;

///取消
- (void)cancel NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
