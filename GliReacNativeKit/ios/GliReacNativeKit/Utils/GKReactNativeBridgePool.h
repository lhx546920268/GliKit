//
//  GKReactNativeBridgePool.h
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/17.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKReactNativeBridge, RCTBridge;

///获取桥接完成回调 如果bridge = nil，表明加载失败
typedef void(^GKReactNativeFetchBridgeCompletion)(GKReactNativeBridge * _Nullable bridge);

///RN桥接
@interface GKReactNativeBridge : NSObject

///桥接
@property(nonatomic, strong) RCTBridge *bridge;

///版本号
@property(nonatomic, copy) NSString *version;

///rn模块名称
@property(nonatomic, copy) NSString *moduleName;

///是否已加载完基础库
@property(nonatomic, assign) BOOL didLoadBasicJs;

///业务包是否已加载
@property(nonatomic, assign) BOOL didLoadBusinessJs;

///完成回调
@property(nonatomic, copy, nullable) GKReactNativeFetchBridgeCompletion completion;

@end

///RN桥接池
@interface GKReactNativeBridgePool : NSObject

///单例
@property(class, nonatomic, readonly) __kindof GKReactNativeBridgePool *sharedPool;

///document中的基础库URL
@property(nonatomic, copy) NSURL *documentBasicBundleURL;

///在mainBundle 中的基础库URL 如果不为空，会拷贝一份到 documentBasicBundleURL 中，因为服务器下载回来的包要和基础包在同一个目录下，否则图片可能加载不出来
@property(nonatomic, copy) NSURL *mainBasicBundleURL;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

///初始化
- (void)initPool;

/**
 获取一个桥接
 
 @param moduleName rn 模块名称
 @param version 版本号
 @param completion 完成回调
 */
- (void)fetchBridgeWithModuleName:(NSString*) moduleName version:(NSString*) version completion:(GKReactNativeFetchBridgeCompletion) completion;

@end

NS_ASSUME_NONNULL_END
