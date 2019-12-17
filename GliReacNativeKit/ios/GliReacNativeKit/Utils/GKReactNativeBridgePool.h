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

//RN桥接
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
@property(nonatomic, copy) GKReactNativeFetchBridgeCompletion completion;

@end

//RN桥接池
@interface GKReactNativeBridgePool : NSObject

///单例
@property(class, nonatomic, readonly) GKReactNativeBridgePool *sharedPool;

///获取基础库URL
@property(nonatomic, readonly) NSURL *basicBundleURL;

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
