//
//  GKPhotosPreviewHeader.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosPreviewHeader.h"
#import "GKPhotosCheckBox.h"
#import "GKBaseDefines.h"
#import "UIApplication+GKTheme.h"

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
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(0, UIApplication.gkNavigationBarMargin, 0, UIApplication.gkNavigationBarMargin);
        [self addSubview:_backButton];
        
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.equalTo(0);
            make.top.equalTo(statusHeight);
        }];
        
        _checkBox = [GKPhotosCheckBox new];
        _checkBox.contentInsets = UIEdgeInsetsMake(10, UIApplication.gkNavigationBarMargin, 10, UIApplication.gkNavigationBarMargin);
        [self addSubview:_checkBox];

        [_checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(0);
            make.top.equalTo(statusHeight);
            make.width.equalTo(self.checkBox.height);
        }];
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
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(UIApplication.gkStatusBarHeight);
            make.centerX.bottom.equalTo(0);
        }];
    }
    
    return _titleLabel;
}

@end
