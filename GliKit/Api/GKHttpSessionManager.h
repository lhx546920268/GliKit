//
//  GKHttpSessionManager.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <AFHTTPSessionManager.h>

///默认的api请求管理
@interface GKHttpSessionManager : AFHTTPSessionManager

///单例
+ (instancetype)sharedManager;

///http请求
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString 
                                      parameters:(id)parameters
                                 timeoutInterval:(NSTimeInterval) timeoutInterval
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

///http请求 上传文件用的
- (NSURLSessionDataTask *)uploadTaskWithURLString:(NSString *)URLString
                                       parameters:(id)parameters
                                  timeoutInterval:(NSTimeInterval) timeoutInterval
                                            files:(NSMutableDictionary<NSString*, NSString*>*) files
                                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

