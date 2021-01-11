//
//  GKBannerView.m
//  GliKit
//
//  Created by 罗海雄 on 2020/1/6.
//

#import "GKBannerView.h"
#import "GKCountDownTimer.h"
#import "UICollectionView+GKUtils.h"
#import "UIColor+GKUtils.h"
#import "GKBaseDefines.h"
#import "UIColor+GKTheme.h"
#import "UIView+GKUtils.h"

@implementation GKPageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _pointSize = CGSizeMake(12, 12);
        self.pageIndicatorTintColor = [UIColor gkColorWithRed:204 green:204 blue:204 alpha:1.0];;
        self.currentPageIndicatorTintColor = UIColor.gkThemeColor;
    }
    
    return self;
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    return _pointSize;
}

@end

@interface GKBannerView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

///计时器
@property(nonatomic,strong) GKCountDownTimer *timer;

///起始位置
@property(nonatomic,assign) CGPoint contentOffset;

///是否需要循环滚动
@property(nonatomic,assign) BOOL shouldScrollCircularly;

///是否已经计算了
@property(nonatomic,assign) BOOL isLayoutSubviews;

///layout
@property(nonatomic,strong) UICollectionViewFlowLayout *layout;

@end

@implementation GKBannerView

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection) scrollDirection
{
    self = [super initWithFrame:CGRectZero];
    if(self){
        _scrollDirection = scrollDirection;
        [self initProps];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [self initProps];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [self initProps];
    }
    
    return self;
}

- (void)initProps
{
    if(!_collectionView){
        
        _animatedTimeInterval = 5;
        _enableScrollCircularly = YES;
        _showPageControl = NO;
        _enableAutoScroll = YES;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = _scrollDirection;
        self.layout = layout;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator= NO;
        _collectionView.showsVerticalScrollIndicator= NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        [self addSubview:_collectionView];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(self.isLayoutSubviews){
        if(newWindow){
            [self startAnimating];
        }else{
            [self stopAnimating];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.isLayoutSubviews = YES;
    
    if(!CGSizeEqualToSize(self.collectionView.frame.size, self.bounds.size)){
        self.collectionView.frame = self.bounds;
        [self fetchData];
    }
}

// MARK: -  public method

- (void)registerNib:(Class)clazz
{
    [self.collectionView registerNib:clazz];
}

- (void)registerClass:(Class)cellClas
{
    [self.collectionView registerClass:cellClas];
}

- (__kindof UICollectionViewCell*)dequeueReusableCellWithClass:(Class) cellClass forIndexPath:(NSIndexPath *)indexPath
{
    return [self dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
}

- (__kindof UICollectionViewCell*)dequeueReusableCellWithReuseIdentifier:(NSString*) identifier forIndexPath:(nonnull NSIndexPath *)indexPath
{
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)reloadData
{
    if(self.isLayoutSubviews){
        [self fetchData];
    }
}

- (void)fetchData
{
    if([self.delegate respondsToSelector:@selector(numberOfCellsInBannerView:)]){
        _numberOfCells = [self.delegate numberOfCellsInBannerView:self];
    }else{
        _numberOfCells = 0;
    }
    
    self.pageControl.numberOfPages = _numberOfCells;
    self.pageControl.currentPage = 0;
    
    self.shouldScrollCircularly = _numberOfCells > 1 && self.enableScrollCircularly;
    
    [self.collectionView reloadData];
    
    if(_numberOfCells > 0){
        [self scrollToIndex:0 animated:NO];
    }
    [self startAnimating];
}

- (void)scrollToIndex:(NSInteger) index animated:(BOOL) flag
{
    NSInteger count = _numberOfCells;
    if(self.shouldScrollCircularly){
        index ++;
        count += 2;
    }
    
    if(index < count){
        switch (_scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal :
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:flag];
                break;
            case UICollectionViewScrollDirectionVertical :
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:flag];
                break;
        }
    }
}

- (BOOL)dragging
{
    return self.collectionView.dragging;
}

- (BOOL)decelerating
{
    return self.collectionView.decelerating;
}

- (UICollectionViewCell*)cellForIndex:(NSInteger) index
{
    NSInteger count = _numberOfCells;
    if(self.shouldScrollCircularly){
        index ++;
        count += 2;
    }
    if(index < count){
        return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    }
    return nil;
}

// MARK: -  timer

///开始动画
- (void)startAnimating
{
    if(!self.shouldScrollCircularly || !self.enableAutoScroll){
        [self stopAnimating];
        return;
    }
    
    if(!self.timer){
        WeakObj(self);
        self.timer = [GKCountDownTimer timerWithTime:GKCountDownInfinite interval:self.animatedTimeInterval];
        self.timer.shouldStartImmediately = NO;
        self.timer.tickHandler = ^(NSTimeInterval timeLeft){
            [selfWeak scrollAnimated];
        };
    }
    if(!self.timer.isExcuting){
        [self.timer start];
    }
}

///结束动画
- (void)stopAnimating
{
    if(self.timer && self.timer.isExcuting)
    {
        [self.timer stop];
    }
}

// MARK: -  property

- (void)setAnimatedTimeInterval:(NSTimeInterval)animatedTimeInterval
{
    if(_animatedTimeInterval != animatedTimeInterval){
        _animatedTimeInterval = animatedTimeInterval;
        BOOL excuting = self.timer.isExcuting;
        self.timer.timeInterval = animatedTimeInterval;
        if(excuting){
            [self.timer start];
        }
    }
}

- (void)setEnableScrollCircularly:(BOOL)enableScrollCircularly
{
    if(_enableScrollCircularly != enableScrollCircularly){
        _enableScrollCircularly = enableScrollCircularly;
        [self reloadData];
    }
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    if(_showPageControl != showPageControl){
        _showPageControl = showPageControl;
        if(_showPageControl){
            if(!self.pageControl){
                _pageControl = [GKPageControl new];
                _pageControl.hidesForSinglePage = YES;
                [_pageControl addTarget:self action:@selector(pageDidChange:) forControlEvents:UIControlEventValueChanged];
                [self addSubview:_pageControl];
                
                [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(0);
                    make.bottom.equalTo(0);
                }];
            }
        }
        self.pageControl.hidden = !_showPageControl;
    }
}

- (void)setEnableAutoScroll:(BOOL)enableAutoScroll
{
    if(_enableAutoScroll != enableAutoScroll){
        _enableAutoScroll = enableAutoScroll;
        if(_enableAutoScroll && !self.decelerating && !self.dragging){
            [self startAnimating];
        }else{
            [self stopAnimating];
        }
    }
}

- (NSInteger)visibleIndex
{
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if(indexPath){
        return [self getActualIndexFromIndex:indexPath.item];
    }
    return NSNotFound;
}

// MARK: -  private method

//点击pageControl
- (void)pageDidChange:(UIPageControl*) pageControl
{
    [self scrollToIndex:pageControl.currentPage animated:YES];
}

//获取实际的内容下标
- (NSInteger)getActualIndexFromIndex:(NSInteger) index
{
    NSInteger pageIndex = index;
    
    if(_shouldScrollCircularly){
        pageIndex = index - 1;
        if(pageIndex < 0){
            pageIndex = _numberOfCells - 1;
        }
        
        if(pageIndex >= _numberOfCells){
            pageIndex = 0;
        }
    }
    return pageIndex;
}

//计时器滚动
- (void)scrollAnimated
{
    if(self.numberOfCells == 0)
        return;
    [self pageChangedAnimated:YES];
}

//滚动动画
- (void)pageChangedAnimated:(BOOL) flag
{
    NSInteger page = self.visibleIndex; // 获取当前的page
    if(page < self.numberOfCells){
        [self scrollToIndex:page + 1 animated:flag];
    }
}

// MARK: -  UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = _numberOfCells;
    if(self.shouldScrollCircularly){
        count += 2;
    }
    
    return count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(bannerView:cellForIndexPath:atIndex:)]){
        return [self.delegate bannerView:self cellForIndexPath:indexPath atIndex:[self getActualIndexFromIndex:indexPath.item]];
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if([self.delegate respondsToSelector:@selector(bannerView:didSelectCellAtIndex:)]){
        [self.delegate bannerView:self didSelectCellAtIndex:[self getActualIndexFromIndex:indexPath.item]];
    }
}

