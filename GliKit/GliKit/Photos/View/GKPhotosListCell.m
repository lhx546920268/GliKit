//
//  GKPhotosListCell.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/2.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosListCell.h"
#import "GKBaseDefines.h"
#import "GKDivider.h"

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
        
        [_thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@15);
            make.top.equalTo(@10);
            make.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(self.thumbnailImageView.mas_height);
        }];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.thumbnailImageView.mas_trailing).offset(15);
            make.centerY.equalTo(@0);
        }];
        
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textColor = UIColor.darkGrayColor;
        [_countLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh - 1 forAxis:UILayoutConstraintAxisHorizontal];
        [_countLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_countLabel];
        
        [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.titleLabel.mas_trailing).offset(5);
            make.centerY.equalTo(@0);
            make.trailing.mas_equalTo(-15);
        }];
        
        
        GKDivider *divider = [GKDivider new];
        [self.contentView addSubview:divider];
        
        [divider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.titleLabel);
            make.trailing.bottom.equalTo(@0);
        }];
    }
    return self;
}

@end
