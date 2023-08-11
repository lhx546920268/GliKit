//
//  GKBaseTask.m
//  GliKit
//
//  Created by xiaozhai on 2023/8/10.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKBaseTask.h"
#import "GKLock.h"
#import "UIView+GKLoading.h"
#import "GKTaskDelegate.h"
#import "GKBaseDefines.h"
#import "GKHttpSessionManager.h"
#import "NSDictionary+GKUtils.h"
#import "UIView+GKLoading.h"
#import "SDWebImageCompat.h"
#import "GKLock.h"
#import "GKTaskDelegate.h"

///http任务状态
typedef NS_ENUM(NSInteger, GKTaskState) {
    
    ///准备中
    GKTaskStateReady,
    
    ///运行中
    GKTaskStateExecuting,
    
    ///已完成
    GKTaskStateCompleted,
    
    ///已取消
    GKTaskStateCancelled,
};

@interface GKBaseTask ()

///状态
@property(nonatomic, assign) GKTaskState state;

///锁
@property(nonatomic, strong) GKLock *lock;

///代理
@property(nonatomic, weak, nullable) id<GKTaskDelegate> delegate;

@end

@implementation GKBaseTask

- (instancetype)init
{
    self = [super init];
    if(self){
        self.loadingToastDelay = 0.5;
        self.lock = [GKLock new];
    }
    
    return self;
}

- (NSString *)taskKey
{
    return self.name;
}

- (NSString*)name
{
    if(_name == nil){
        _name = NSStringFromClass(self.class);
    }
    
    return _name;
}

// MARK: - 状态

- (BOOL)isExecuting
{
    return self.state == GKTaskStateExecuting;
}

- (BOOL)isCancelled
{
    return self.state == GKTaskStateCancelled;
}

- (BOOL)isCompleted
{
    return self.state == GKTaskStateCompleted;
}

// MARK: - 子类重写 回调

- (void)onStart
{
    if(self.shouldShowloadingToast){
        [UIApplication.sharedApplication.keyWindow endEditing:YES];
        if(self.view != nil){
            [self.view gkShowLoadingToastWithText:nil delay:self.loadingToastDelay];
        }
    }
}

- (void)onSuccess{}

- (void)onFail{}

- (void)onComplete
{
    if([self.delegate respondsToSelector:@selector(taskDidComplete:)]){
        [self.delegate taskDidComplete:self];
    }
    
    [self.view gkDismissLoadingToast];
}

// MARK: - 外部方法

- (void)start
{
    [self.lock lock];
    if(self.state == GKTaskStateReady) {
        self.state = GKTaskStateExecuting;
        [self onStart];
        [self startSafe];
    }
    [self.lock unlock];
}

- (void)startSafe{}

- (void)cancel
{
    [self.lock lock];
    if(!self.isCancelled && !self.isCompleted){
        self.state = GKTaskStateCancelled;
        [self cancelSafe];
        [self onComplete];
    }
    [self.lock unlock];
}

- (void)cancelSafe{}

- (void)runWithLock:(void (^)(void))block
{
    [self.lock lock];
    block();
    [self.lock unlock];
}

// MARK: - 内部回调

///请求成功
- (void)requestDidSuccess
{
    //防止解析错误
    @try {
        [self onSuccess];
        if([self.delegate respondsToSelector:@selector(taskDidSuccess:)]){
            [self.delegate taskDidSuccess:self];
        }
    } @catch (NSException *exception) {
        _isDataParseFail = YES;
        [self onDataParseFail];
        [self requestDidFail];
        return;
    }
    
    dispatch_main_async_safe(^{
        [self.lock lock];
        if(!self.isCancelled){
            self.state = GKTaskStateCompleted;
            !self.successHandler ?: self.successHandler(self);
            [self onComplete];
        }
        [self.lock unlock];
    })
}

- (void)onDataParseFail{}

///请求失败
- (void)requestDidFail
{
    dispatch_main_async_safe(^{
        [self.lock lock];
        if(!self.isCancelled){
            self.state = GKTaskStateCompleted;
            !self.willFailHandler ?: self.willFailHandler(self);
            [self onFail];
            !self.failHandler ?: self.failHandler(self);
            if([self.delegate respondsToSelector:@selector(taskDidFail:)]){
                [self.delegate taskDidFail:self];
            }
            [self onComplete];
        }
        [self.lock unlock];
    })
}


@end
