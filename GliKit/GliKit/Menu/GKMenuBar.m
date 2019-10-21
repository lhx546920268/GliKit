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

@interface GKMenuBar ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 是否是点击按钮
 */
@property(nonatomic, assign) BOOL isClickItem;

/**
 是否已经可以计算item
 */
@property(nonatomic, assign) BOOL measureEnable;

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
    self.itemInterval = 5.0;
    self.indicatorHeight = 2.0;
    
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
        
        self.measureEnable = YES;
        
        [self reloadData];
        [self layoutIndicatorWithAnimate:NO];
    }
}

///刷新数据
- (void)reloadData
{
    if(self.measureEnable){
        [self measureItems];
        [self.collectionView reloadData];
    }
}

///测量item
- (void)measureItems
{
    if(!self.measureEnable)
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
    !self.measureCompletionHandler ?: self.measureCompletionHandler();
}

- (CGFloat)onMeasureItems
{
    @throw [NSException exceptionWithName:@"CASubClassNotImplExpection" reason:[NSString stringWithFormat:@"%@ 必须重写 %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd)] userInfo:nil];
    return 0;
}

- (CGFloat)contentWidth
{
    return (self.gkWidth - self.contentInset.left - self.contentInset.right);
}

// MARK: - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(!self.measureEnable){
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
    return self.currentStyle == GKMenuBarStyleFill ? 0 : self.itemInterval;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:@"CASubClassNotImplExpection" reason:[NSString stringWithFormat:@"%@ 必须重写 %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd)] userInfo:nil];
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    BOOL enable = YES;
    
    if([self.delegate respondsToSelector:@selector(menuBar:shouldSelectItemAtIndex:)]){
        enable = [self.delegate menuBar:self shouldSelectItemAtIndex:indexPath.item];
    }
    
    if(enable){
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
    if(!_indicator && self.indicatorHeight > 0){
        _indicator = [UIView new];
        self.indicator.backgroundColor = self.indicatorColor;
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
    UICollectionViewCell *cell = [self itemForIndex:index];
    GKMenuBarItem *item = self.items[index];
    
    CGFloat x = 0;
    if(!CGRectEqualToRect(CGRectZero, cell.frame)){
        x = cell.gkLeft + (cell.gkWidth - item.itemWidth) / 2.0;
    }else{
        x = self.contentInset.left;
        CGFloat itemInterval = 0;
        if(self.currentStyle == GKMenuBarStyleFit){
            itemInterval = self.itemInterval;
        }
        
        for(NSInteger i = 0;i < index;i ++){
            item = [self.items objectAtIndex:i];
            x += item.itemWidth + itemInterval;
        }
    }
    return x;
}

///设置下划线的位置
- (void)layoutIndicatorWithAnimate:(BOOL) flag
{
    if(!self.measureEnable)
        return;
    if(self.indicator){
        CGRect frame = self.indicator.frame;
        
        frame.origin.x = [self indicatorXForIndex:_selectedIndex];
        frame.size.height = self.indicatorHeight;
        frame.origin.y = self.gkHeight - self.indicatorHeight;
        
        GKMenuBarItem *item = self.items[_selectedIndex];
        
        if(self.currentStyle == GKMenuBarStyleFill && self.indicatorShouldFill){
            frame.size.width = item.itemWidth;
        }else{
            frame.size.width = item.contentSize.width + self.itemPadding;
        }
        
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
    if(selectedIndex >= self.items.count)
        return;
    
    if(_selectedIndex == selectedIndex && (_isClickItem || _callDelegateWhenSetSelectedIndex)){
        if([self.delegate respondsToSelector:@selector(menuBar:didSelectHighlightedItemAtIndex:)]){
            [self.delegate menuBar:self didSelectHighlightedItemAtIndex:selectedIndex];
        }
        return;
    }
    
    if(_selectedIndex == selectedIndex)
        return;
    
    NSInteger oldIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    [self onSelectItemAtIndex:_selectedIndex oldIndex:oldIndex];
    
    [self layoutIndicatorWithAnimate:flag];
    [self scrollToVisibleRectWithAnimate:flag];
    
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
    if(!self.measureEnable)
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
        
        GKMenuBarItem *item1 = self.items[_selectedIndex];
        GKMenuBarItem *item2 = self.items[index];
        
        frame.origin.x = x + offset;
        frame.size.width = item1.itemWidth + (item2.itemWidth - item1.itemWidth) * percent;
        
        self.indicator.frame = frame;
    }
}

///滚动到可见位置
- (void)scrollToVisibleRectWithAnimate:(BOOL) flag
{
    if(_selectedIndex >= self.items.count || self.currentStyle != GKMenuBarStyleFit || !self.measureEnable)
        return;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:flag];
}

///通过下标获取按钮
- (UICollectionViewCell*)itemForIndex:(NSUInteger) index
{
    if(index >= _items.count || !self.measureEnable)
        return nil;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell == nil){
        cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    }
    
    return cell;
}


@end
