//
//  GKReactNativeViewController.h
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/17.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <GKBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKReactNativeLoader;
@class GKReactNativeVersionModel, RCTRootView;

/**
 * 基础RN视图控制器
 * 定义 宏定义 RNDebug 1 可以连接本地的开发的RN调试
 */
@interface GKReactNativeViewController : GKBaseViewController

///rn加载器
@property(nonatomic, strong, null_resettable) id<GKReactNativeLoader> reactNativeLoader;

///额外要初始化的属性
@property(nonatomic, strong, nullable) NSDictionary *extendProperties;

///rn 模块名称
@property(nonatomic, copy) NSString *moduleName;

///显示rn的视图
@property(nonatomic, readonly, nullable) RCTRootView *rnRootView;

///rn是否已加载完成
@property(nonatomic, readonly) BOOL reactNativeDidLoad;

///rn视图 显示
- (void)onRactNativeDisplay;

///rn加载失败 默认显示失败界面
- (void)onReactNativeLoadFailWithModel:(nullable GKReactNativeVersionModel*) model;

#if RNDebug

///本地 rn 入口路径，从项目的根目录开始，如果index文件在根目录，则 传 index就行了
@property(nonatomic, copy) NSString *localIndexPath;

#endif

@end

NS_ASSUME_NONNULL_END
