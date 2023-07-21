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
#import "GKButton.h"
#import "GKDivider.h"

@implementation GKTabMenuBarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _button = [GKButton new];
        _button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _button.titleLabel.textAlignment = NSTextAlignmentCenter;
        _button.userInteractionEnabled = NO;
        _button.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_button];
        
        _divider = [GKDivider verticalDivider];
        _divider.userInteractionEnabled = NO;
        [self.contentView addSubview:_divider];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
       
        [_divider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(15);
        }];
    }
    return self;
}

- (void)setItem:(GKTabMenuBarItem *)item
{
    _item = item;
    [_button setTitle:_item.title forState:UIControlStateNormal];
    [_button setImage:_item.image forState:UIControlStateNormal];
    [_button setImage:_item.selectedImage forState:UIControlStateSelected];
    [_button setBackgroundImage:_item.backgroundImage forState:UIControlStateNormal];
    _button.imagePadding = _item.iconPadding;
    _button.imagePosition = _item.imagePosition;
    
    _button.titleEdgeInsets = _item.titleInsets;
    
    self.customView = _item.customView;
}

- (void)setTick:(BOOL) tick
{
    _tick = tick;
    _button.tintColor = [_button titleColorForState:UIControlStateNormal];
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
