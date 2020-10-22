//
//  GKScrollViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewController.h"
#import "UIScrollView+GKEmptyView.h"
#import "UIScrollView+GKRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@class GKScrollViewModel, GKRefreshControl, GKLoadMoreControl;

/**
 滚动视图控制器，具有加载更多和下拉刷新，键盘弹出时设置contentInset功能，防止键盘挡住输入框
 */
@interface GKScrollViewController : GKBaseViewController

/**
 滚动视图 default is 'nil'
 */
@property(nonatomic, strong, nullable) UIScrollView *scrollView;

/**
 scrollView 改变了
 */
@property(nonatomic, copy) void(^scrollViewDidChange)(UIScrollView * _Nullable scrollView);

/**
 滑动时是否隐藏键盘 default is 'YES'
 */
@property(nonatomic, assign) BOOL shouldDismissKeyboardWhileScroll;

/**
 键盘弹出是否需要调整contentInsets default is 'YES'
 */
@property(nonatomic, assign) BOOL shouldAdjustContentInsetsForKeyboard;

/**
 scroll view 原始的contentInsets
 */
@property(nonatomic, assign) UIEdgeInsets contentInsets;

/**
 加载更多和下拉刷是否可以共存 default is 'NO'
 */
@property(nonatomic, assign) BOOL coexistRefreshAndLoadMore;

/**
 是否已初始化
 */
@property(nonatomic, readonly) BOOL isInit;

/**
 初始化视图 默认不做任何事 ，子类按需实现该方法
 */
- (void)initViews NS_REQUIRES_SUPER;

/**
 刷新列表数据 子类重写
 */
- (void)reloadListData;

//MARK: - Refresh

/**
 是否可以下拉刷新数据
 */
@property(nonatomic, assign) BOOL refreshEnable;

/**
 下拉刷新视图
 */
@property(nonatomic, readonly, nullable) GKRefreshControl *refreshControl;

/**
 是否正在刷新数据
 */
@property(nonatomic, readonly) BOOL refreshing;

/**
 手动调用下拉刷新，会有下拉动画
 */
- (void)startRefresh NS_REQUIRES_SUPER;

/**
 触发下拉刷新
 */
- (void)onRefesh NS_REQUIRES_SUPER;

/**
 结束下拉刷新
 */
- (void)stopRefresh NS_REQUIRES_SUPER;

/**
 刷新完成
 *@param result 是否成功
 */
- (void)stopRefreshForResult:(BOOL) result NS_REQUIRES_SUPER;

/**
 下拉刷新取消
 */
- (void)onRefeshCancel NS_REQUIRES_SUPER;

//MARK: - Load More

/**
 加载更多时的指示视图
 */
@property(nonatomic, readonly, nullable) GKLoadMoreControl *loadMoreControl;

/**
 是否可以加载更多数据 default is 'NO'
 */
@property(nonatomic, assign) BOOL loadMoreEnable;


/**
 当前第几页 default is 'GKHttpFirstPage'
 */
@property(nonatomic, assign) int curPage;

/**
 是否还有更多
 */
@property(nonatomic, assign) BOOL hasMore;

/**
 是否正在加载更多
 */
@property(nonatomic, readonly) BOOL loadingMore;

/**
 手动加载更多，会有上拉动画
 */
- (void)startLoadMore NS_REQUIRES_SUPER;

/**
 触发加载更多
 */
- (void)onLoadMore NS_REQUIRES_SUPER;

/**
 结束加载更多
 *@param flag 是否还有更多信息
 */
- (void)stopLoadMoreWithMore:(BOOL) flag NS_REQUIRES_SUPER;

/**
 加载更多失败
 */
- (void)stopLoadMoreWithFail NS_REQUIRES_SUPER;

/**
 加载更多取消
 */
- (void)onLoadMoreCancel NS_REQUIRES_SUPER;

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint*)targetContentOffset NS_REQUIRES_SUPER;


@end

NS_ASSUME_NONNULL_END
