//
//  GKTabBar.m
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import "GKTabBar.h"
#import "GKTabBarButton.h"
#import "GKBaseDefines.h"
#import "UIColor+GKTheme.h"
#import "UIColor+GKUtils.h"
#import "UIView+GKUtils.h"
#import "UIApplication+GKTheme.h"

@implementation GKTabBar

- (instancetype)initWithButtons:(NSArray<GKTabBarButton *> *)buttons
{
    self = [super init];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.buttons = buttons;
        _selectedIndex = NSNotFound;
        
        _separator = [UIView new];
        _separator.backgroundColor = UIColor.gkSeparatorColor;
        _separator.userInteractionEnabled = NO;
        [self addSubview:_separator];
        
        [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.equalTo(@0);
            make.height.mas_equalTo(UIApplication.gkSeparatorHeight);
        }];
    }
    
    return self;
}

- (void)setButtons:(NSArray<GKTabBarButton *> *)buttons
{
    if(_buttons != buttons){
        _buttons = buttons;
        
        //移除以前的按钮
        NSArray *subviews = self.subviews;
        for(UIView *view in subviews){
            if(view != self.separator){
                [view removeFromSuperview];
            }
        }
        
        GKTabBarButton *beforeBtn = nil;
        CGFloat bottom = UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.bottom;
        for(NSUInteger i = 0;i < _buttons.count;i ++){
            GKTabBarButton *btn = _buttons[i];
            [btn addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
            [self insertSubview:btn belowSubview:self.separator];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.bottom.mas_equalTo(-bottom);
                if(beforeBtn){
                    make.leading.equalTo(beforeBtn.mas_trailing);
                    make.width.equalTo(beforeBtn);
                }else{
                    make.leading.equalTo(@0);
                }
                if(i == _buttons.count - 1){
                    make.trailing.equalTo(@0);
                }
            }];

            beforeBtn = btn;
        }
    }
}

// MARK: - private method

//选中某个按钮
- (void)handleTap:(GKTabBarButton*) btn
{
    if(btn.selected)
        return;
    
    NSInteger index = [self.buttons indexOfObject:btn];
    BOOL enabled = YES;
    if([self.delegate respondsToSelector:@selector(tabBar:clickEnabledAtIndex:)]){
        enabled = [self.delegate tabBar:self clickEnabledAtIndex:index];
    }
    if(enabled){
        self.selectedIndex = index;
    }
}

// MARK: - property

//设置选中的
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if(_selectedIndex != selectedIndex){
        
        if(_selectedIndex < _buttons.count){
            GKTabBarButton *btn = _buttons[_selectedIndex];
            btn.backgroundColor = [UIColor clearColor];
            btn.selected = NO;
        }
        
        _selectedIndex = selectedIndex;
        GKTabBarButton *btn = _buttons[_selectedIndex];
        btn.selected = YES;
        if(self.selectedButtonBackgroundColor){
            btn.backgroundColor = self.selectedButtonBackgroundColor;
        }
        
        if([self.delegate respondsToSelector:@selector(tabBar:didClickAtIndex:)]){
            [self.delegate tabBar:self didClickAtIndex:_selectedIndex];
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
                make.edges.equalTo(@0);
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
        GKTabBarButton *btn = _buttons[_selectedIndex];
        btn.backgroundColor = _selectedButtonBackgroundColor;
    }
}

/**设置选项卡边缘值
 *@param badgeValue 边缘值
 *@param index 下标
 */
- (void)setBadgeValue:(NSString*) badgeValue forIndex:(NSInteger) index;
{
#if CADebug
    NSAssert(index < _buttons.count, @"CATabBar setBadgeValue forIndex, index %d 越界", (int)index);
#endif
    GKTabBarButton *btn = _buttons[index];
    btn.badgeValue = badgeValue;
}

@end

