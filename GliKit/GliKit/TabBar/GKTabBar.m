//
//  GKTabBar.m
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import "GKTabBar.h"
#import "GKTabBarItem.h"
#import "GKBaseDefines.h"
#import "UIColor+GKTheme.h"
#import "UIColor+GKUtils.h"
#import "UIView+GKUtils.h"
#import "UIApplication+GKTheme.h"

@implementation GKTabBar

- (instancetype)initWithItems:(NSArray<GKTabBarItem*>*) items
{
    self = [super init];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.items = items;
        _selectedIndex = NSNotFound;
        
        _separator = [UIView new];
        _separator.backgroundColor = UIColor.gkSeparatorColor;
        _separator.userInteractionEnabled = NO;
        [self addSubview:_separator];
        
        [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.equalTo(0);
            make.height.equalTo(UIApplication.gkSeparatorHeight);
        }];
    }
    
    return self;
}

- (void)setItems:(NSArray<GKTabBarItem *> *)items
{
    if(_items != items){
        _items = items;
        
        //移除以前的item
        NSArray *subviews = self.subviews;
        for(UIView *view in subviews){
            if(view != self.separator){
                [view removeFromSuperview];
            }
        }
        
        GKTabBarItem *beforeItem = nil;
        CGFloat bottom = UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.bottom;
        for(NSUInteger i = 0;i < _items.count;i ++){
            GKTabBarItem *item = _items[i];
            [item addTarget:self action:@selector(handleTouchupInside:) forControlEvents:UIControlEventTouchUpInside];
            [self insertSubview:item belowSubview:self.separator];
            
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(0);
                make.bottom.equalTo(-bottom);
                if(beforeItem){
                    make.leading.equalTo(beforeItem.mas_trailing);
                    make.width.equalTo(beforeItem);
                }else{
                    make.leading.equalTo(0);
                }
                if(i == _items.count - 1){
                    make.trailing.equalTo(0);
                }
            }];

            beforeItem = item;
        }
    }
}

// MARK: - private method

//选中某个按钮
- (void)handleTouchupInside:(GKTabBarItem*) item
{
    if(item.selected == YES)
        return;
    
    NSInteger index = [self.items indexOfObject:item];
    BOOL shouldSelect = YES;
    if([self.delegate respondsToSelector:@selector(tabBar:shouldSelectItemAtIndex:)]){
        shouldSelect = [self.delegate tabBar:self shouldSelectItemAtIndex:index];
    }
    if(shouldSelect){
        self.selectedIndex = index;
    }
}

// MARK: - property

//设置选中的
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if(_selectedIndex != selectedIndex){
        
        if(_selectedIndex < _items.count){
            GKTabBarItem *item = _items[_selectedIndex];
            item.backgroundColor = [UIColor clearColor];
            item.selected = NO;
        }
        
        _selectedIndex = selectedIndex;
        GKTabBarItem *item = _items[_selectedIndex];
        item.selected = YES;
        if(self.selectedButtonBackgroundColor){
            item.backgroundColor = self.selectedButtonBackgroundColor;
        }
        
        if([self.delegate respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]){
            [self.delegate tabBar:self didSelectItemAtIndex:_selectedIndex];
        }
    }
}

//设置背景
- (void)setBackgroundView:(UIView *)backgroundView
{
    if(_backgroundView != backgroundView){
        [_backgroundView removeFromSuperview];
        _backgroundView = backgroundView;
        
        if(_backgroundView != nil){
            [self insertSubview:_backgroundView atIndex:0];
            [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(0);
            }];
        }
    }
}

- (void)setSelectedButtonBackgroundColor:(UIColor *)selectedButtonBackgroundColor
{
    if(![_selectedButtonBackgroundColor isEqualToColor:selectedButtonBackgroundColor]){
        if(selectedButtonBackgroundColor == nil)
            selectedButtonBackgroundColor = [UIColor clearColor];
        
        _selectedButtonBackgroundColor = selectedButtonBackgroundColor;
        GKTabBarItem *item = _items[_selectedIndex];
        item.backgroundColor = _selectedButtonBackgroundColor;
    }
}

/**设置选项卡边缘值
 *@param badgeValue 边缘值
 *@param index 下标
 */
- (void)setBadgeValue:(NSString*) badgeValue forIndex:(NSInteger) index;
{
#if CADebug
    NSAssert(index < _items.count, @"CATabBar setBadgeValue forIndex, index %d 越界", (int)index);
#endif
    GKTabBarItem *item = _items[index];
    item.badgeValue = badgeValue;
}

@end

