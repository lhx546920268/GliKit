//
//  GKHttpSessionManager.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKHttpSessionManager.h"
#import "GKTaskDelegate.h"
#import "GKFileManager.h"

@interface GKHttpSessionManager()

///异步线程返回 有些解析可能比较耗时
@property(nonatomic, strong) dispatch_queue_t customCompletionQueue;

///json 请求body
@property(nonatomic, strong) AFJSONRequestSerializer *JSONRequestSerializer;

@end

@implementation GKHttpSessionManager

+ (instancetype)sharedManager
{
    static GKHttpSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GKHttpSessionManager new];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        self.requestSerializer.timeoutInterval = 15;
        self.customCompletionQueue = dispatch_queue_create("com.glikit.http.customCompletionQueue", DISPATCH_QUEUE_CONCURRENT);
        self.completionQueue = self.customCompletionQueue;
    }
    
    return self;
}

- (AFJSONRequestSerializer *)JSONRequestSerializer
{
    if(!_JSONRequestSerializer){
        _JSONRequestSerializer = AFJSONRequestSerializer.new;
        _JSONRequestSerializer.timeoutInterval = 15;
    }
    
    return _JSONRequestSerializer;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                    headerFields:(NSDictionary*) headerFields
                                 timeoutInterval:(NSTimeInterval) timeoutInterval
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.JSONRequestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    [self addHeaderFields:headerFields forRequest:request];
    request.timeoutInterval = timeoutInterval;
    
    NSLog(@"请求参数 %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:nil
                        downloadProgress:nil
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (error) {
                               if (failure) {
                                   failure(dataTask, error);
                               }
                           } else {
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                       }];
    
    return dataTask;
}

- (NSURLSessionDataTask *)uploadTaskWithURLString:(NSString *)URLString
                                       parameters:(id)parameters
                                     headerFields:(NSDictionary*) headerFields
                                  timeoutInterval:(NSTimeInterval) timeoutInterval
                                            files:(NSMutableDictionary<NSString*, NSString*>*)files
                                          success:(void (^)(NSURLSessionDataTask *, id))success
                                          failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for(NSString *key in files){
            NSString *filePath = files[key];
            NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
            [formData appendPartWithFileData:data name:key fileName:filePath.lastPathComponent mimeType:[GKFileManager mimeTypeForFileAtPath:filePath]];
        }
        
    } error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    [self addHeaderFields:headerFields forRequest:request];
    request.timeoutInterval = timeoutInterval;
    
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    return task;
}

- (void)addHeaderFields:(NSDictionary*) headerFields forRequest:(NSMutableURLRequest*) request
{
    //请求头
    for(NSString *key in headerFields){
        id value = headerFields[key];
        if([value isKindOfClass:NSArray.class]){
            NSArray *array = (NSArray*)value;
            for(NSString *multiValue in array){
                [request addValue:multiValue forHTTPHeaderField:key];
            }
        } else {
            [request addValue:value forHTTPHeaderField:key];
        }
    }
}

@end
