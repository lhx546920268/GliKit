//
//  GKPhotosToolBar.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/11.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosToolBar.h"
#import "UIView+GKAutoLayout.h"
#import "GKBasic.h"

@implementation GKPhotosToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.whiteColor;
        
        _divider = [UIView new];
        _divider.backgroundColor = GKSeparatorColor;
        [self addSubview:_divider];
        
        [_divider gk_leftToSuperview];
        [_divider gk_rightToSuperview];
        [_divider gk_topToSuperview];
        [_divider gk_heightToSelf:GKSeparatorWidth];
        
        CGFloat bottom = 0;
        if(@available(iOS 11, *)){
            bottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        }
        
        _previewButton = [UIButton new];
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _previewButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        _previewButton.enabled = NO;
        [_previewButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_previewButton setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
        [_previewButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateHighlighted];
        [self addSubview:_previewButton];
        
        [_previewButton gk_leftToSuperview];
        [_previewButton gk_topToSuperview];
        [_previewButton gk_bottomToSuperview:bottom];
        
        _useButton = [UIButton new];
        [_useButton setTitle:@"使用" forState:UIControlStateNormal];
        _useButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _useButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        _useButton.enabled = NO;
        [_useButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_useButton setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
        [_useButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateHighlighted];
        [self addSubview:_useButton];
        
        [_useButton gk_rightToSuperview];
        [_useButton gk_topToSuperview];
        [_useButton gk_bottomToSuperview:bottom];
        
        _countLabel = [UILabel new];
        _countLabel.text = @"已选0张图片";
        _countLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_countLabel];
        
        [_countLabel gk_centerXInSuperview];
        [_countLabel gk_bottomToSuperview:bottom];
        [_countLabel gk_topToSuperview];
        
        [self gk_heightToSelf:45 + bottom];
    }
    return self;
}

- (void)setCount:(int)count
{
    if(_count != count){
        _count = count;
        _countLabel.text = [NSString stringWithFormat:@"已选%d张图片", _count];
        self.previewButton.enabled = _count > 0;
        self.useButton.enabled = _count > 0;
    }
}

@end
