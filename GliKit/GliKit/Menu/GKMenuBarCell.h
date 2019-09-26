//
//  GKMenuBarCell.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKMenuBarItem;

/**
 菜单按钮
 */
@interface GKMenuBarCell : UICollectionViewCell

/**
 按钮
 */
@property(nonatomic, readonly) UIButton *button;

/**
 分隔符
 */
@property(nonatomic, readonly) UIView *separator;

/**
 是否选中
 */
@property(nonatomic, assign) BOOL tick;

/**
 按钮信息
 */
@property(nonatomic, strong) GKMenuBarItem *item;

/**
 自定义视图
 */
@property(nonatomic, strong, nullable) UIView *customView;

@end

NS_ASSUME_NONNULL_END

