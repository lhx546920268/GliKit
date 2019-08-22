//
//  GKMenuBar.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKMenuBar.h"
#import "GKMenuBarCell.h"
#import "UICollectionView+GKUtils.h"
#import "NSString+GKUtils.h"
#import "NSObject+GKUtils.h"
#import "UIColor+GKUtils.h"
#import "UIFont+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "UIApplication+GKTheme.h"
#import "UIView+GKUtils.h"

@interface GKMenuBar ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView *collectionView;

/**
 菜单按钮宽度 当style = GKMenuBarStyleFill 时有效
 */
@property(nonatomic,assign) CGFloat fillItemWidth;

/**
 是否是点击按钮
 */
@property(nonatomic,assign) BOOL isTapItem;

/**
 内容宽度
 */
@property(nonatomic,readonly) CGFloat contentWidth;

/**
 是否已经可以计算item
 */
@property(nonatomic,assign) BOOL mesureEnable;

@end

@implementation GKMenuBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialization];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithTitles:nil];
}

- (instancetype)initWithTitles:(NSArray<NSString*> *)titles
{
    return [self initWithFrame:CGRectZero titles:titles];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString*> *) titles
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialization];
        self.titles = titles;
    }
    return self;
}

- (instancetype)initWithItems:(NSArray<GKMenuBarItem*> *)items
{
    return [self initWithFrame:CGRectZero items:items];
}

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<GKMenuBarItem*> *) items
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialization];
        self.items = items;
    }
    
    return self;
}

///初始化
- (void)initialization
{
    self.backgroundColor = [UIColor whiteColor];
    
    _shouldDetectStyleAutomatically = YES;
    _normalTextColor = [UIColor darkGrayColor];
    _normalFont = [UIFont systemFontOfSize:13];
    _selectedTextColor = UIColor.gkThemeColor;
    _selectedFont = _normalFont;
    
    _itemPadding = 10.0;
    _callDelegateWhenSetSelectedIndex = NO;
    _itemInterval = 5.0;
    _showSeparator = YES;
    
    _indicatorColor = UIColor.gkThemeColor;
    _indicatorHeight = 2.0;
    
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
    [collectionView registerClass:[GKMenuBarCell class]];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    _indicator = [UIView new];
    _indicator.backgroundColor = self.indicatorColor;
    [self.collectionView addSubview:_indicator];
    
    //分割线
    _bottomSeparator = [UIView new];
    _bottomSeparator.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self addSubview:_bottomSeparator];
    
    _topSeparator = [UIView new];
    _topSeparator.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self addSubview:_topSeparator];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(self.gkWidth > 0 && self.gkHeight > 0 && !CGSizeEqualToSize(self.bounds.size, _collectionView.frame.size)){
        _topSeparator.frame = CGRectMake(0, 0, self.gkWidth, 0.5f);
        _bottomSeparator.frame = CGRectMake(0, self.gkHeight - 0.5f, self.gkWidth, 0.5f);
        _collectionView.frame = self.bounds;
        
        self.mesureEnable = YES;
        
        [self reloadData];
        [self layoutIndicatorWithAnimate:NO];
    }
}

///刷新数据
- (void)reloadData
{
    if(self.mesureEnable){
        [self mesureItems];
        [self.collectionView reloadData];
    }
}

///测量item
- (void)mesureItems
{
    if(!self.mesureEnable)
        return;
    
    CGFloat totalWidth = 0;
    int i = 0;
    for(GKMenuBarItem *info in self.items){
        info.itemWidth = [info.title gkStringSizeWithFont:_normalFont].width + self.itemPadding;
        if(info.icon != nil){
            info.itemWidth += info.icon.size.width + info.iconPadding;
        }
        
        totalWidth += info.itemWidth;
        if(i != self.items.count){
            totalWidth += self.itemInterval;
        }
        i ++;
    }
    
    if(self.shouldDetectStyleAutomatically){
        _style = totalWidth > self.contentWidth ? GKMenuBarStyleFit : GKMenuBarStyleFill;
    }
    _fillItemWidth = self.contentWidth / self.items.count;
    
    !self.measureCompletionHandler ?: self.measureCompletionHandler();
}

