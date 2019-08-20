//
//  GKAlertHeader.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 弹窗头部
 */
@interface GKAlertHeader : UIScrollView

/**图标
 */
@property(nonatomic,readonly) UIImageView *imageView;

/**
 标题
 */
@property(nonatomic,readonly) UILabel *titleLabel;

/**
 信息
 */
@property(nonatomic,readonly) UILabel *messageLabel;

@end
