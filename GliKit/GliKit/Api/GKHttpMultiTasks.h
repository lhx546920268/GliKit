//
//  GKHttpMultiTasks.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKHttpTask;

///多任务处理
@interface GKHttpMultiTasks : NSObject

///当有一个任务失败时，是否取消所有任务 default `YES`
@property(nonatomic, assign) BOOL shouldCancelAllTaskWhileOneFail;

///是否只标记网络错误 default `NO`
@property(nonatomic, assign) BOOL onlyFlagNetworkError;

///所有任务完成回调 hasFail 是否有任务失败了
@property(nonatomic, copy, nullable) void(^completionHandler)(GKHttpMultiTasks *tasks, BOOL hasFail);

///添加任务 key 为className
- (void)addTask:(GKHttpTask*) task;

/// 添加任务
/// @param task 对应任务 会自动调用 GKHttpTask 的start方法
/// @param key 唯一标识符
- (void)addTask:(GKHttpTask*) task forKey:(NSString*) key;

///开始所有任务
- (void)start;

///串行执行所有任务，按照添加顺序来执行
- (void)startSerially;

///取消所有请求
- (void)cancelAllTasks;

///获取某个请求
- (nullable __kindof GKHttpTask*)taskForKey:(NSString*) key;

@end

NS_ASSUME_NONNULL_END

