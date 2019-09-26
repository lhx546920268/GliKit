//
//  GKPhotosGridCell.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/2.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPhotosCheckBox, GKPhotosGridCell, PHAsset;

///代理
@protocol GKPhotosGridCellDelegate <NSObject>

///选中某个图片
- (void)photosGridCellCheckedDidChange:(GKPhotosGridCell*) cell;

@end

///相册网格
@interface GKPhotosGridCell : UICollectionViewCell

///图片
@property(nonatomic, readonly) UIImageView *imageView;

///选中覆盖
@property(nonatomic, readonly) UIView *overlay;

///选中勾
@property(nonatomic, readonly) GKPhotosCheckBox *checkBox;

///选中
@property(nonatomic, assign) BOOL checked;

///asset标识符
@property(nonatomic, strong, nullable) PHAsset *asset;

///代理
@property(nonatomic, weak, nullable) id<GKPhotosGridCellDelegate> delegate;

///设置选中
- (void)setChecked:(BOOL)checked animated:(BOOL) animated;

@end

NS_ASSUME_NONNULL_END

