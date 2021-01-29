//
//  UITableView+GKRowHeight.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKRowHeightModel;

///缓存行高的
@interface UITableView (GKRowHeight)

/// 获取cell高度
/// @param identifier cell唯一标识
/// @param model 保存行高的
- (CGFloat)gkRowHeightForIdentifier:(NSString*) identifier model:(id<GKRowHeightModel>) model;

/// 获取cell高度 主要用于静态cell，不重用的cell
/// @param cell 要计算高度的cell
/// @param model 保存行高的
- (CGFloat)gkRowHeightForCell:(UITableViewCell*) cell model:(id<GKRowHeightModel>) model;

/// 获取header footer 高度
/// @param identifier header唯一标识
/// @param model 保存行高的
- (CGFloat)gkHeaderFooterHeightForIdentifier:(NSString*) identifier model:(id<GKRowHeightModel>) model;

/// 获取header footer 高度 主要用于静态 header footer，不重用的
/// @param headerFooter 要计算高度的header footer
/// @param model 保存行高的
- (CGFloat)gkHeightForHeaderFooter:(UIView*) headerFooter model:(id<GKRowHeightModel>) model;

@end

NS_ASSUME_NONNULL_END
