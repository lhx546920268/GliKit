//
//  GKDTableViewSkeletonHeader.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDTableViewSkeletonHeader.h"

@implementation GKDTableViewSkeletonHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if(self){
        
        self.contentView.backgroundColor = UIColor.whiteColor;
        _titleLabel = [UILabel new];
        _titleLabel.text = @"这是一个标题";
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@15);
            make.centerY.equalTo(@0);
        }];
    }
    
    return self;
}

@end
