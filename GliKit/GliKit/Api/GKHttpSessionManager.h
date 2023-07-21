//
//  GKHttpSessionManager.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

///默认的api请求管理
@interface GKHttpSessionManager : AFHTTPSessionManager

///单例
+ (instancetype)sharedManager;

///http请求
- (nullable NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString 
                                      parameters:(nullable id)parameters
                                    headerFields:(NSDictionary*) headerFields
                                 timeoutInterval:(NSTimeInterval) timeoutInterval
                                         success:(nullable void (^)(NSURLSessionDataTask *, id))success
                                         failure:(nullable void (^)(NSURLSessionDataTask *, NSError *))failure;

///http请求 上传文件用的
- (nullable NSURLSessionDataTask *)uploadTaskWithURLString:(NSString *)URLString
                                       parameters:(nullable id)parameters
                                     headerFields:(NSDictionary*) headerFields
                                  timeoutInterval:(NSTimeInterval) timeoutInterval
                                            files:(nullable NSMutableDictionary<NSString*, NSString*>*) files
                                          success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                                          failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