///内容宽度
- (CGFloat)contentWidth
{
    return (self.gkWidth - _contentInset.left - _contentInset.right);
}

- (CGFloat)menuBarWidth
{
    if(self.items.count == 0)
        return 0;
    CGFloat width = _contentInset.left + _contentInset.right + (self.items.count - 1) * self.itemInterval;
    for(GKMenuBarItem *info in self.items){
        width += ceil([info.title gkStringSizeWithFont:self.normalFont].width) + self.itemPadding;
    }
    
    return width;
}

//MARK:- UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(!self.mesureEnable){
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
    switch(_style){
        case GKMenuBarStyleFit : {
            GKMenuBarItem *info = [_items objectAtIndex:indexPath.item];
            return CGSizeMake(info.itemWidth, collectionView.gkHeight);
        }
            break;
        case GKMenuBarStyleFill :{
            return CGSizeMake(_fillItemWidth, collectionView.gkHeight);
        }
            break;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return _style == GKMenuBarStyleFill ? 0 : self.itemInterval;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKMenuBarCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:[GKMenuBarCell gkNameOfClass] forIndexPath:indexPath];
    
    GKMenuBarItem *info = [self.items objectAtIndex:indexPath.item];
    [item.button setTitleColor:_selectedTextColor forState:UIControlStateSelected];
    [item.button setTitleColor:_normalTextColor forState:UIControlStateNormal];
    [item.button.titleLabel setFont:_selectedIndex == indexPath.item ? _selectedFont : _normalFont];
    item.info = info;
    item.tick = self.selectedIndex == indexPath.item;
    item.separator.hidden = !self.showSeparator || indexPath.item == _items.count - 1 || _style == GKMenuBarStyleFit;
    
    return item;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKMenuBarItem *info = self.items[indexPath.item];
    if(info.customView){
        if([self.delegate respondsToSelector:@selector(menuBar:willDisplayCustomView:atIndex:)]){
            [self.delegate menuBar:self willDisplayCustomView:info.customView atIndex:indexPath.item];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    BOOL enable = YES;
    
    if([self.delegate respondsToSelector:@selector(menuBar:shouldSelectItemAtIndex:)]){
        enable = [self.delegate menuBar:self shouldSelectItemAtIndex:indexPath.item];
    }
    
    if(enable){
        self.isTapItem = YES;
        [self setSelectedIndex:indexPath.item animated:YES];
        self.isTapItem = NO;
    }
}

//MARK:- property

- (void)setTitles:(NSArray *)titles
{
    if(_titles != titles){
        NSMutableArray *infos = [NSMutableArray arrayWithCapacity:titles.count];
        
        for(NSString *title in titles){
            [infos addObject:[GKMenuBarItem infoWithTitle:title]];
        }
        self.items = infos;
    }
}

- (void)setItems:(NSArray *)itmeInfos
{
    if(_items != itmeInfos){
        _items = [itmeInfos copy];
        
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:_items.count];
        for(GKMenuBarItem *info in _items){
            NSString *title = info.title;
            if(title == nil){
                title = @"";
            }
            [titles addObject:title];
        }
        
        _titles = [titles copy];
        
        [self reloadData];
        self.selectedIndex = 0;
    }
}

- (void)setShowSeparator:(BOOL)showSeparator
{
    if(_showSeparator != showSeparator){
        _showSeparator = showSeparator;
        [self.collectionView reloadData];
    }
}

- (void)setNormalTextColor:(UIColor *) color
{
    if(color == nil)
        color = [UIColor darkGrayColor];
    
    if(![_normalTextColor isEqualToColor:color]){
        _normalTextColor = color;
        [self.collectionView reloadData];
    }
}

- (void)setNormalFont:(UIFont *) font
{
    if(font == nil)
        font = [UIFont systemFontOfSize:13];
    if(![_normalFont isEqualToFont:font]){
        _normalFont = font;
        
        [self mesureItems];
        [self.collectionView reloadData];
        [self layoutIndicatorWithAnimate:NO];
    }
}

