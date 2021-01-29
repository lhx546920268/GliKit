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
@interface GKScrollViewModel : GKBaseViewModel

///绑定的viewController
@property(nonatomic, weak, nullable, readonly) __kindof GKScrollViewController *viewController;

// MARK: - Refresh

///是否正在刷新
@property(nonatomic, readonly) BOOL refreshing;

///手动调用下拉刷新，会有下拉动画
- (void)startRefresh NS_REQUIRES_SUPER;

///触发下拉刷新
- (void)onRefesh;

///结束下拉刷新
- (void)stopRefresh NS_REQUIRES_SUPER;

///刷新完成
- (void)stopRefreshForResult:(BOOL) result NS_REQUIRES_SUPER;

///下拉刷新取消
- (void)onRefeshCancel;

// MARK: - Load More

///当前第几页 default `GKHttpFirstPage`
@property(nonatomic, assign) int curPage;

///是否还有更多
@property(nonatomic, assign) BOOL hasMore;

///是否正在加载更多
@property(nonatomic, readonly) BOOL loadingMore;

///手动加载更多，会有上拉动画
- (void)startLoadMore NS_REQUIRES_SUPER;

///触发加载更多
- (void)onLoadMore NS_REQUIRES_SUPER;

///结束加载更多
- (void)stopLoadMoreWithMore:(BOOL) hasMore NS_REQUIRES_SUPER;

///加载更多失败
- (void)stopLoadMoreWithFail NS_REQUIRES_SUPER;

///加载更多取消
- (void)onLoadMoreCancel NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END

