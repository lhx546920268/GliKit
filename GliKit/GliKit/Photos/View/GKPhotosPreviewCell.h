//
//  GKPhotosPreviewCell.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset, GKPhotosPreviewCell;

///代理
@protocol GKPhotosPreviewCellDelegate <NSObject>

///单击
- (void)photosPreviewCellDidClick:(GKPhotosPreviewCell*) cell;

@end

///相册预览
@interface GKPhotosPreviewCell : UICollectionViewCell

///加载中
@property(nonatomic, assign) BOOL loading;

///asset标识符
@property(nonatomic, strong, nullable) PHAsset *asset;

///代理
@property(nonatomic, weak, nullable) id<GKPhotosPreviewCellDelegate> delegate;

///图片加载完成时
- (void)onLoadImage:(nullable UIImage*) image;

@end

NS_ASSUME_NONNULL_END

