//
//  GKScrollViewModel.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 xiaozhai. All rights reserved.
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

- (void)setCurPage:(int)curPage
{
    self.viewController.curPage = curPage;
}

- (int)curPage
{
    return self.viewController.curPage;
}

- (BOOL)refreshing
{
    return self.viewController.refreshing;
}

- (BOOL)loadingMore
{
    return self.viewController.loadingMore;
}

- (void)onRefesh
{
    
}

- (void)onLoadMore
{
    
}

- (void)onRefreshComplete:(BOOL) success
{
    [self.viewController onRefreshComplete:success];
}

- (void)onloadMoreComplete:(BOOL) hasMore
{
    [self.viewController onloadMoreComplete:hasMore];
}

- (void)onloadMoreFail
{
    [self.viewController onloadMoreFail];
}

- (void)onRefeshCancel
{
    
}

- (void)onLoadMoreCancel
{
    
}

@end
