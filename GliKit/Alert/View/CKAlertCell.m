//
//  CKAlertCell.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "CKAlertCell.h"
#import <Masonry.h>

@implementation CKAlertCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.adjustsImageWhenHighlighted = NO;
        _button.adjustsImageWhenDisabled = NO;
        _button.enabled = NO;
        [self.contentView addSubview:_button];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];

    }
    
    return self;
}

@end
