//
//  GKTabMenuBar.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKTabMenuBar.h"
#import "GKTabMenuBarCell.h"
#import "UICollectionView+GKUtils.h"
#import "NSString+GKUtils.h"
#import "NSObject+GKUtils.h"
#import "UIColor+GKUtils.h"
#import "UIFont+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "UIApplication+GKTheme.h"
#import "UIView+GKUtils.h"
#import "GKDivider.h"

@interface GKTabMenuBar ()

@end

@implementation GKTabMenuBar

@dynamic items;
@dynamic delegate;

- (instancetype)initWithTitles:(NSArray<NSString*> *)titles
{
    return [self initWithFrame:CGRectZero titles:titles];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString*> *) titles
{
    self = [super initWithFrame:frame];
    if(self){
        self.titles = titles;
    }
    return self;
}

- (void)didInitCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerClass:[GKTabMenuBarCell class]];
}

- (CGFloat)onMeasureItems
{
    CGFloat totalWidth = 0;
    int i = 0;
    
    UIFont *font = self.normalFont;
    if (self.selectedFont.pointSize > font.pointSize) {
        font = self.selectedFont;
    }
    for(GKTabMenuBarItem *item in self.items){
        CGSize size = [item.title gkStringSizeWithFont:font];
        
        if(item.icon != nil){
            size.width += item.icon.size.width + item.iconPadding;
            size.height = MAX(size.height, item.icon.size.height);
        }
        item.contentSize = size;
        item.itemWidth = size.width + self.itemPadding;
        
        totalWidth += item.itemWidth;
        if(i != self.items.count - 1){
            totalWidth += self.itemSpacing;
        }
        i ++;
    }
    return totalWidth;
}

// MARK: - UICollectionView delegate

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKTabMenuBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GKTabMenuBarCell gkNameOfClass] forIndexPath:indexPath];
    
    BOOL tick = self.selectedIndex == indexPath.item;
    GKTabMenuBarItem *item = self.items[indexPath.item];
    [cell.button setTitleColor:tick ? self.selectedTextColor : self.normalTextColor forState:UIControlStateNormal];
    [cell.button.titleLabel setFont:self.selectedIndex == indexPath.item ? self.selectedFont : self.normalFont];
    cell.item = item;
    cell.tick = tick;
    cell.divider.hidden = !self.displayItemDidvider || indexPath.item == self.items.count - 1 || self.currentStyle == GKMenuBarStyleFit;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKTabMenuBarItem *item = self.items[indexPath.item];
    if(item.customView){
        if([self.delegate respondsToSelector:@selector(menuBar:willDisplayCustomView:atIndex:)]){
            [self.delegate menuBar:self willDisplayCustomView:item.customView atIndex:indexPath.item];
        }
    }
}

- (void)onSelectItemAtIndex:(NSUInteger)index oldIndex:(NSUInteger)oldIndex
{
    //取消以前的选中状态
    GKTabMenuBarCell *cell = [self cellForIndex:oldIndex];
    cell.tick = NO;
    cell = [self cellForIndex:index];
    cell.tick = YES;
}

// MARK: - Property

- (UIColor *)normalTextColor
{
    if(!_normalTextColor){
        return [UIColor darkGrayColor];
    }
    return _normalTextColor;
}

- (UIFont *)normalFont
{
    if(!_normalFont){
        return [UIFont systemFontOfSize:13];
    }
    
    return _normalFont;
}

- (UIColor *)selectedTextColor
{
    if(!_selectedTextColor){
        return UIColor.gkThemeColor;
    }
    return _selectedTextColor;
}

- (UIFont *)selectedFont
{
    if(!_selectedFont){
        return self.normalFont;
    }
    return _selectedFont;
}

- (void)setTitles:(NSArray *)titles
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:titles.count];
    
    for(NSString *title in titles){
        [items addObject:[GKTabMenuBarItem itemWithTitle:title]];
    }
    self.items = items;
}

- (NSArray<NSString *> *)titles
{
    if(self.items.count > 0){
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:self.items.count];
        for(GKTabMenuBarItem *item in self.items){
            NSString *title = item.title;
            if(title == nil){
                title = @"";
            }
            [titles addObject:title];
        }
        
        return [titles copy];
    }
    return nil;
}

// MARK: - 设置

- (void)setBadgeValue:(NSString*) badgeValue forIndex:(NSUInteger) index
{
    NSAssert(index < self.items.count, @"GKMenuBar setBadgeValue: forIndex:，index %ld 已越界", (long)index);
    
    GKTabMenuBarItem *item = self.items[index];
    item.badgeNumber = badgeValue;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)setTitle:(NSString*) title forIndex:(NSUInteger) index
{
    NSAssert(index < self.items.count, @"GKMenuBar setIcon: forIndex:，index %ld 已越界", (long)index);
    
    GKTabMenuBarItem *item = self.items[index];
    item.title = title;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)setIcon:(UIImage*) icon forIndex:(NSUInteger) index
{
    NSAssert(index < self.items.count, @"GKMenuBar setIcon: forIndex:，index %ld 已越界", (long)index);
    
    GKTabMenuBarItem *item = self.items[index];
    item.icon = icon;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)setSelectedIcon:(UIImage*) icon forIndex:(NSUInteger) index
{
    NSAssert(index < self.items.count, @"GKMenuBar setSelectedIcon: forIndex:，index %ld 已越界", (long)index);
    
    GKTabMenuBarItem *item = self.items[index];
    item.selectedIcon = icon;
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)setPercent:(float) percent forIndex:(NSUInteger) index
{
    [super setPercent:percent forIndex:index];
    if(!self.measureEnabled)
        return;
    
    GKTabMenuBarCell *cell1 = (GKTabMenuBarCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
    GKTabMenuBarCell *cell2 = (GKTabMenuBarCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    [cell1.button setTitleColor:[self getColorFrom:self.selectedTextColor to:self.normalTextColor percent:percent] forState:UIControlStateNormal];
    [cell2.button setTitleColor:[self getColorFrom:self.normalTextColor to:self.selectedTextColor percent:percent] forState:UIControlStateNormal];
}

- (UIColor*)getColorFrom:(UIColor*) from to:(UIColor*) to percent:(float) percent
{
    NSDictionary *fromARGB = from.gkColorARGB;
    NSDictionary *toARGB = to.gkColorARGB;
    CGFloat red = [fromARGB[GKColorRed] floatValue] + ([toARGB[GKColorRed] floatValue] - [fromARGB[GKColorRed] floatValue]) * percent;
    CGFloat green = [fromARGB[GKColorGreen] floatValue] + ([toARGB[GKColorGreen] floatValue] - [fromARGB[GKColorGreen] floatValue]) * percent;
    CGFloat blue = [fromARGB[GKColorBlue] floatValue] + ([toARGB[GKColorBlue] floatValue] - [fromARGB[GKColorBlue] floatValue]) * percent;
    CGFloat alpha = [fromARGB[GKColorAlpha] floatValue] + ([toARGB[GKColorAlpha] floatValue] - [fromARGB[GKColorAlpha] floatValue]) * percent;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


@end
