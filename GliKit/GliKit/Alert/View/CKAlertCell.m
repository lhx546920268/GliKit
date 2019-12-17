//
//  CKAlertCell.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "CKAlertCell.h"
#import <Masonry.h>
#import "GKButton.h"

@implementation CKAlertCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){

        _button = [GKButton new];
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
