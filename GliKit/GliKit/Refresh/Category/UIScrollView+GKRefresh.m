//
//  UIScrollView+GKRefresh.m
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UIScrollView+GKRefresh.h"
#import <objc/runtime.h>
#import "UIView+GKEmptyView.h"
#import "GKRefreshControl.h"
#import "GKLoadMoreControl.h"
#import "GKRefreshStyle.h"

//下拉刷新控制器的key
static char GKRefreshControlKey;

//上拉加载控制器的 key
static char GKLoadMoreControlKey;

@implementation UIScrollView (GKRefresh)

- (__kindof GKRefreshControl*)gkAddRefreshWithHandler:(GKDataControlHandler)handler
{
    GKRefreshControl *refreshControl = self.gkRefreshControl;
    if(!refreshControl){
        refreshControl = [[[GKRefreshStyle sharedInstance].refreshClass alloc] initWithScrollView:self];
    }
    refreshControl.handler = handler;
    self.gkRefreshControl = refreshControl;
    GKLoadMoreControl *loadMoreControl = self.gkLoadMoreControl;
    if(loadMoreControl){
        UIEdgeInsets contentInsets = self.contentInset;
        if(loadMoreControl.state == GKDataControlStateLoading
           || (loadMoreControl.state == GKDataControlStateNoData && loadMoreControl.shouldStayWhileNoData)){
            contentInsets.bottom -= loadMoreControl.criticalPoint;
            if(contentInsets.bottom < 0){
                contentInsets.bottom = 0;
            }
        }
        loadMoreControl.originalContentInset = contentInsets;
    }
    
    return refreshControl;
}

- (void)gkRemoveRefreshControl
{
    GKRefreshControl *refreshControl = self.gkRefreshControl;
    if(refreshControl){
        self.contentInset = refreshControl.originalContentInset;
        self.gkRefreshControl = nil;
    }
}

- (GKRefreshControl*)gkRefreshControl
{
    return objc_getAssociatedObject(self, &GKRefreshControlKey);
}

- (void)setGkRefreshControl:(GKRefreshControl *) refreshControl
{
    if(refreshControl != self.gkRefreshControl){
        [self.gkRefreshControl removeFromSuperview];
        if(refreshControl){
            [self addSubview:refreshControl];
        }
        objc_setAssociatedObject(self, &GKRefreshControlKey, refreshControl, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (BOOL)gkRefreshing
{
    return self.gkRefreshControl.state == GKDataControlStateLoading;
}

// MARK: - 加载更多

- (__kindof GKLoadMoreControl*)gkAddLoadMoreWithHandler:(GKDataControlHandler)handler
{
    GKLoadMoreControl *loadMoreControl = self.gkLoadMoreControl;
    if(!loadMoreControl){
        loadMoreControl = [[[GKRefreshStyle sharedInstance].loadMoreClass alloc] initWithScrollView:self];
    }
    loadMoreControl.handler = handler;
    self.gkLoadMoreControl = loadMoreControl;
    GKRefreshControl *refreshControl = self.gkRefreshControl;
    if(refreshControl){
        UIEdgeInsets contentInsets = self.contentInset;
        if(refreshControl.state == GKDataControlStateLoading){
            contentInsets.top -= refreshControl.criticalPoint;
            if(contentInsets.top < 0){
                contentInsets.top = 0;
            }
        }
        refreshControl.originalContentInset = contentInsets;
    }
    
    return loadMoreControl;
}

- (void)gkRemoveLoadMoreControl
{
    GKLoadMoreControl *loadMoreControl = self.gkLoadMoreControl;
    if(loadMoreControl){
        self.contentInset = loadMoreControl.originalContentInset;
        self.gkLoadMoreControl = nil;
    }
}

- (void)setGkLoadMoreControl:(GKLoadMoreControl *) loadMoreControl
{
    if(loadMoreControl != self.gkLoadMoreControl){
        [self.gkLoadMoreControl removeFromSuperview];
        if(loadMoreControl){
            GKEmptyView *emptyView = self.gkEmptyView;
            if(emptyView){
                [self insertSubview:loadMoreControl belowSubview:emptyView];
            }else{
                [self addSubview:loadMoreControl];
            }
        }
        objc_setAssociatedObject(self, &GKLoadMoreControlKey, loadMoreControl, OBJC_ASSOCIATION_RETAIN);
    }
}

- (GKLoadMoreControl*)gkLoadMoreControl
{
    return objc_getAssociatedObject(self, &GKLoadMoreControlKey);
}

- (BOOL)gkLoadingMore
{
    return self.gkLoadMoreControl.state == GKDataControlStateLoading;
}

@end
