//
//  GKReactNativeLoader.h
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/17.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKReactNativeVersionModel;

///加载rn 完成回调 bundleURL为nil时 加载失败
typedef void(^GKLoadReactNativeCompletionHandler)(NSURL * _Nullable bundleURL, NSString *moduleName, __kindof GKReactNativeVersionModel * _Nullable model);

///rn 加载器
@protocol GKReactNativeLoader<NSObject>

///rn 对应的moduleName
@property(nonatomic, readonly) NSString *moduleName;

///加载rn 文件
- (void)loadReactNativeFileWithCompletionHandler:(GKLoadReactNativeCompletionHandler) handler;

@end


NS_ASSUME_NONNULL_END
