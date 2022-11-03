//
//  GKDDynamicCell.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2022/9/22.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import "GKDDynamicCell.h"

@implementation GKDDynamicCell

+ (CGSize)gkItemSize
{
    return CGSizeMake(UIScreen.gkWidth - 30, 100);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _textLabel = [UILabel new];
        [self.contentView addSubview:_textLabel];
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
        }];
        
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.layer.cornerRadius = 10;
    }
    
    return self;
}

@end
