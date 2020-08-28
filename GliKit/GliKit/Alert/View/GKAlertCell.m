//
//  GKAlertCell.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKAlertCell.h"
#import <Masonry/Masonry.h>
#import "GKButton.h"

@implementation GKAlertCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){

        self.selectedBackgroundView = [UIView new];
        _button = [GKButton new];
        _button.adjustsImageWhenHighlighted = NO;
        _button.adjustsImageWhenDisabled = NO;
        _button.userInteractionEnabled = NO;
        [self.contentView addSubview:_button];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    
    return self;
}

@end
