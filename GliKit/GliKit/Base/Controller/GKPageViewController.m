//
//  GKPageViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPageViewController.h"
#import "GKContainer.h"
#import "GKPageLoadingContainer.h"
#import "GKBaseWebViewController.h"
#import "UIView+GKUtils.h"
#import <objc/runtime.h>

static char GKVisiblePageKey;

@implementation UIViewController (GKPage)

- (BOOL)visibleInPage
{
    NSNumber *number = objc_getAssociatedObject(self, &GKVisiblePageKey);
    return number != nil ? number.boolValue : NO;
}

- (void)setVisibleInPage:(BOOL)visibleInPage
{
    objc_setAssociatedObject(self, &GKVisiblePageKey, @(visibleInPage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface GKPageViewController ()<UIScrollViewDelegate>

///起始滑动位置
@property(nonatomic, assign) CGPoint beginOffset;

///是否需要滚动到对应位置
@property(nonatomic, assign) NSInteger willScrollToPage;

///当前scrollView 大小
@property(nonatomic, assign) CGSize scrollViewSize;

@end

@implementation GKPageViewController

@synthesize menuBar = _menuBar;
@synthesize pageViewControllers = _pageViewControllers;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.willScrollToPage = NSNotFound;
    _shouldUseMenuBar = YES;
    _shouldSetMenuBarTopView = YES;
    self.menuBarHeight = GKMenuBarHeight;
}

- (GKTabMenuBar*)menuBar
{
    if(!self.shouldUseMenuBar)
        return nil;
    
    if(!_menuBar){
        _menuBar = [GKTabMenuBar new];
        _menuBar.contentInset = UIEdgeInsetsMake(0, _menuBar.itemPadding, 0, _menuBar.itemPadding);
        _menuBar.delegate = self;
    }
    
    return _menuBar;
}

- (NSMutableArray<UIViewController*>*)pageViewControllers
{
    if(!_pageViewControllers){
        _pageViewControllers = [NSMutableArray array];
    }
    
    return _pageViewControllers;
}

- (void)initViews
{
    if(self.shouldUseMenuBar && self.shouldSetMenuBarTopView){
        [self.container setTopView:self.menuBar height:self.menuBarHeight];
    }
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.scrollsToTop = NO;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    self.scrollView = scrollView;
    self.contentView = scrollView;
    
    [super initViews];
    
    [self reloadData];
}

// MARK: - Layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(!CGSizeEqualToSize(self.scrollView.frame.size, CGSizeZero) && !CGSizeEqualToSize(self.scrollView.frame.size, self.scrollViewSize)){
        
        self.scrollViewSize = self.scrollView.frame.size;
        [self layoutPages];
        
        if((self.willScrollToPage > 0 && self.willScrollToPage < self.numberOfPage) || self.menuBar.selectedIndex != 0){
            
            NSInteger oldPage = _currentPage;
            if(self.menuBar.selectedIndex != 0){
                _currentPage = self.menuBar.selectedIndex;
            }
            [self.scrollView setContentOffset:CGPointMake(_currentPage * self.scrollViewSize.width, 0) animated:NO];
            [self _onScrollTopPage:_currentPage oldPage:oldPage];
            self.willScrollToPage = NSNotFound;
        }else{
            if(_currentPage < self.numberOfPage){
                [self viewControllerForIndex:_currentPage].visibleInPage = YES;
            }
        }
    }
}

///调整子视图
- (void)layoutPages
{
    if(!CGSizeEqualToSize(self.scrollViewSize, CGSizeZero)){
        self.scrollView.contentSize = CGSizeMake(self.scrollViewSize.width * self.numberOfPage, 0);
        [self layoutVisiablePages];
    }
}

///调整可见部分的视图
- (void)layoutVisiablePages
{
    NSInteger index = floor(self.scrollView.contentOffset.x / self.scrollViewSize.width);
    [self layoutPageForIndex:index - 1];
    [self layoutPageForIndex:index];
    [self layoutPageForIndex:index + 1];
}

///调整viewControlelr
- (void)layoutPageForIndex:(NSInteger) index
{
    if(index >= 0 && index < [self numberOfPage]){
        UIViewController *viewControlelr = [self viewControllerForIndex:index];
        if(viewControlelr.view.superview == nil){
            [self.scrollView addSubview:viewControlelr.view];
            [self addChildViewController:viewControlelr];
        }
        viewControlelr.view.frame = CGRectMake(self.scrollViewSize.width * index, 0, self.scrollViewSize.width, self.scrollViewSize.height);
    }
}

// MARK: - Public Method

