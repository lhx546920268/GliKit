//
//  GKPhotosListCell.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/2.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosListCell.h"
#import "UIView+GKAutoLayout.h"
#import "GKBasic.h"
#import "UIColor+Utils.h"

@implementation GKPhotosListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbnailImageView];
        
        [_thumbnailImageView gk_leftToSuperview:15];
        [_thumbnailImageView gk_topToSuperview:10];
        [_thumbnailImageView gk_bottomToSuperview:10];
        [_thumbnailImageView gk_aspectRatio:1.0];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel gk_leftToItemRight:_thumbnailImageView margin:15];
        [_titleLabel gk_centerYInSuperview];
        
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textColor = UIColor.darkGrayColor;
        [_countLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh - 1 forAxis:UILayoutConstraintAxisHorizontal];
        [_countLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_countLabel];
        
        [_countLabel gk_leftToItemRight:_titleLabel margin:5];
        [_countLabel gk_centerYInSuperview];
        [_countLabel gk_rightToSuperview:15];
        
        UIView *divider = [UIView new];
        divider.backgroundColor = GKSeparatorColor;
        [self.contentView addSubview:divider];
        
        [divider gk_rightToSuperview];
        [divider gk_leftToItem:_titleLabel];
        [divider gk_bottomToSuperview];
        [divider gk_heightToSelf:GKSeparatorWidth];
        
    }
    return self;
}

@end
