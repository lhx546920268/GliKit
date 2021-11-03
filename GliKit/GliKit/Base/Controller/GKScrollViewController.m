//
//  GKScrollViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKScrollViewController.h"
#import "GKRefreshControl.h"
#import "GKLoadMoreControl.h"
#import "UIViewController+GKKeyboard.h"
#import "GKPageViewController.h"
#import "GKScrollViewModel.h"
#import "GKHttpTask.h"
#import "GKBaseDefines.h"
#import "UIView+GKUtils.h"

@interface GKScrollViewController ()<UIScrollViewDelegate>

@end

@implementation GKScrollViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.curPage = GKHttpFirstPage;
        self.shouldDismissKeyboardWhileScroll = YES;
        self.shouldAdjustContentInsetsForKeyboard = YES;
    }
    return self;
}

// MARK: - property

- (void)setScrollView:(UIScrollView *)scrollView
{
    if(_scrollView != scrollView){
        _scrollView = scrollView;
        if (@available(iOS 11.0, *)) {
            if(self.shouldAdjustContentInsetForSafeArea && ([_scrollView isKindOfClass:UITableView.class] || [_scrollView isKindOfClass:UICollectionView.class])){
                _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentScrollableAxes;
            } else {
                _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        !self.scrollViewDidChange ?: self.scrollViewDidChange(_scrollView);
    }
}

- (BOOL)shouldAdjustContentInsetForSafeArea
{
    return YES;
}

// MARK: - 加载视图

- (BOOL)isInit
{
    return self.scrollView.superview != nil;
}

- (void)initViews
{
    
}

- (void)reloadListData
{
    
}

// MARK: - Refresh

- (void)setRefreshEnabled:(BOOL) enabled
{
    if(_refreshEnabled != enabled){

        NSAssert(_scrollView != nil, @"%@ 设置下拉刷新 scrollView 不能为nil", NSStringFromClass([self class]));

        _refreshEnabled = enabled;
        if(_refreshEnabled){
            WeakObj(self);
            [self.scrollView gkAddRefreshWithHandler:^(void){
                
                [selfWeak willRefresh];
            }];
        }else{
            [self.scrollView gkRemoveRefreshControl];
        }
    }
}

- (GKRefreshControl *)refreshControl
{
    return self.scrollView.gkRefreshControl;
}

///将要触发下拉刷新
- (void)willRefresh
{
    if(self.loadingMore && !self.coexistRefreshAndLoadMore){
        [self stopLoadMoreWithMore:YES];
        if(self.curPage > GKHttpFirstPage){
            self.curPage --;
        }
        [self onLoadMoreCancel];
    }
    _refreshing = YES;
    [self onRefesh];
}

- (void)startRefresh
{
    [self.refreshControl startLoading];
}

- (void)onRefesh
{
    if(self.viewModel){
        [self.viewModel onRefesh];
    }
}

- (void)stopRefresh
{
    [self stopRefreshForResult:YES];
}

- (void)stopRefreshForResult:(BOOL)result
{
    _refreshing = NO;
    [self.refreshControl stopLoading];
}

- (void)onRefeshCancel
{
    if(self.viewModel){
        [self.viewModel onRefeshCancel];
    }
}

// MARK: - Load More

- (void)setLoadMoreEnabled:(BOOL)enabled
{
    if(_loadMoreEnabled != enabled){
        
        NSAssert(_scrollView != nil, @"%@ 设置加载更多 scrollView 不能为nil", NSStringFromClass([self class]));
        _loadMoreEnabled = enabled;
        
        if(_loadMoreEnabled){
            WeakObj(self);
            [self.scrollView gkAddLoadMoreWithHandler:^(void){
                
                [selfWeak willLoadMore];
            }];
        }else{
            [self.scrollView gkRemoveLoadMoreControl];
        }
    }
}

- (GKLoadMoreControl *)loadMoreControl
{
    return self.scrollView.gkLoadMoreControl;
}

///将要触发加载更多
- (void)willLoadMore
{
    if(self.refreshing && !self.coexistRefreshAndLoadMore){
        [self stopRefresh];
        [self onRefeshCancel];
    }
    _loadingMore = YES;
    [self onLoadMore];
}

- (void)startLoadMore
{
    [self.loadMoreControl startLoading];
}

- (void)onLoadMore
{
    if(self.viewModel){
        [self.viewModel onLoadMore];
    }
}

- (void)stopLoadMoreWithMore:(BOOL) flag
{
    _loadingMore = NO;
    if(flag){
        [self.loadMoreControl stopLoading];
    }else{
        
        [self.loadMoreControl noMoreInfo];
    }
}

- (void)stopLoadMoreWithFail
{
    _loadingMore = NO;
    [self.loadMoreControl loadFail];
}

- (void)onLoadMoreCancel
{
    if(self.viewModel){
        [self.viewModel onLoadMoreCancel];
    }
}

// MARK: - 键盘

///键盘高度改变
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    [super keyboardWillChangeFrame:notification];
    if(self.shouldAdjustContentInsetsForKeyboard){
        UIEdgeInsets insets = self.contentInsets;
        if(!self.keyboardHidden){
            insets.bottom += self.keyboardFrame.size.height;
            if(self.bottomView){
                insets.bottom -= self.bottomView.gkHeight;
            }
            if(insets.bottom < 0){
                insets.bottom = 0;
            }
        }
        
        [UIView animateWithDuration:0.25 animations:^(void){
            
            self.scrollView.contentInset = insets;
        }];
    }
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.shouldDismissKeyboardWhileScroll){
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
    }
    if(scrollView == self.scrollView){
        //防止左右滑动时触发上下滑动
        if([self.parentViewController isKindOfClass:[GKPageViewController class]]){
            GKPageViewController *page = (GKPageViewController*)self.parentViewController;
            page.scrollView.scrollEnabled = NO;
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(scrollView == self.scrollView){
        [self.loadMoreControl scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        if([self.parentViewController isKindOfClass:[GKPageViewController class]]){
            GKPageViewController *page = (GKPageViewController*)self.parentViewController;
            page.scrollView.scrollEnabled = YES;
        }
    }
}

@end
