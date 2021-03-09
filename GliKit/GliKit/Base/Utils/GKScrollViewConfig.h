//
//  GKScrollViewConfig.h
//  GliKit
//
//  Created by 罗海雄 on 2021/2/23.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

///列表配置
@interface GKScrollViewConfig : NSObject

///绑定的viewController
@property(nonatomic, weak, nullable, readonly) __kindof GKScrollViewController *viewController;

///关联的viewModel 如果有关联 调用viewModel对应方法
@property(nonatomic, nullable, readonly) __kindof GKScrollViewModel *viewModel;

///当前导航栏
@property(nonatomic, nullable, readonly) UINavigationController *navigationController;

///配置
- (void)config;

/// 初始化
/// @param viewController 绑定的视图控制器
/// @return 一个 GKBaseViewModel或其子类 实例
- (instancetype)initWithController:(GKScrollViewController*) viewController;
+ (instancetype)configWithController:(GKScrollViewController*) viewController;

@end

NS_ASSUME_NONNULL_END
