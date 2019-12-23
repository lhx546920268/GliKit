//
//  GKDCollectionViewSkeletonCell.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDCollectionViewSkeletonCell.h"

@implementation GKDCollectionViewSkeletonCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat size = (UIScreen.gkScreenWidth - 10 * 4) / 3;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test_1"]];
        [self.contentView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(size - 10, size - 10));
            make.centerX.equalTo(0);
            make.top.equalTo(5);
        }];
        
        UILabel *label = [UILabel new];
        label.text = @"标题";
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(5);
            make.leading.equalTo(5);
            make.trailing.equalTo(-5);
        }];
        
        self.contentView.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

@end
