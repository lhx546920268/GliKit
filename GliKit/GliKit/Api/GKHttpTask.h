//
//  GKHttpTask.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseTask.h"

NS_ASSUME_NONNULL_BEGIN

///http参数类型
typedef NSMutableDictionary<NSString*, id> GKHttpParameters;

///http要上传的文件
typedef NSMutableDictionary<NSString*, NSString*> GKHttpFiles;

///http请求头
typedef NSMutableDictionary<NSString*, id> GKHttpHeaders;

typedef NSString* GKHttpMethod NS_EXTENSIBLE_STRING_ENUM;

///get
static GKHttpMethod const GKHttpMethodGet = @"GET";

///post
static GKHttpMethod const GKHttpMethodPost = @"POST";

///翻页起始页
static const int GKHttpFirstPage = 1;

/**
 单个http请求任务 子类可重写对应的方法
 不需要添加一个属性来保持 strong ，任务开始后会添加到一个全局 队列中
 */
@interface GKHttpTask : GKBaseTask

///是否暂停
@property(nonatomic, readonly) BOOL isSuspended;

// MARK: - http参数

///请求超时 秒 default `15s`
@property(nonatomic, assign) NSTimeInterval timeoutInterval;

///默认get
@property(nonatomic, copy) GKHttpMethod httpMethod;

///请求链接
@property(nonatomic, readonly) NSString *requestURL;

///请求参数
@property(nonatomic, readonly, nullable) GKHttpParameters *params;

///要上传的文件
@property(nonatomic, readonly, nullable) GKHttpFiles *files;

///请求头 如果同一个字段有多个值，value用数组，否则用字符串
@property(nonatomic, readonly, nullable) GKHttpHeaders *headerFields;

// MARK: - 结果

///是否是网络错误
@property(nonatomic, readonly) BOOL isNetworkError;

///接口是否请求成功
@property(nonatomic, readonly) BOOL isApiSuccess;

///原始最外层字典
@property(nonatomic, readonly, nullable) NSDictionary *data;

/// 获取到数据
/// @param data 原始字典数据
/// @return 接口是否请求成功
- (BOOL)onLoadData:(nullable NSDictionary*) data;

@end

NS_ASSUME_NONNULL_END
