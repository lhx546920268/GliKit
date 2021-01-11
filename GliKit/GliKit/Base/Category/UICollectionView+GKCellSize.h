//
//  UICollectionView+GKCellSize.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///保存item大小的
@protocol GKItemSizeModel <NSObject>

///item大小
@property(nonatomic, assign) CGSize itemSize;

@end

///可配置的item
@protocol GKCollectionConfigurableItem <NSObject>

///对应的数据
@property(nonatomic, strong) id<GKItemSizeModel> model;

@end

///cell大小
@interface UICollectionView (GKCellSize)

/// 获取cell大小
/// @param identifier cell唯一标识
/// @param model 保存cell大小的
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier model:(id<GKItemSizeModel>) model;

/// 获取cell大小
/// @param identifier cell唯一标识
/// @param constraintSize 最大，只能设置 宽度或高度
/// @param model 保存cell大小的
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier constraintSize:(CGSize) constraintSize model:(id<GKItemSizeModel>) model;

/// 获取cell大小
/// @param identifier cell唯一标识
/// @param width cell宽度
/// @param model 保存cell大小的
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier width:(CGFloat) width model:(id<GKItemSizeModel>) model;

/// 获取cell大小
/// @param identifier cell唯一标识
/// @param height cell高度
/// @param model 保存cell大小的
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier height:(CGFloat) height model:(id<GKItemSizeModel>) model;

@end

NS_ASSUME_NONNULL_END

