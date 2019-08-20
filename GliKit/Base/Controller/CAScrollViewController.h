//
//  GKScrollViewController.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKBaseViewController.h"
#import "UIScrollView+GKEmptyView.h"

@class GKScrollViewModel, MJRefreshComponent;

/**
 滚动视图控制器，具有加载更多和下拉刷新，键盘弹出时设置contentInset功能，防止键盘挡住输入框
 */
@interface GKScrollViewController : GKBaseViewController

/**
 滚动视图 default is 'nil'
 */
@property(nonatomic,strong) UIScrollView *scrollView;

/**
 滑动时是否隐藏键盘 default is 'YES'
 */
@property(nonatomic,assign) BOOL shouldDismissKeyboardWhileScroll;

/**
 键盘弹出是否需要调整contentInsets default is 'YES'
 */
@property(nonatomic,assign) BOOL shouldAdjustContentInsetsForKeyboard;


/**
 scroll view 原始的contentInsets
 */
@property(nonatomic,assign) UIEdgeInsets contentInsets;

/**
 是否可以下拉刷新数据
 */
@property(nonatomic,assign) BOOL refreshEnable;

/**
 加载更多和下拉刷是否可以共存 default is 'NO'
 */
@property(nonatomic,assign) BOOL coexistRefreshAndLoadMore;

/**
 是否可以加载更多数据 default is 'NO'
 */
@property(nonatomic,assign) BOOL loadMoreEnable;

/**
 当前第几页 default is 'GKHttpFirstPage'
 */
@property(nonatomic,assign) int curPage;

/**
 是否还有更多
 */
@property(nonatomic,assign) BOOL hasMore;

/**
 是否正在刷新数据
 */
@property(nonatomic,readonly) BOOL refreshing;

/**
 是否正在加载更多
 */
@property(nonatomic,readonly) BOOL loadingMore;

/**
 是否已初始化
 */
@property(nonatomic,readonly) BOOL isInit;

/**
 初始化视图 默认不做任何事 ，子类按需实现该方法
 */
- (void)initViews NS_REQUIRES_SUPER;

/**
 下来刷新view，默认是 GKRefreshHeader，子类重写
 */
- (MJRefreshComponent*)refreshHeader;

/**
 加载更多view，默认是 GKRefreshFooter，子类重写
 */
- (MJRefreshComponent*)refreshFooter;

///以下的两个方法默认不做任何事，子类按需实现

/**
 触发下拉刷新
 */
- (void)onRefesh NS_REQUIRES_SUPER;

/**
 触发加载更多
 */
- (void)onLoadMore NS_REQUIRES_SUPER;

///以下的两个方法，刷新结束或加载结束时调用，如果子类重写，必须调用 super方法

- (void)stopRefresh NS_REQUIRES_SUPER;

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
 手动调用下拉刷新，会有下拉动画
 */
- (void)startRefresh NS_REQUIRES_SUPER;

/**
 手动加载更多，会有上拉动画
 */
- (void)startLoadMore NS_REQUIRES_SUPER;

///以下3个子类按需重写 viewModel中刷新完成会执行对应方法

/**
 刷新完成
 *@param 是否成功
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

///以下2个子类按需重写

/**
 下拉刷新取消
 */
- (void)onRefeshCancel NS_REQUIRES_SUPER;

/**
 加载更多取消
 */
- (void)onLoadMoreCancel NS_REQUIRES_SUPER;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_REQUIRES_SUPER;

/**
 刷新列表数据 子类重写
 */
- (void)reloadListData;


@end
