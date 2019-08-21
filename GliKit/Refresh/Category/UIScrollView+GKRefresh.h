//
//  UIScrollView+GKRefresh.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDataControl.h"

@class GKRefreshControl, GKLoadMoreControl;

///刷新 类目
@interface UIScrollView (GKRefresh)

/**
 添加下拉刷新功能
 *@param handler 刷新回调方法
 */
- (__kindof GKRefreshControl*)gkAddRefreshWithHandler:(GKDataControlHandler) handler;

/**
 删除下拉刷新功能
 */
- (void)gkRemoveRefreshControl;

/**
 下拉刷新控制类
 */
@property(nonatomic, strong) GKRefreshControl *gkRefreshControl;

/**
 是否正在下拉刷新
 */
@property(nonatomic, readonly) BOOL gkRefreshing;

/**
 添加加载更多
 *@param handler 加载回调
 */
- (__kindof GKLoadMoreControl*)gkAddLoadMoreWithHandler:(GKDataControlHandler) handler;

/**
 删除加载更多功能
 */
- (void)gkRemoveLoadMoreControl;

/**
 加载更多控制类
 */
@property(nonatomic, strong) GKLoadMoreControl *gkLoadMoreControl;

/**
 是否正在加载更多
 */
@property(nonatomic, readonly) BOOL gkLoadingMore;

@end
