//
//  GKMenuBarCell.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKMenuBarCell.h"
#import "GKMenuBarItemInfo.h"

@implementation GKMenuBarCell

- (id)initWithFrame:(CGRect)frame
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

- (void)setInfo:(GKMenuBarItemInfo *)info
{
    _info = info;
    [_button setTitle:info.title forState:UIControlStateNormal];
    [_button setImage:info.icon forState:UIControlStateNormal];
    [_button setImage:info.selectedIcon forState:UIControlStateSelected];
    [_button setBackgroundImage:info.backgroundImage forState:UIControlStateNormal];
    
    [_button gk_setImagePosition:info.iconPosition margin:info.iconPadding];
    
    UIEdgeInsets insets = _button.titleEdgeInsets;
    insets.left += _info.titleInsets.left;
    insets.right += _info.titleInsets.right;
    insets.bottom += _info.titleInsets.bottom;
    insets.top += _info.titleInsets.top;
    _button.titleEdgeInsets = insets;
    
    self.customView = _info.customView;
}

- (void)setTick:(BOOL)item_selected
{
    _tick = item_selected;
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
