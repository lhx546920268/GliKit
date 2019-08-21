//
//  GKPhotosPreviewHeader.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosPreviewHeader.h"
#import "GKPhotosCheckBox.h"
#import "UIView+GKAutoLayout.h"
#import "GKBasic.h"

@implementation GKPhotosPreviewHeader

@synthesize titleLabel = _titleLabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat statusHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        _backButton.tintColor = UIColor.whiteColor;
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(0, GKNavigationBarMargin, 0, GKNavigationBarMargin);
        [self addSubview:_backButton];
        
        [_backButton gk_leftToSuperview];
        [_backButton gk_topToSuperview:statusHeight];
        [_backButton gk_bottomToSuperview];
        
        _checkBox = [GKPhotosCheckBox new];
        _checkBox.contentInsets = UIEdgeInsetsMake(10, GKNavigationBarMargin, 10, GKNavigationBarMargin);
        [self addSubview:_checkBox];

        
        [_checkBox gk_aspectRatio:1.0];
        [_checkBox gk_rightToSuperview];
        [_checkBox gk_topToSuperview:statusHeight];
        [_checkBox gk_bottomToSuperview];
    }
    
    return self;
}

- (UILabel*)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        [_titleLabel gk_centerXInSuperview];
        [_titleLabel gk_topToSuperview:UIApplication.sharedApplication.statusBarFrame.size.height];
        [_titleLabel gk_bottomToSuperview];
    }
    
    return _titleLabel;
}

@end
