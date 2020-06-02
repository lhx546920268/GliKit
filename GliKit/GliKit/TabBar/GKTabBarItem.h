//
//  GKTabBarItem.h
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKBadgeValueView;

/**
 选项卡按钮
 */
@interface GKTabBarItem : UIControl

/**
 标题
 */
@property(nonatomic, readonly) UILabel *textLabel;

/**
 边缘数值
 */
@property(nonatomic, copy, nullable) NSString *badgeValue;

/**
 边缘视图
 */
@property(nonatomic, readonly, nullable) GKBadgeValueView *badge;

/**
 图片
 */
@property(nonatomic, readonly) UIImageView *imageView;

/**
 创建角标
 */
- (void)initBadge;

@end

NS_ASSUME_NONNULL_END
