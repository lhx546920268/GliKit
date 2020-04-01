//
//  GKScrollViewModel.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKScrollViewModel.h"

@implementation GKScrollViewModel

@synthesize viewController = _viewController;

- (instancetype)initWithController:(GKBaseViewController *)viewController
{
    self = [super initWithController:viewController];
    if(self){
        _viewController = (GKScrollViewController*)viewController;
    }
    
    return self;
}

// MARK: - Refresh

- (BOOL)refreshing
{
    return self.viewController.refreshing;
}

- (void)startRefresh
{
    [self.viewController startRefresh];
}

- (void)onRefesh
{
    
}

- (void)stopRefresh
{
    [self.viewController stopRefresh];
}

- (void)stopRefreshForResult:(BOOL)result
{
    [self.viewController stopRefreshForResult:result];
}

- (void)onRefeshCancel
{
    
}

// MARK: - Load More

- (void)setCurPage:(int)curPage
{
    self.viewController.curPage = curPage;
}

- (int)curPage
{
    return self.viewController.curPage;
}

- (void)setHasMore:(BOOL)hasMore
{
    self.viewController.hasMore = hasMore;
}

- (BOOL)hasMore
{
    return self.viewController.hasMore;
}

- (BOOL)loadingMore
{
    return self.viewController.loadingMore;
}

- (void)startLoadMore
{
    [self.viewController startLoadMore];
}

- (void)onLoadMore
{
    
}

- (void)stopLoadMoreWithMore:(BOOL)flag
{
    [self.viewController stopLoadMoreWithMore:flag];
}

- (void)stopLoadMoreWithFail
{
    [self.viewController stopLoadMoreWithFail];
}

- (void)onLoadMoreCancel
{
    
}

@end
