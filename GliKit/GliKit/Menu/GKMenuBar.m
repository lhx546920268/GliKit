//
//  GKMenuBar.m
//  GliKit
//
//  Created by 罗海雄 on 2019/10/21.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKMenuBar.h"
#import "GKMenuBarItem.h"
#import "NSString+GKUtils.h"
#import "NSObject+GKUtils.h"
#import "UIColor+GKUtils.h"
#import "UIFont+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "UIApplication+GKTheme.h"
#import "UIView+GKUtils.h"
#import "GKBaseDefines.h"

@interface GKMenuBar ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

///是否是点击按钮
@property(nonatomic, assign) BOOL isClickItem;

///正在滑动到中间的下标
@property(nonatomic, assign) NSInteger scrollingToCenterIndex;

@end

@implementation GKMenuBar

@synthesize indicator = _indicator;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initViews];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero items:nil];
}

- (instancetype)initWithItems:(NSArray<GKMenuBarItem*> *)items
{
    return [self initWithFrame:CGRectZero items:items];
}

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<GKMenuBarItem*> *) items
{
    self = [super initWithFrame:frame];
    if(self){
        [self initViews];
        self.items = items;
    }
    
    return self;
}

///初始化
- (void)initViews
{
    self.backgroundColor = [UIColor whiteColor];
    self.itemPadding = 10.0;
    self.itemSpacing = 5.0;
    self.indicatorSize = CGSizeMake(0, 2.0);
    
    _callDelegateWhenSetSelectedIndex = NO;
    _selectedIndex = 0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.scrollsToTop = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;

    [self didInitCollectionView:collectionView];
    
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)didInitCollectionView:(UICollectionView *)collectionView
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(self.gkWidth > 0 && self.gkHeight > 0 && !CGSizeEqualToSize(self.bounds.size, _collectionView.frame.size)){
        _collectionView.frame = self.bounds;
        
        _measureEnabled = YES;
        
        [self reloadData];
        [self layoutIndicatorWithAnimate:NO];
    }
}

///刷新数据
- (void)reloadData
{
    if(self.measureEnabled){
        [self measureItems];
        [self.collectionView reloadData];
    }
}

///测量item
- (void)measureItems
{
    if(!self.measureEnabled)
        return;
    
    CGFloat totalWidth = [self onMeasureItems];
    
    switch (self.style) {
        case GKMenuBarStyleAutoDetect : {
            _currentStyle = totalWidth > self.contentWidth ? GKMenuBarStyleFit : GKMenuBarStyleFill;
        }
            break;
        default : {
            _currentStyle = self.style;
        }
            break;
    }
    
    if (_currentStyle == GKMenuBarStyleFill) {
        CGFloat fillItemWidth = self.contentWidth / self.items.count;
        CGFloat spacing = (self.contentWidth - totalWidth + self.itemSpacing * (self.items.count - 1)) / self.items.count;
        for (GKMenuBarItem *item in self.items) {
            if (self.shouldEqualItemSpacing) {
                item.itemWidth += spacing;
            } else {
                item.itemWidth = fillItemWidth;
            }
        }
    }
    
    !self.measureCompletionHandler ?: self.measureCompletionHandler();
}

- (CGFloat)onMeasureItems
{
    GKThrowNotImplException
}

- (CGFloat)contentWidth
{
    return (self.gkWidth - self.contentInset.left - self.contentInset.right);
}

// MARK: - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(!self.measureEnabled){
        return 0;
    }
    return _items.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.contentInset;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKMenuBarItem *item = _items[indexPath.item];
    return CGSizeMake(item.itemWidth, collectionView.gkHeight - self.contentInset.top - self.contentInset.bottom);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.currentStyle == GKMenuBarStyleFill ? 0 : self.itemSpacing;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKThrowNotImplException
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    BOOL enabled = YES;
    
    if([self.delegate respondsToSelector:@selector(menuBar:shouldSelectItemAtIndex:)]){
        enabled = [self.delegate menuBar:self shouldSelectItemAtIndex:indexPath.item];
    }
    
    if(enabled){
        self.isClickItem = YES;
        [self setSelectedIndex:indexPath.item animated:YES];
        self.isClickItem = NO;
    }
}

