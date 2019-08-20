//
//  GKHttpMultiTasks.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKHttpMultiTasks.h"
#import "GKHttpTask.h"
#import "GKHttpTaskDelegate.h"
#import "GKHttpSessionManager.h"
#import "NSObject+GKUtils.h"
#import <SDWebImageCompat.h>

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

@interface GKHttpMultiTasks()<GKHttpTaskDelegate>

///任务列表
@property(nonatomic, strong) NSMutableArray<GKHttpTask*> *tasks;

///是否有请求失败
@property(nonatomic, assign) BOOL hasFail;

///是否并发执行
@property(nonatomic, assign) BOOL concurrent;

///对应任务
@property(nonatomic, strong) NSMutableDictionary<NSString*, __kindof GKHttpTask*> *taskDictionary;

@end

@implementation GKHttpMultiTasks

- (instancetype)init
{
    self = [super init];
    if(self){
        
        self.tasks = [NSMutableArray array];
        self.taskDictionary = [NSMutableDictionary dictionary];
        self.shouldCancelAllTaskWhileOneFail = YES;
    }
    
    return self;
}

- (void)addTask:(GKHttpTask *)task
{
    [self addTask:task forKey:[task gk_nameOfClass]];
}

- (void)addTask:(GKHttpTask*) task forKey:(NSString *)key
{
    [self.taskDictionary setObject:task forKey:key];
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
    @synchronized (self) {
        for(GKHttpTask *task in self.tasks){
            [task cancel];
        }
        [self.tasks removeAllObjects];
        [self.taskDictionary removeAllObjects];
        
        [GKSharedContainers() removeObject:self];
    }
}

- (__kindof GKHttpTask*)taskForKey:(NSString*) key
{
    return [self.taskDictionary objectForKey:key];
}

///开始任务
- (void)startTask
{
    @synchronized (self) {
        [GKSharedContainers() addObject:self];
        self.hasFail = NO;
        
        if(self.concurrent){
            for(GKHttpTask *task in self.tasks){
                [task start];
            }
        }else{
            [self startNextTask];
        }
    }
}

///开始执行下一个任务 串行时用到
- (void)startNextTask
{
    GKHttpTask *task = [self.tasks firstObject];
    [task start];
}

///删除任务
- (void)task:(GKHttpTask*) task didComplete:(BOOL) success
{
    @synchronized (self) {
        [self.tasks removeObject:task];
    }
    
    if(!success){
        self.hasFail = YES;
        if(self.shouldCancelAllTaskWhileOneFail){
            @synchronized (self) {
                for(GKHttpTask *task in self.tasks){
                    [task cancel];
                }
                [self.tasks removeAllObjects];
            }
        }
    }
    
    if(self.tasks.count == 0){
        !self.completionHandler ?: self.completionHandler(self, self.hasFail);
        [self.taskDictionary removeAllObjects];
        [GKSharedContainers() removeObject:self];
        
    }else if (!self.concurrent){
        [self startNextTask];
    }
}

//MARK: GKHttpTaskDelegate

- (void)taskDidComplete:(__kindof GKHttpTask *)task
{
    dispatch_main_async_safe(^{
        if(!task.isCanceled){
            [self task:task didComplete:task.isApiSuccess || (!task.isNetworkError && self.onlyFlagNetworkError)];
        }
    })
}

@end