- (void)setSelectedTextColor:(UIColor *) color
{
    if(color == nil)
        color = UIColor.gkThemeColor;
    
    if(![_selectedTextColor isEqualToColor:color]){
        _selectedTextColor = color;
        [self.collectionView reloadData];
    }
}

- (void)setSelectedFont:(UIFont *) font
{
    if(font == nil)
        font = [UIFont systemFontOfSize:13];
    if(![_selectedFont isEqualToFont:font]){
        _selectedFont = font;
        
        [self.collectionView reloadData];
    }
}

- (void)setItemInterval:(CGFloat)buttonInterval
{
    if(_itemInterval != buttonInterval){
        _itemInterval = buttonInterval;
        
        if(_style == GKMenuBarStyleFit){
            [self.collectionView reloadData];
            [self layoutIndicatorWithAnimate:NO];
        }
    }
}

- (void)setItemPadding:(CGFloat) padding
{
    if(_itemPadding != padding){
        CGFloat oldPadding = _itemPadding;
        _itemPadding = padding;
        
        for(GKMenuBarItem *info in self.items){
            info.itemWidth += _itemPadding - oldPadding;
        }
        
        [self.collectionView reloadData];
        [self layoutIndicatorWithAnimate:NO];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if(!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)){
        _contentInset = contentInset;
        [self.collectionView reloadData];
        [self layoutIndicatorWithAnimate:NO];
    }
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight
{
    if(_indicatorHeight != indicatorHeight){
        _indicatorHeight = indicatorHeight;
        _indicator.gkHeight = _indicatorHeight;
    }
}

- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    if(![_indicatorColor isEqualToColor:indicatorColor]){
        _indicatorColor = indicatorColor;
        _indicator.backgroundColor = _indicatorColor;
    }
}

//MARK:- public method

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL) flag
{
    if(selectedIndex >= self.items.count)
        return;
    
    if(_selectedIndex == selectedIndex && (_isTapItem || _callDelegateWhenSetSelectedIndex)){
        if([self.delegate respondsToSelector:@selector(menuBar:didSelectHighlightedItemAtIndex:)]){
            [self.delegate menuBar:self didSelectHighlightedItemAtIndex:selectedIndex];
        }
        return;
    }
    
    if(_selectedIndex == selectedIndex)
        return;
    
    //取消以前的选中状态
    GKMenuBarCell *item = [self itemForIndex:_selectedIndex];
    item.tick = NO;
    
    NSInteger previousIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    
    [self layoutIndicatorWithAnimate:flag];
    [self scrollToVisibleRectWithAnimate:flag];
    
    if(previousIndex < self.items.count && ( _isTapItem || _callDelegateWhenSetSelectedIndex)){
        if([self.delegate respondsToSelector:@selector(menuBar:didDeselectItemAtIndex:)]){
            [self.delegate menuBar:self didDeselectItemAtIndex:previousIndex];
        }
    }
    
    if(_isTapItem || _callDelegateWhenSetSelectedIndex){
        if([self.delegate respondsToSelector:@selector(menuBar:didSelectItemAtIndex:)]){
            [self.delegate menuBar:self didSelectItemAtIndex:_selectedIndex];
        }
    }
}

///获取下划线x轴位置
- (CGFloat)indicatorXForIndex:(NSUInteger) index
{
    GKMenuBarCell *item = [self itemForIndex:index];
    GKMenuBarItem *info = [self.items objectAtIndex:index];
    
    CGFloat x = 0;
    if(!CGRectEqualToRect(CGRectZero, item.frame)){
        x = item.gkLeft + (item.gkWidth - info.itemWidth) / 2.0;
    }else{
        switch (_style) {
            case GKMenuBarStyleFit :
                x = _contentInset.left;
                for(NSInteger i = 0;i < index;i ++){
                    info = [self.items objectAtIndex:i];
                    x += info.itemWidth + self.itemInterval;
                }
                break;
            case GKMenuBarStyleFill :
                x = _contentInset.left + (_fillItemWidth - info.itemWidth) / 2;;
                for(NSInteger i = 0;i < index;i ++){
                    x += _fillItemWidth;
                }
                break;
        }
    }
    return x;
}

