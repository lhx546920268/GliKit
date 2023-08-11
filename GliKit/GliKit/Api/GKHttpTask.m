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
#import "SDWebImageCompat.h"
#import "GKLock.h"
#import "GKTaskDelegate.h"

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

@interface GKHttpTask()

///当前任务
@property(nonatomic, readonly) NSURLSessionTask *URLSessionTask;

@end

@implementation GKHttpTask

@synthesize URLSessionTask = _URLSessionTask;

- (instancetype)init
{
    self = [super init];
    if(self){
        self.timeoutInterval = 15;
    }
    
    return self;
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

- (BOOL)isSuspended
{
    return _URLSessionTask != nil && _URLSessionTask.state == NSURLSessionTaskStateSuspended;
}

// MARK: - 子类重写 回调

- (void)onStart
{
    [super onStart];
    [GKSharedTasks() addObject:self];
}

- (BOOL)onLoadData:(NSDictionary *)data
{
    return YES;
}

- (void)onComplete
{
    [super onComplete];
    _URLSessionTask = nil;
    [GKSharedTasks() removeObject:self];
}

// MARK: - 外部调用方法

- (void)startSafe
{
    [self.URLSessionTask resume];
    if (!self.URLSessionTask) {
        [self processError:[NSError errorWithDomain:@"GKHttpURLSesstionError" code:0 userInfo:nil]];
    }
}

- (void)cancelSafe
{
    if(self.isSuspended || self.isExecuting){
        [_URLSessionTask cancel];
    }
}

@end
