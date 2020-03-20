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

///二维码容错率
typedef NS_ENUM(NSInteger, GKQRCodeImageCorrectionLevel)
{
    /// 7% 容错率 L
    GKQRCodeImageCorrectionLevelPercent7 = 0,
    
    /// 15% 容错率 M
    GKQRCodeImageCorrectionLevelPercent15,
    
    /// 25% 容错率 Q
    GKQRCodeImageCorrectionLevelPercent25,
    
    /// 30% 容错率 H
    GKQRCodeImageCorrectionLevelPercent30,
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

// MARK: - 二维码

/**
 通过给定信息生成二维码
 
 *@param string 二维码信息 不能为空
 *@param correctionLevel 二维码容错率
 *@param size 二维码大小 如果为CGSizeZero ，将使用 240的大小
 *@param contentColor 二维码内容颜色，如果空，将使用 blackColor
 *@param backgroundColor 二维码背景颜色，如果空，将使用 whiteColor
 *@param logo 二维码 logo ,放在中心位置 ，logo的大小 根据 UIImage.size 来确定
 *@param logoSize logo 大小 0则表示是用图片大小
 *@return 成功返回二维码图片，否则nil
 */
+ (UIImage*)gkQRCodeImageWithString:(NSString*) string
                  correctionLevel:(GKQRCodeImageCorrectionLevel) correctionLevel
                             size:(CGSize) size
                     contentColor:(UIColor*) contentColor
                  backgroundColor:(UIColor*) backgroundColor
                             logo:(UIImage*) logo
                            logoSize:(CGSize) logoSize;

@end

NS_ASSUME_NONNULL_END