- (void)removeAllViewContollers
{
    for(UIViewController *viewControlelr in _pageViewControllers){
        [viewControlelr removeFromParentViewController];
        [viewControlelr.view removeFromSuperview];
    }
    [_pageViewControllers removeAllObjects];
}

- (void)reloadData
{
    [self layoutPages];
    self.scrollView.contentOffset = CGPointZero;
    _currentPage = 0;
    if(_currentPage < self.numberOfPage){
        [self viewControllerForIndex:_currentPage].visibleInPage = YES;
    }
}

- (void)setPage:(NSUInteger) page animate:(BOOL) animate
{
    if(page >= [self numberOfPage]){
        return;
    }
    
    NSInteger oldPage = _currentPage;
    _currentPage = page;
    [self.menuBar setSelectedIndex:page animated:animate];
    if(!CGSizeEqualToSize(self.scrollViewSize, CGSizeZero)){
        [self.scrollView setContentOffset:CGPointMake(page * self.scrollViewSize.width, 0) animated:animate];
        [self _onScrollTopPage:_currentPage oldPage:oldPage];
    }else{
        self.willScrollToPage = _currentPage;
    }
}

- (UIViewController*)viewControllerForIndex:(NSUInteger) index
{
    return _pageViewControllers[index];
}

- (NSInteger)numberOfPage
{
    if(self.shouldUseMenuBar){
        return self.menuBar.titles.count;
    }else{
        return _pageViewControllers.count;
    }
}

- (void)_onScrollTopPage:(NSInteger)page oldPage:(NSInteger) oldPage
{
    if(oldPage < self.numberOfPage){
        [self viewControllerForIndex:oldPage].visibleInPage = NO;
    }
    
    [self viewControllerForIndex:page].visibleInPage = YES;
    
    [self onScrollTopPage:page];
}

- (void)onScrollTopPage:(NSInteger)page
{
    
}

// MARK: - GKTabMenuBarDelegate

- (void)menuBar:(GKTabMenuBar *)menu didSelectItemAtIndex:(NSUInteger)index
{
    [self.scrollView setContentOffset:CGPointMake(index * self.scrollViewSize.width, 0)];
    NSInteger oldPage = _currentPage;
    _currentPage = index;
    [self _onScrollTopPage:index oldPage:oldPage];
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.beginOffset = scrollView.contentOffset;
    [self setScrollEnabled:NO];
    
    [super scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self layoutVisiablePages];
    
    CGFloat offset = scrollView.contentOffset.x;
    if(offset <= 0 || offset >= scrollView.gkWidth * (self.menuBar.titles.count - 1)){
        return;
    }
    
    //是否是向右滑动
    BOOL toRight = scrollView.contentOffset.x >= self.beginOffset.x;
    
    CGFloat width = scrollView.gkWidth;
    int index = (toRight ? offset : (offset + width)) / width;
    if(index != self.menuBar.selectedIndex)
        return;
    
    offset = (int)offset % (int)width;
    if(!toRight){
        offset = width - offset;
    }
    float percent = offset / width;
    
    //向左还是向右
    NSUInteger willIndex = toRight ? self.menuBar.selectedIndex + 1 : self.menuBar.selectedIndex - 1;
    
    [self.menuBar setPercent:percent forIndex:willIndex];
    
    [super scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self scrollToVisibleIndex];
        [self setScrollEnabled:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollToVisibleIndex];
    [self setScrollEnabled:YES];
}

///滑动到可见位置
- (void)scrollToVisibleIndex
{
    NSInteger index = floor(self.scrollView.bounds.origin.x / self.scrollView.gkWidth);
    
    if(index != _currentPage){
        NSInteger oldPage = _currentPage;
        _currentPage = index;
        if(self.shouldUseMenuBar){
            if(index != self.menuBar.selectedIndex){
                [self.menuBar setSelectedIndex:index animated:YES];
            }
        }
        [self _onScrollTopPage:index oldPage:oldPage];
    }
}

///设置是否可以滑动
- (void)setScrollEnabled:(BOOL) enabled
{
    for(UIViewController *viewController in _pageViewControllers){
        if([viewController isKindOfClass:[GKScrollViewController class]]){
            GKScrollViewController *vc = (GKScrollViewController*)viewController;
            vc.scrollView.scrollEnabled = enabled;
        }else if ([viewController isKindOfClass:[GKBaseWebViewController class]]){
            GKBaseWebViewController *web = (GKBaseWebViewController*)viewController;
            web.webView.scrollView.scrollEnabled = enabled;
        }
    }
}

@end
