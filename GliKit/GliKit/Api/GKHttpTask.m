//
//  GKHttpTask.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKHttpTask.h"
#import "GKBaseDefines.h"
#import "GKHttpSessionManager.h"
#import "NSDictionary+GKUtils.h"
#import "UIView+GKLoading.h"
#import <SDWebImageCompat.h>
#import "GKLock.h"
#import "GKHttpTaskDelegate.h"

///保存请求队列的单例
static NSMutableSet* GKSharedTasks()
{
    static NSMutableSet *sharedTasks = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTasks = [NSMutableSet set];
    });
    
    return sharedTasks;
}

///http任务状态
typedef NS_ENUM(NSInteger, GKHttpTaskState) {
    
    ///准备中
    GKHttpTaskStateReady,
    
    ///运行中
    GKHttpTaskStateExecuting,
    
    ///已完成
    GKHttpTaskStateCompleted,
    
    ///已取消
    GKHttpTaskStateCancelled,
};

@interface GKHttpTask()

///当前任务
@property(nonatomic, readonly) NSURLSessionTask *URLSessionTask;

///锁
@property(nonatomic, strong) GKLock *lock;

///状态
@property(nonatomic, assign) GKHttpTaskState state;

///代理
@property(nonatomic, weak, nullable) id<GKHttpTaskDelegate> delegate;

@end

@implementation GKHttpTask

@synthesize URLSessionTask = _URLSessionTask;

- (instancetype)init
{
    self = [super init];
    if(self){
        self.loadingToastDelay = 0.5;
        self.timeoutInterval = 15;
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
        return NSStringFromClass(self.class);
    }
    
    return _name;
}

// MARK: - Handler

- (NSURLSessionTask*)URLSessionTask
{
    if(!_URLSessionTask){

        WeakObj(self)
        
        NSString *URLString = [self requestURL];;
        GKHttpSessionManager *manager = [GKHttpSessionManager sharedManager];
        
        GKHttpFiles *files = [self files];
        if(files.count > 0){
            
            _URLSessionTask = [manager uploadTaskWithURLString:URLString
                                                    parameters:self.params
                                                  headerFields:self.headerFields
                                               timeoutInterval:self.timeoutInterval
                                                         files:files
                                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [selfWeak processSuccessResult:responseObject];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [selfWeak processError:error];
            }];
        }else{
            _URLSessionTask = [manager dataTaskWithHTTPMethod:self.httpMethod
                                                    URLString:URLString
                                                   parameters:self.params
                                                 headerFields:self.headerFields
                                              timeoutInterval:self.timeoutInterval
                                                      success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                
                [selfWeak processSuccessResult:responseObject];
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                
                [selfWeak processError:error];
            }];
        }
    }
    return _URLSessionTask;
}

///处理http请求请求成功的结果
- (void)processSuccessResult:(NSDictionary*) result
{
    if ([result isKindOfClass:NSDictionary.class]) {
        _data = result;
        _isApiSuccess = [self onLoadData:_data];
        if (_isApiSuccess) {
            [self requestDidSuccess];
        } else{
            [self requestDidFail];
        }
    } else {
        [self requestDidFail];
    }
}

///处理请求失败错误
- (void)processError:(NSError*) error
{
    //是自己取消的  因为服务端取消的也会被标记成 NSURLErrorCancelled
    if (self.isCancelled) {
        return;
    }
    
    switch (error.code) {
        case NSURLErrorInternationalRoamingOff :
        case NSURLErrorTimedOut :
        case NSURLErrorCannotFindHost :
        case NSURLErrorCannotConnectToHost :
        case NSURLErrorNetworkConnectionLost :
        case NSURLErrorNotConnectedToInternet : {
                _isNetworkError = YES;
            }
            break;
        default:
            break;
    }
    
    [self requestDidFail];
}

// MARK: - 状态

- (BOOL)isExecuting
{
    return self.state == GKHttpTaskStateExecuting;
}

- (BOOL)isSuspended
{
    return _URLSessionTask != nil && _URLSessionTask.state == NSURLSessionTaskStateSuspended;
}

- (BOOL)isCancelled
{
    return self.state == GKHttpTaskStateCancelled;
}

- (BOOL)isCompleted
{
    return self.state == GKHttpTaskStateCompleted;
}

// MARK: - 子类重写 回调

- (void)onStart
{
    [GKSharedTasks() addObject:self];
    if(self.shouldShowloadingToast){
        [UIApplication.sharedApplication.keyWindow endEditing:YES];
        if(self.view != nil){
            [self.view gkShowLoadingToastWithText:nil delay:self.loadingToastDelay];
        }
    }
}

- (BOOL)onLoadData:(NSDictionary *)data
{
    return YES;
}

- (void)onSuccess{}

- (void)onFail{}

- (void)onComplete
{
    if([self.delegate respondsToSelector:@selector(taskDidComplete:)]){
        [self.delegate taskDidComplete:self];
    }
    
    [self.view gkDismissLoadingToast];
    _URLSessionTask = nil;
    [GKSharedTasks() removeObject:self];
}

// MARK: - 外部调用方法

- (void)start
{
    [self.lock lock];
    if(self.state == GKHttpTaskStateReady) {
        self.state = GKHttpTaskStateExecuting;
        [self onStart];
        [self.URLSessionTask resume];
        if (!self.URLSessionTask) {
            [self processError:[NSError errorWithDomain:@"GKHttpURLSesstionError" code:0 userInfo:nil]];
        }
    }
    [self.lock unlock];
}

- (void)cancel
{
    [self.lock lock];
    if(!self.isCancelled && !self.isCompleted){
        self.state = GKHttpTaskStateCancelled;
        if(self.isSuspended || self.isExecuting){
            [_URLSessionTask cancel];
        }
        [self onComplete];
    }
    [self.lock unlock];
}

// MARK: - 内部回调

///请求成功
- (void)requestDidSuccess
{
    [self onSuccess];
    if([self.delegate respondsToSelector:@selector(taskDidSuccess:)]){
        [self.delegate taskDidSuccess:self];
    }
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
            self.state = GKHttpTaskStateCompleted;
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
            self.state = GKHttpTaskStateCompleted;
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
