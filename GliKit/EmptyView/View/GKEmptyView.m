//
//  GKEmptyView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKEmptyView.h"
#import "UIView+GKAutoLayout.h"

@interface GKEmptyView ()

///内容
@property(nonatomic,readonly) UIView *contentView;

@end

@implementation GKEmptyView

@synthesize textLabel = _textLabel;
@synthesize iconImageView = _iconImageView;
@synthesize contentView = _contentView;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initlization];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initlization];
    }
    
    return self;
}

///初始化默认数据
- (void)initlization
{
    self.backgroundColor = [UIColor clearColor];
}

- (UIView*)contentView
{
    if(!_contentView){
        self.clipsToBounds = YES;
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_contentView];
        
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(@(10));
            make.trailing.equalTo(self).offset(@(-10));
            make.centerY.equalTo(self);
        }];
    }
    return _contentView;
}

- (UILabel*)textLabel
{
    if(!_textLabel){
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor gk_colorFromHex:@"aeaeae"];
        _textLabel.font = [UIFont appFontWithSize:14];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        [self.contentView addSubview:_textLabel];
        
        
        BOOL exist = _iconImageView != nil;
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if(exist){
                [self.contentView removeConstraint:self.iconImageView.gk_bottomLayoutConstraint];
                make.top.equalTo(self.iconImageView.mas_bottom).offset(@(10));
            }else{
                make.top.equalTo(self.contentView);
            }
            make.leading.trailing.bottom.equalTo(self.contentView);
        }];
    }
    
    return _textLabel;
}

- (UIImageView*)iconImageView
{
    if(!_iconImageView){
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_iconImageView];
        
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.leading.greaterThanOrEqualTo(self.contentView);
            make.trailing.lessThanOrEqualTo(self.contentView);
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
        }];
        
        if(_textLabel){
            [self.contentView removeConstraint:_textLabel.gkTopLayoutConstraint];
            [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.iconImageView.mas_bottom).offset(@(10));
            }];
        }else{
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView);
            }];
        }
    }
    
    return _iconImageView;
}

- (void)setCustomView:(UIView *)customView
{
    if(_customView != customView){
        [_customView removeFromSuperview];
        _customView = customView;
        
        if(_customView){
            [_contentView removeFromSuperview];
            [self addSubview:_customView];
            [_customView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
}

@end
