//
//  GKBaseViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+GKEmptyView.h"


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
@property(nonatomic, strong) __kindof GKBaseViewModel *viewModel;

///获取兼容的状态栏高度 比如有连接个人热点的时候状态栏的高度是不一样的 viewDidLayoutSubviews 获取
@property(nonatomic, readonly) CGFloat compatiableStatusHeight;

///是否已计算出frame，使用约束时用到
@property(nonatomic, readonly) BOOL isViewDidLayoutSubviews;

///设置点击self.view 回收键盘
@property(nonatomic, assign) BOOL shouldDismissKeyboardWhileTap;

//MARK: 内容视图

///固定在顶部的视图 xib不要用
@property(nonatomic, strong) UIView *topView;

///固定在底部的视图 xib不要用
@property(nonatomic, strong) UIView *bottomView;

///内容视图 xib 不要用
@property(nonatomic, strong) UIView *contentView;

///视图容器 self.view xib 不要用，如果 showAsDialog = YES，self.view将不再是 container 且 要自己设置container的约束
@property(nonatomic, readonly) GKContainer *container;

/**
 设置顶部视图
 
 @param topView 顶部视图
 @param height 视图高度，GKWrapContent 为自适应
 */
- (void)setTopView:(UIView *)topView height:(CGFloat) height;

/**
 设置底部视图
 
 @param bottomView 底部视图
 @param height 视图高度，GKWrapContent 为自适应
 */
- (void)setBottomView:(UIView *)bottomView height:(CGFloat) height;

//MARK: 导航栏

///导航栏
@property(nonatomic, readonly) GKNavigationBar *navigatonBar;

///item帮助类
@property(nonatomic, readonly) GKNavigationItemHelper *navigationItemHelper;

///系统导航栏
@property(nonatomic, readonly) GKSystemNavigationBar *systemNavigationBar;

///是否要创建自定义导航栏 default YES
@property(nonatomic, assign) BOOL shouldCreateNavigationBar;

///自定义导航栏类
@property(nonatomic, readonly) Class navigationBarClass;

///设置导航栏隐藏
- (void)setNavigatonBarHidden:(BOOL) hidden animate:(BOOL) animate;

/**
 主要是用于要子类调用 super
 */
- (void)viewDidLayoutSubviews NS_REQUIRES_SUPER;

//MARK: Task

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
 加载页面数据 第一次加载 或者 网络错误重新加载
 */
- (void)gkReloadData NS_REQUIRES_SUPER;

/**
 数据加载完成回调 子类重写
 */
- (void)onLoadData;

@end