// MARK: - Property

- (void)setItems:(NSArray *)items
{
    if(_items != items){
        _items = [items copy];
        [self reloadData];
        self.selectedIndex = 0;
    }
}

- (UIView *)indicator
{
    if(!_indicator && self.indicatorSize.height > 0){
        _indicator = [UIView new];
        _indicator.backgroundColor = self.indicatorColor;
        [self.collectionView addSubview:_indicator];
    }
    
    return _indicator;
}

- (UIColor *)indicatorColor
{
    if(!_indicatorColor){
        return UIColor.gkThemeColor;
    }
    return _indicatorColor;
}

// MARK: - 分割线

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //绘制分割线
    if(self.displayTopDivider || self.displayBottomDivider){
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, UIColor.gkSeparatorColor.CGColor);
        CGContextSetLineWidth(context, UIApplication.gkSeparatorHeight);
        
        CGFloat offset = UIApplication.gkSeparatorHeight / 2.0;
        
        if(self.displayTopDivider){
            CGContextMoveToPoint(context, 0, offset);
            CGContextAddLineToPoint(context, rect.size.width, offset);
        }
        
        if(self.displayBottomDivider){
            CGContextMoveToPoint(context, 0, rect.size.height - offset);
            CGContextAddLineToPoint(context, rect.size.width, rect.size.height - offset);
        }
        
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

///获取下划线x轴位置
- (CGFloat)indicatorXForIndex:(NSUInteger) index
{
    UICollectionViewCell *cell = [self cellForIndex:index];
    GKMenuBarItem *item = self.items[index];
    
    CGFloat x = 0;
    if(!CGRectEqualToRect(CGRectZero, cell.frame)){
        x = cell.gkLeft + (cell.gkWidth - [self indicatorWidthForIndex:index]) / 2.0;
    }else{
        x = self.contentInset.left + (item.itemWidth - [self indicatorWidthForIndex:index]) / 2;
        CGFloat spacing = 0;
        if(self.currentStyle == GKMenuBarStyleFit){
            spacing = self.itemSpacing;
        }
        
        for(NSInteger i = 0;i < index;i ++){
            item = self.items[i];
            x += item.itemWidth + spacing;
        }
    }
    return x;
}

///获取下划线宽度
- (CGFloat)indicatorWidthForIndex:(NSUInteger) index
{
    GKMenuBarItem *item = self.items[index];
    
    if(self.currentStyle == GKMenuBarStyleFill && self.indicatorSize.width < 0){
        return item.itemWidth;
    }else if(self.indicatorSize.width > 0 ) {
        return self.indicatorSize.width;
    }else{
        return item.contentSize.width + self.itemPadding;
    }
}

///设置下划线的位置
- (void)layoutIndicatorWithAnimate:(BOOL) flag
{
    if(!self.measureEnabled)
        return;
    
    if(self.indicator){
        CGRect frame = self.indicator.frame;
        
        frame.origin.x = [self indicatorXForIndex:_selectedIndex];
        frame.size.height = self.indicatorSize.height;
        frame.origin.y = self.gkHeight - self.indicatorSize.height - self.indicatorPadding;
        frame.size.width = [self indicatorWidthForIndex:_selectedIndex];
        
        if(flag){
            [UIView animateWithDuration:0.25 animations:^(void){
                
                self.indicator.frame = frame;
            }];
        }else{
            self.indicator.frame = frame;
        }
    }
}

// MARK: - 设置

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL) flag
{
    [self setSelectedIndex:selectedIndex animated:flag scrollToCenter:YES];
}

