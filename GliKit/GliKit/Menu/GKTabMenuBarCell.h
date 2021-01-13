//
//  GKTabMenuBarCell.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKTabMenuBarItem, GKButton, GKDivider;

///菜单按钮
@interface GKTabMenuBarCell : UICollectionViewCell

///按钮
@property(nonatomic, readonly) GKButton *button;

///分隔符
@property(nonatomic, readonly) GKDivider *divider;

///是否选中
@property(nonatomic, assign) BOOL tick;

///按钮信息
@property(nonatomic, strong) GKTabMenuBarItem *item;

///自定义视图
@property(nonatomic, strong, nullable) UIView *customView;

@end

NS_ASSUME_NONNULL_END

