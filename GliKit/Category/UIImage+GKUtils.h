//
//  UIImage+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@class ALAsset;

///图片扩展
@interface UIImage (GKUtils)

#pragma mark 创建图片

/**
 从图片资源中获取图片数据
 *@return [UIImage imageFromAsset:asset options:GKAssetImageOptionsResolutionImage];
 */
+ (UIImage*)gk_imageFromAsset:(ALAsset *)asset;

/**
 从图片资源中获取图片数据
 *@param asset 资源文件类
 *@param options 从资源文件中获取图片的选项
 */
+ (UIImage*)gk_imageFromAsset:(ALAsset*) asset options:(GKAssetImageOptions) options;

#pragma clang diagnostic pop

/**
 通过view生成图片
 */
+ (UIImage*)gk_imageFromView:(UIView*)view;

/**
 通过layer生成图片
 */
+ (UIImage*)gk_imageFromLayer:(GKLayer*) layer;

/**
 通过给定颜色创建图片
 */
+ (UIImage*)gk_imageWithColor:(UIColor*) color size:(CGSize) size;

#pragma mark resize

/**
 通过给定的大小，获取等比例缩小后的图片尺寸
 *@param size 要缩小的图片最大尺寸
 *@param type 缩小方式
 *@return 返回要缩小的图片尺寸
 */
- (CGSize)gk_fitWithSize:(CGSize) size type:(GKImageFitType) type;

/**
 通过给定的大小，获取等比例缩小后的图片尺寸
 *@param imageSize 要缩小的图片大小
 *@param size 要缩小的图片最大尺寸
 *@param type 缩小方式
 *@return 返回要缩小的图片尺寸
 */
+ (CGSize)gk_fitImageSize:(CGSize) imageSize size:(CGSize) size type:(GKImageFitType) type;

/**
 通过给定大小获取图片的等比例缩小的缩率图
 *@param size 目标图片大小
 *@return 图片的缩略图
 */
- (UIImage*)gk_aspectFitWithSize:(CGSize) size;

/**
 居中截取的缩略图
 *@param size 目标图片大小
 *@return 图片的缩略图
 */
- (UIImage*)gk_aspectFillWithSize:(CGSize) size;

/**
 截取图片
 *@param rect 要截取的rect
 *@return 截取的图片
 */
- (UIImage*)gk_subImageWithRect:(CGRect) rect;

/**
 图片变灰
 */
+ (UIImage*)grayscaleImageForImage:(UIImage*)image;

@end

