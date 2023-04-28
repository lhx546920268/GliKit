//
//  GKTabBarButton.m
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import "GKTabBarButton.h"
#import "GKBadgeValueView.h"
#import "GKBaseDefines.h"

@interface GKTabBarButton ()

@property(nonatomic, strong) UIView *contentView;

@end

@implementation GKTabBarButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.clipsToBounds = NO;
        UIView *contentView = [UIView new];
        contentView.userInteractionEnabled = NO;
        [self addSubview:contentView];
        
        _imageView = [UIImageView new];
        [contentView addSubview:_imageView];
        
        _textLabel = [UILabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        [contentView addSubview:_textLabel];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {;
            make.leading.trailing.centerY.equalTo(0);
        }];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.equalTo(0);
        }];
        
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(0);
            make.bottom.centerX.equalTo(0);
        }];
        
        self.contentView = contentView;
    }
    return self;
}

// MARK: - property

- (void)setBadgeValue:(NSString *)badgeValue
{
    if(_badgeValue != badgeValue){
        _badgeValue = badgeValue;
        
        [self initBadge];
        
        if([_badgeValue isEqualToString:@""]){
            _badge.point = YES;
        }else{
            _badge.point = NO;
            _badge.value = _badgeValue;
        }
    }
}

///创建角标
- (void)initBadge
{
    if(!_badge){
        
        _badge = [GKBadgeValueView new];
        _badge.font = [UIFont systemFontOfSize:13];
        [self addSubview:_badge];
        
        [_badge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.imageView.mas_trailing);
            make.top.equalTo(5);
        }];
    }
}

@end
