//
//  GKBaseViewModel.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

///基础视图逻辑处理
@interface GKBaseViewModel : NSObject

///绑定的viewController
@property(nonatomic, weak, nullable) __kindof GKBaseViewController *viewController;

///加载数据是否需要显示 pageLoading default is 'YES'
@property(nonatomic, assign) BOOL shouldShowPageLoading;

/**
 构造方法

 @param viewController 绑定的视图控制器
 @return 一个 GKBaseViewModel或其子类 实例
 */
- (instancetype)initWithController:(GKBaseViewController*) viewController;
+ (instancetype)viewModelWithController:(GKBaseViewController*) viewController;


///关联的viewController会调用这里
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

/**
 添加需要取消的请求 在dealloc
 
 @param task 请求
 */
- (void)addCanceledTask:(GKHttpTask*) task;

/**
 添加需要取消的请求 在dealloc
 
 @param task 请求
 @param cancel 是否取消相同的任务 通过 task.name 来判断
 */
- (void)addCanceledTask:(GKHttpTask*) task cancelTheSame:(BOOL) cancel;

/**
 添加需要取消的请求队列 在 dealloc
 
 @param tasks 请求
 */
- (void)addCanceledTasks:(GKHttpMultiTasks*) tasks;

/**
 重新加载页面数据
 */
- (void)reloadData NS_REQUIRES_SUPER;

/**
 数据加载完成回调
 */
- (void)onLoadData NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END

