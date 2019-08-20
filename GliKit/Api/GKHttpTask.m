//
//  GKHttpTask.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKHttpTask.h"
#import "GKBaseDefines.h"
#import "GKHttpSessionManager.h"
#import "NSDictionary+GKUtils.h"
#import "GKApiConstant.h"

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
        self.loadingHUDDelay = 0.5;
        self.timeoutInterval = 15;
    }
    
    return self;
}

//MARK: 参数

- (nullable NSMutableDictionary*)files
{
    return nil;
}

- (nonnull NSString*)name
{
    if(_name == nil){
        return NSStringFromClass([self class]);
    }
    
    return _name;
}

//MARK: Handler

- (NSURLSessionTask *)URLSessionTask
{
    if(!_URLSessionTask){

        WeakObj(self)
        
        NSString *URLString = [self requestURL];;
        GKHttpSessionManager *manager = [GKHttpSessionManager sharedManager];
        
        NSMutableDictionary *files = [self files];
        if(files.count > 0){
            
            _URLSessionTask = [manager uploadTaskWithURLString:URLString parameters:self.params timeoutInterval:self.timeoutInterval files:files success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [selfWeak processSuccessResult:responseObject];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [selfWeak processError:error];
            }];
            
        }else{
            _URLSessionTask = [manager dataTaskWithHTTPMethod:self.httpMethod == GKHttpMethodGet ? @"GET" : @"POST" URLString:URLString parameters:self.params timeoutInterval:self.timeoutInterval success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                
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
    if([result isKindOfClass:[NSDictionary class]]){
        _data = result;
        _isApiSuccess = [self onLoadData:_data];
        if(_isApiSuccess){
            [self requestDidSuccess];
        }else{
            [self requestDidFail];
        }
    }else{
        [self requestDidFail];
    }
}

///处理请求失败错误
- (void)processError:(NSError*) error
{
    //是自己取消的  因为服务端取消的也会被标记成 NSURLErrorCancelled
    if(self.isCanceled){
        return;
    }
    
    switch (error.code) {
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

//MARK: 状态

- (BOOL)isExecuting
{
    return _URLSessionTask != nil && _URLSessionTask.state == NSURLSessionTaskStateRunning;
}

- (BOOL)isSuspended
{
    return _URLSessionTask != nil && _URLSessionTask.state == NSURLSessionTaskStateSuspended;
}

//MARK: 子类重写 回调

- (void)onStart
{
    [GKSharedTasks() addObject:self];
    if(self.shouldShowloadingHUD){
        if(self.view != nil){
            [self.view gk_showProgressWithText:nil delay:self.loadingHUDDelay];
        }
    }
}

- (void)onSuccess
{
    
}

- (void)onFail
{
    if(self.shouldAlertErrorMsg){
        //服务端错误
        NSString *error = nil;
        switch (_code) {
            case GKHttpCodeFail : {
                error = self.message;
            }
                break;
            case GKHttpCodeTokenOutOfDate : {
                error = self.message;
                [[NSNotificationCenter defaultCenter] postNotificationName:GKUserDidLogoutNotification object:nil];
            }
                break;
            default:
                break;
        }
        
        if([NSString isEmpty:error]){
            error = @"network_error".zegoLocalizedString;
        }
        
        if(self.view){
            [self.view gk_showErrorWithText:error];
        }else{
            [[UIApplication sharedApplication].keyWindow gk_showErrorWithText:error];
        }
    }
}

- (void)onComplete
{
    [self.view gk_dismissProgress];
    if([self.delegate respondsToSelector:@selector(taskDidComplete:)]){
        [self.delegate taskDidComplete:self];
    }
    _URLSessionTask = nil;
    [GKSharedTasks() removeObject:self];
}

//MARK: 外部调用方法

- (void)start
{
    if(self.isExecuting)
        return;
    
    [self onStart];
    [self.URLSessionTask resume];
}

- (void)cancel
{
    if(self.isSuspended || self.isExecuting){
        _isCanceled = YES;
        [_URLSessionTask cancel];
        [self onComplete];
    }
}

//MARK: 内部回调

///请求成功
- (void)requestDidSuccess
{
    [self onSuccess];
    if([self.delegate respondsToSelector:@selector(taskDidSuccess:)]){
        [self.delegate taskDidSuccess:self];
    }
    WeakObj(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        !selfWeak.successHandler ?: selfWeak.successHandler(selfWeak);
        [selfWeak onComplete];
    });
}

///请求失败
- (void)requestDidFail
{
    WeakObj(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        !selfWeak.willFailHandler ?: selfWeak.willFailHandler(selfWeak);
        [selfWeak onFail];
        !selfWeak.failHandler ?: selfWeak.failHandler(selfWeak);
        if([selfWeak.delegate respondsToSelector:@selector(taskDidFail:)]){
            [selfWeak.delegate taskDidFail:self];
        }
        [selfWeak onComplete];
    });
}


@end
