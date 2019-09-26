//
//  GKScrollViewModel.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewModel.h"
#import "GKScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

///带有下拉划线的基础视图逻辑处理
@interface GKScrollViewModel : GKBaseViewModel;

///绑定的viewController
@property(nonatomic, weak, nullable) __kindof GKScrollViewController *viewController;

/**
 当前第几页 default is 'GKHttpFirstPage'
 */
@property(nonatomic, assign) int curPage;

/**
 是否正在刷新数据
 */
@property(nonatomic, readonly) BOOL refreshing;

/**
 是否正在加载更多
 */
@property(nonatomic, readonly) BOOL loadingMore;

/**
 触发下拉刷新
 */
- (void)onRefesh;

/**
 触发加载更多
 */
- (void)onLoadMore;

/**
 刷新完成
 *@param success 是否成功
 */
- (void)onRefreshComplete:(BOOL) success NS_REQUIRES_SUPER;

/**
 加载更多完成 是否还有更多
 */
- (void)onloadMoreComplete:(BOOL) hasMore NS_REQUIRES_SUPER;

/**
 加载更多失败
 */
- (void)onloadMoreFail NS_REQUIRES_SUPER;

/**
 下拉刷新取消
 */
- (void)onRefeshCancel;

/**
 加载更多取消
 */
- (void)onLoadMoreCancel;

@end

NS_ASSUME_NONNULL_END

