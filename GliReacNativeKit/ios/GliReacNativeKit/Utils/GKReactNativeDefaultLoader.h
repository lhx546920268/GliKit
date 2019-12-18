//
//  GKReactNativeDefaultLoader.h
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKReactNativeLoader.h"

NS_ASSUME_NONNULL_BEGIN

///默认的rn加载器
@interface GKReactNativeDefaultLoader : NSObject<GKReactNativeLoader>

///js bundle 名称 default is `bundle.jsbundle` 
@property(nonatomic, copy, null_resettable) NSString *jsBundleName;

///通过模块名称z创建
- (instancetype)initWithModuleName:(NSString*) moduleName;

///检查版本 子类重写
- (void)detectVersion;

///检查版本完成
- (void)onDetectVersion:(nullable GKReactNativeVersionModel*) model;

///rn保存在本地的文件夹
+ (NSString*)reactNativeDirectory;

///rn本地bundle路径
+ (NSString*)reactNativeBundlePathForModuleName:(NSString*) moduleName;

@end

NS_ASSUME_NONNULL_END
