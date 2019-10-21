//
//  GKTabMenuBarCell.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKTabMenuBarCell.h"
#import "GKTabMenuBarItem.h"
#import "GKBaseDefines.h"
#import "UIButton+GKUtils.h"

@implementation GKTabMenuBarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _button.titleLabel.textAlignment = NSTextAlignmentCenter;
        _button.userInteractionEnabled = NO;
        _button.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_button];
        
        _separator = [UIView new];
        _separator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _separator.userInteractionEnabled = NO;
        [self.contentView addSubview:_separator];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
       
        [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self);
            make.centerY.equalTo(self);
            make.size.equalTo(CGSizeMake(0.5, 15));
        }];
    }
    return self;
}

- (void)setItem:(GKTabMenuBarItem *)item
{
    _item = item;
    [_button setTitle:_item.title forState:UIControlStateNormal];
    [_button setImage:_item.icon forState:UIControlStateNormal];
    [_button setImage:_item.selectedIcon forState:UIControlStateSelected];
    [_button setBackgroundImage:_item.backgroundImage forState:UIControlStateNormal];
    
    [_button gkSetImagePosition:_item.iconPosition margin:_item.iconPadding];
    
    UIEdgeInsets insets = _button.titleEdgeInsets;
    insets.left += _item.titleInsets.left;
    insets.right += _item.titleInsets.right;
    insets.bottom += _item.titleInsets.bottom;
    insets.top += _item.titleInsets.top;
    _button.titleEdgeInsets = insets;
    
    self.customView = _item.customView;
}

- (void)setTick:(BOOL) tick
{
    _tick = tick;
    _button.selected = _tick;
    _button.tintColor = [_button titleColorForState:_tick ? UIControlStateSelected : UIControlStateNormal];
}

- (void)setCustomView:(UIView *)customView
{
    if(_customView != customView){
        [_customView removeFromSuperview];
        _customView = customView;
        if(_customView){
            [self.contentView addSubview:_customView];
        }
    }
}

@end