- (void)setSelectedIndexAndScrollToCenterIfNeeded:(NSUInteger)selectedIndex animated:(BOOL)flag
{
    [self setSelectedIndex:selectedIndex animated:flag scrollToCenter:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL) flag scrollToCenter:(BOOL) scrollToCenter
{
    if(selectedIndex >= self.items.count)
        return;
    
    if(_selectedIndex == selectedIndex){
        if(_isClickItem || _callDelegateWhenSetSelectedIndex){
            if([self.delegate respondsToSelector:@selector(menuBar:didSelectHighlightedItemAtIndex:)]){
                [self.delegate menuBar:self didSelectHighlightedItemAtIndex:selectedIndex];
            }
        }
        return;
    }
    
    NSInteger oldIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    [self onSelectItemAtIndex:_selectedIndex oldIndex:oldIndex];
    
    [self layoutIndicatorWithAnimate:flag];
    
    if (!scrollToCenter) {
        UICollectionViewCell *cell = [self cellForIndex:_selectedIndex];
        if (CGRectEqualToRect(cell.frame, CGRectZero)) {
            scrollToCenter = YES;
        } else {
            CGFloat offset = self.collectionView.contentOffset.x;
            if (cell.gkLeft < offset + self.contentInset.left) {
                scrollToCenter = YES;
            } else if (cell.gkRight > offset + self.collectionView.gkWidth - self.contentInset.right) {
                scrollToCenter = YES;
            }
        }
    }
    
    if (scrollToCenter) {
        [self scrollToVisibleRectWithAnimate:flag];
    }
    
    if(oldIndex < self.items.count && ( _isClickItem || _callDelegateWhenSetSelectedIndex)){
        if([self.delegate respondsToSelector:@selector(menuBar:didDeselectItemAtIndex:)]){
            [self.delegate menuBar:self didDeselectItemAtIndex:oldIndex];
        }
    }
    
    if(_isClickItem || _callDelegateWhenSetSelectedIndex){
        if([self.delegate respondsToSelector:@selector(menuBar:didSelectItemAtIndex:)]){
            [self.delegate menuBar:self didSelectItemAtIndex:_selectedIndex];
        }
    }
}

- (void)onSelectItemAtIndex:(NSUInteger)index oldIndex:(NSUInteger)oldIndex
{
    
}

- (void)setPercent:(float) percent forIndex:(NSUInteger) index
{
    if(!self.measureEnabled)
        return;
    
    if(self.indicator){
        NSAssert(index < self.items.count, @"GKMenuBar setPercent: forIndex:，index %ld 已越界", (long)index);
        if(percent > 1.0){
            percent = 1.0;
        }else if(percent < 0){
            percent = 0;
        }
        
        CGRect frame = self.indicator.frame;
        
        CGFloat x = [self indicatorXForIndex:_selectedIndex];
        CGFloat offset = percent * ([self indicatorXForIndex:index] - x);
        
        CGFloat width1 = [self indicatorWidthForIndex:_selectedIndex];
        CGFloat width2 = [self indicatorWidthForIndex:index];
        
        frame.origin.x = x + offset;
        frame.size.width = width1 + (width2 - width1) * percent;
        
        self.indicator.frame = frame;
        
        
        BOOL scrollToCenter = NO;
        offset = self.collectionView.contentOffset.x;
        if (self.indicator.gkLeft < offset + self.contentInset.left) {
            scrollToCenter = YES;
        } else if (self.indicator.gkRight > offset + self.collectionView.gkWidth - self.contentInset.right) {
            scrollToCenter = YES;
        }
        
        if (scrollToCenter) {
            [self scrollToVisibleRectWithAnimate:YES];
        }
    }
}

///滚动到可见位置
- (void)scrollToVisibleRectWithAnimate:(BOOL) flag
{
    if(_selectedIndex >= self.items.count || self.currentStyle != GKMenuBarStyleFit || !self.measureEnabled)
        return;
    if (_scrollingToCenterIndex != _selectedIndex) {
        _scrollingToCenterIndex = _selectedIndex;
        if (flag) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self->_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            } completion:^(BOOL finished) {
                self.scrollingToCenterIndex = NSNotFound;
            }];
        } else {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            self.scrollingToCenterIndex = NSNotFound;
        }
    }
}

///通过下标获取按钮
- (__kindof UICollectionViewCell*)cellForIndex:(NSUInteger) index
{
    if(index >= _items.count || !self.measureEnabled)
        return nil;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}


@end
