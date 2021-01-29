//
//  GKBaseViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+GKEmptyView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKContainer,
GKHttpTask,
GKHttpMultiTasks,
GKBaseViewModel,
GKNavigationBar,
GKSystemNavigationBar,
GKNavigationItemHelper;

///控制视图的基类
@interface GKBaseViewController : UIViewController<GKEmptyViewDelegate>

///关联的viewModel 如果有关联 调用viewModel对应方法
@property(nonatomic, strong, nullable) __kindof GKBaseViewModel *viewModel;

///是否已计算出frame，使用约束时用到
@property(nonatomic, readonly) BOOL isViewDidLayoutSubviews;

///设置点击self.view 回收键盘
@property(nonatomic, assign) BOOL shouldDismissKeyboardWhileTap;

///状态栏颜色
@property(nonatomic, assign) UIStatusBarStyle statusBarStyle;;

///界面是否显示
@property(nonatomic, readonly) BOOL isDisplaying;

///是否是第一次显示
@property(nonatomic, readonly) BOOL isFisrtDisplay;

///第一次显示回调
- (void)viewDidFirstAppear:(BOOL) animate;

// MARK: - 内容视图

///固定在顶部的视图 xib不要用
@property(nonatomic, strong, nullable) UIView *topView;

///固定在底部的视图 xib不要用
@property(nonatomic, strong, nullable) UIView *bottomView;

///内容视图 xib 不要用
@property(nonatomic, strong, nullable) UIView *contentView;

///视图容器 self.view xib 不要用，如果 showAsDialog = YES，self.view将不再是 container 且 要自己设置container的约束
@property(nonatomic, readonly, nullable) GKContainer *container;

/// 设置顶部视图
/// @param topView 顶部视图
/// @param height 视图高度，GKWrapContent 为自适应
- (void)setTopView:(nullable UIView *)topView height:(CGFloat) height;

/// 设置底部视图
/// @param bottomView 底部视图
/// @param height 视图高度，GKWrapContent 为自适应
- (void)setBottomView:(nullable UIView *)bottomView height:(CGFloat) height;

// MARK: - 导航栏

///导航栏
@property(nonatomic, readonly, nullable) GKNavigationBar *navigatonBar;

///item帮助类
@property(nonatomic, readonly) GKNavigationItemHelper *navigationItemHelper;

///系统导航栏
@property(nonatomic, readonly, nullable) GKSystemNavigationBar *systemNavigationBar;

///是否要创建自定义导航栏 default YES
@property(nonatomic, assign) BOOL shouldCreateNavigationBar;

///自定义导航栏类
@property(nonatomic, readonly) Class navigationBarClass;

///设置导航栏隐藏
- (void)setNavigatonBarHidden:(BOOL) hidden animate:(BOOL) animate;

///主要是用于要子类调用 super
- (void)viewDidLayoutSubviews NS_REQUIRES_SUPER;

// MARK: - Task

/// 添加需要取消的请求 在dealloc
/// @param task 请求
- (void)addCancelableTask:(GKHttpTask*) task;

/// @param cancel 是否取消相同的任务 通过 task.name 来判断
- (void)addCancelableTask:(GKHttpTask*) task cancelTheSame:(BOOL) cancel;

///添加需要取消的请求队列 在 dealloc
- (void)addCancelableTasks:(GKHttpMultiTasks*) tasks;

///加载页面数据 第一次加载 或者 网络错误重新加载
- (void)gkReloadData NS_REQUIRES_SUPER;

///数据加载完成回调 子类重写
- (void)onLoadData;

@end

NS_ASSUME_NONNULL_END