///设置下划线的位置
- (void)layoutIndicatorWithAnimate:(BOOL) flag
{
    if(!self.mesureEnable)
        return;
    GKMenuBarCell *item = [self itemForIndex:_selectedIndex];
    item.tick = YES;
    CGRect frame = _indicator.frame;
    
    frame.origin.x = [self indicatorXForIndex:_selectedIndex];
    frame.size.height = self.indicatorHeight;
    frame.origin.y = self.gkHeight - self.indicatorHeight;
    
    if(_style == GKMenuBarStyleFill && self.indicatorShouldFill){
        frame.size.width = _fillItemWidth;
        if(self.indicatorShouldFill){
            frame.origin.x = _fillItemWidth * _selectedIndex;
        }
    }else{
        GKMenuBarItem *info = [self.items objectAtIndex:_selectedIndex];
        frame.size.width = info.itemWidth;
    }
    
    if(flag){
        [UIView animateWithDuration:0.25 animations:^(void){
            
            self->_indicator.frame = frame;
        }];
    }else{
        _indicator.frame = frame;
    }
}

- (void)setPercent:(float) percent forIndex:(NSUInteger) index
{
    if(!self.mesureEnable)
        return;
    
#ifdef DEBUG
    NSAssert(index < self.items.count, @"GKMenuBar setPercent: forIndex:，index %ld 已越界", (long)index);
#endif
    if(percent > 1.0){
        percent = 1.0;
    }else if(percent < 0){
        percent = 0;
    }
    
    CGRect frame = _indicator.frame;
    
    CGFloat x = [self indicatorXForIndex:_selectedIndex];
    CGFloat offset = percent * ([self indicatorXForIndex:index] - x);
    
    GKMenuBarItem *info1 = [self.items objectAtIndex:_selectedIndex];
    GKMenuBarItem *info2 = [self.items objectAtIndex:index];
    
    frame.origin.x = x + offset;
    frame.size.width = info1.itemWidth + (info2.itemWidth - info1.itemWidth) * percent;
    _indicator.frame = frame;
}

///滚动到可见位置
- (void)scrollToVisibleRectWithAnimate:(BOOL) flag
{
    if(_selectedIndex >= self.items.count || _style != GKMenuBarStyleFit || !self.mesureEnable)
        return;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:flag];
}

- (void)setBadgeValue:(NSString*) badgeValue forIndex:(NSUInteger) index
{
#ifdef DEBUG
    NSAssert(index < self.items.count, @"GKMenuBar setBadgeValue: forIndex:，index %ld 已越界", (long)index);
#endif
    
    GKMenuBarItem *info = [self.items objectAtIndex:index];
    info.badgeNumber = badgeValue;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]];
}

- (void)setTitle:(NSString*) title forIndex:(NSUInteger) index
{
#ifdef DEBUG
    NSAssert(index < self.items.count, @"GKMenuBar setIcon: forIndex:，index %ld 已越界", (long)index);
#endif
    
    GKMenuBarItem *info = [self.items objectAtIndex:index];
    info.title = title;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]];
}

- (void)setIcon:(UIImage*) icon forIndex:(NSUInteger) index
{
#ifdef DEBUG
    NSAssert(index < self.items.count, @"GKMenuBar setIcon: forIndex:，index %ld 已越界", (long)index);
#endif
    
    GKMenuBarItem *info = [self.items objectAtIndex:index];
    info.icon = icon;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]];
}

- (void)setSelectedIcon:(UIImage*) icon forIndex:(NSUInteger) index
{
#ifdef DEBUG
    NSAssert(index < self.items.count, @"GKMenuBar setSelectedIcon: forIndex:，index %ld 已越界", (long)index);
#endif
    
    GKMenuBarItem *info = [self.items objectAtIndex:index];
    info.selectedIcon = icon;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]];
}

///通过下标获取按钮
- (id)itemForIndex:(NSUInteger) index
{
    if(index >= _items.count || !self.mesureEnable)
        return nil;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *item = (GKMenuBarCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if(item == nil){
        item = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    }
    
    return item;
}


@end