// MARK: -  UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopAnimating];
    self.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self startAnimating];
        self.contentOffset = CGPointZero;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(!scrollView.dragging){
        [self startAnimating];
        self.contentOffset = CGPointZero;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    switch (_scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal : {
            CGFloat pagewidth = scrollView.gkWidth;
            int page = floor(scrollView.contentOffset.x / pagewidth);
            if(self.shouldScrollCircularly){
                if(page == 0){
                    if(self.contentOffset.x > scrollView.contentOffset.x){
                        [self.collectionView scrollRectToVisible:CGRectMake(pagewidth * (_numberOfCells + 1), 0, pagewidth, scrollView.gkHeight) animated:NO]; // 最后+1,循环到第1页
                        self.contentOffset = CGPointMake(pagewidth * (_numberOfCells + 1), 0);
                        self.pageControl.currentPage = _numberOfCells - 1;
                    }
                }else if (page >= (_numberOfCells + 1)){
                    if(self.contentOffset.x < scrollView.contentOffset.x){
                        [self.collectionView scrollRectToVisible:CGRectMake(pagewidth, 0, pagewidth, scrollView.gkHeight) animated:NO]; // 最后+1,循环第1页
                        self.pageControl.currentPage = 0;
                    }
                }else{
                    self.pageControl.currentPage = [self getActualIndexFromIndex:page];
                }
            }else{
                self.pageControl.currentPage = page;
            }
        }
            break;
        case UICollectionViewScrollDirectionVertical : {
            CGFloat pageHeight = scrollView.gkHeight;
            int page = floor(scrollView.contentOffset.y / pageHeight);
            
            if(self.shouldScrollCircularly){
                if(page == 0){
                    if(self.contentOffset.y > scrollView.contentOffset.y){
                        [self.collectionView scrollRectToVisible:CGRectMake(0, pageHeight * (_numberOfCells + 1), scrollView.gkWidth, pageHeight) animated:NO]; // 最后+1,循环到第1页
                        self.contentOffset = CGPointMake(0, self.gkHeight * (_numberOfCells + 1));
                        self.pageControl.currentPage = _numberOfCells - 1;
                    }
                }else if (page >= (_numberOfCells + 1)){
                    if(self.contentOffset.y < scrollView.contentOffset.y){
                        [self.collectionView scrollRectToVisible:CGRectMake(0, pageHeight, scrollView.gkWidth, pageHeight) animated:NO]; // 最后+1,循环第1页
                        self.pageControl.currentPage = 0;
                    }
                }else{
                    self.pageControl.currentPage = [self getActualIndexFromIndex:page];
                }
            }else{
                self.pageControl.currentPage = page;
            }
        }
            break;
    }
}

@end
