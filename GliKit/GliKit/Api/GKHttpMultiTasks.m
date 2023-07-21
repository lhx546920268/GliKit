//
//  GKHttpMultiTasks.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKHttpMultiTasks.h"
#import "GKHttpTask.h"
#import "GKHttpTaskDelegate.h"
#import "GKHttpSessionManager.h"
#import "NSObject+GKUtils.h"
#import "SDWebImageCompat.h"
#import "GKLock.h"

///保存请求队列的单例
static NSMutableSet* GKSharedContainers()
{
    static NSMutableSet *sharedContainers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContainers = [NSMutableSet set];
    });
    
    return sharedContainers;
}

@interface GKHttpTask(GKPrivate)

///代理
@property(nonatomic, weak, nullable) id<GKHttpTaskDelegate> delegate;

@end

@interface GKHttpMultiTasks()<GKHttpTaskDelegate>

///任务列表
@property(nonatomic, strong) NSMutableArray<GKHttpTask*> *tasks;

///是否并发执行
@property(nonatomic, assign) BOOL concurrent;

///对应任务
@property(nonatomic, strong) NSMutableDictionary<NSString*, __kindof GKHttpTask*> *taskDictionary;

///锁
@property(nonatomic, strong) GKLock *lock;

///uuid
@property(nonatomic, copy) NSString *uuid;

@end

@implementation GKHttpMultiTasks

- (instancetype)init
{
    self = [super init];
    if(self){
        
        self.tasks = [NSMutableArray array];
        self.taskDictionary = [NSMutableDictionary dictionary];
        self.shouldCancelAllTaskWhileOneFail = YES;
        self.lock = [GKLock new];
    }
    
    return self;
}

- (NSString *)uuid
{
    if (!_uuid) {
        _uuid = NSUUID.UUID.UUIDString;
    }
    return _uuid;
}

- (void)addTask:(GKHttpTask *)task
{
    [self addTask:task forKey:task.gkNameOfClass];
}

- (void)addTask:(GKHttpTask*) task forKey:(NSString *)key
{
    NSParameterAssert(task != nil);
    NSParameterAssert(key != nil);
    
    self.taskDictionary[key] = task;
    [self.tasks addObject:task];
    task.delegate = self;
}

- (void)start
{
    self.concurrent = YES;
    [self startTask];
}

- (void)startSerially
{
    self.concurrent = NO;
    [self startTask];
}

- (void)cancelAllTasks
{
    [self.lock lock];
    if(_isExecuting){
        _isExecuting = NO;
        for(GKHttpTask *task in self.tasks){
            [task cancel];
        }
        [self.tasks removeAllObjects];
        [self.taskDictionary removeAllObjects];
        
        [GKSharedContainers() removeObject:self];
    }
    [self.lock unlock];
}

- (__kindof GKHttpTask*)taskForKey:(NSString*) key
{
    return self.taskDictionary[key];
}

///开始任务
- (void)startTask
{
    NSAssert(self.tasks.count > 0, @"%@ 至少有一个任务", self.gkNameOfClass);
    [self.lock lock];
    if(!_isExecuting){
        _isExecuting = YES;
        [GKSharedContainers() addObject:self];
        _hasFail = NO;
        
        if(self.concurrent){
            for(GKHttpTask *task in self.tasks){
                [task start];
            }
        }else{
            [self startNextTaskIfNeeded:nil];
        }
    }
    
    [self.lock unlock];
}

///开始执行下一个任务 串行时用到
- (void)startNextTaskIfNeeded:(GKHttpTask*) currentTask
{
    GKHttpTask *task = nil;
    if(self.tasks.count > 0){
        task = [self.tasks firstObject];
    }else if(self.nextTaskHandler != nil){
        task = self.nextTaskHandler(currentTask);
    }
    
    if(task){
        [task start];
    }else{
        [self onComplete];
    }
}

///删除任务
- (void)task:(GKHttpTask*) task didComplete:(BOOL) success
{
    [self.lock lock];
    [self.tasks removeObject:task];
    
    if(!success){
        _hasFail = YES;
        if(self.shouldCancelAllTaskWhileOneFail){
            for(GKHttpTask *task in self.tasks){
                [task cancel];
            }
            [self.tasks removeAllObjects];
        }
    }
    
    if (!self.concurrent){
        [self startNextTaskIfNeeded:task];
    } else if(self.tasks.count == 0){
        [self onComplete];
    }
    [self.lock unlock];
}

- (void)onComplete
{
    _isExecuting = NO;
    !self.completionHandler ?: self.completionHandler(self);
    [self.taskDictionary removeAllObjects];
    [GKSharedContainers() removeObject:self];
}

// MARK: - GKHttpTaskDelegate

- (void)taskDidComplete:(__kindof GKHttpTask *)task
{
    dispatch_main_async_safe(^{
        if(!task.isCancelled){
            [self task:task didComplete:task.isApiSuccess || (!task.isNetworkError && self.onlyFlagNetworkError)];
        }
    })
}

// MARK: - GKCancelableTask

- (NSString *)taskKey
{
    return self.uuid;
}

- (void)cancel
{
    [self cancelAllTasks];
}

@end
