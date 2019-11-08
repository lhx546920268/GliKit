//
//  UIImage+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///图片等比例缩小方式
typedef NS_ENUM(NSInteger, GKImageFitType)
{
    ///宽和高
    GKImageFitTypeSize = 0,
    
    ///宽
    GKImageFitTypeWidth,
    
    ///高
    GKImageFitTypeHeight,
};

/**
 从资源文件中获取图片的选项
 */
typedef NS_ENUM(NSInteger, GKAssetImageOptions)
{
    ///适合当前屏幕大小的图片
    GKAssetImageOptionsFullScreenImage = 0,
    
    ///完整的图片
    GKAssetImageOptionsResolutionImage,
};

static const CGFloat GKImageScale = 2.0;

///图片扩展
@interface UIImage (GKUtils)

// MARK: - 创建图片

/**
 通过view生成图片
 */
+ (UIImage*)gkImageFromView:(UIView*)view;

/**
 通过layer生成图片
 */
+ (UIImage*)gkImageFromLayer:(CALayer*) layer;

/**
 通过给定颜色创建图片
 */
+ (UIImage*)gkImageWithColor:(UIColor*) color size:(CGSize) size;

// MARK: - resize

/**
 通过给定的大小，获取等比例缩小后的图片尺寸
 *@param size 要缩小的图片最大尺寸
 *@param type 缩小方式
 *@return 返回要缩小的图片尺寸
 */
- (CGSize)gkFitWithSize:(CGSize) size type:(GKImageFitType) type;

/**
 通过给定的大小，获取等比例缩小后的图片尺寸
 *@param imageSize 要缩小的图片大小
 *@param size 要缩小的图片最大尺寸
 *@param type 缩小方式
 *@return 返回要缩小的图片尺寸
 */
+ (CGSize)gkFitImageSize:(CGSize) imageSize size:(CGSize) size type:(GKImageFitType) type;

/**
 通过给定大小获取图片的等比例缩小的缩率图
 *@param size 目标图片大小
 *@return 图片的缩略图
 */
- (UIImage*)gkAspectFitWithSize:(CGSize) size;

/**
 居中截取的缩略图
 *@param size 目标图片大小
 *@return 图片的缩略图
 */
- (UIImage*)gkAspectFillWithSize:(CGSize) size;

/**
 截取图片
 *@param rect 要截取的rect
 *@return 截取的图片
 */
- (UIImage*)gkSubImageWithRect:(CGRect) rect;

/**
 修复图片方向错误，比如拍照的时候，有时图片方向不对
 */
+ (UIImage*)gkFixOrientation:(UIImage *)aImage;

@end

NS_ASSUME_NONNULL_END

