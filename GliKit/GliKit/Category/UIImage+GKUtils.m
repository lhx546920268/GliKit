//
//  UIImage+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIImage+GKUtils.h"
#import "UIColor+GKUtils.h"
#import "UIImage+GKTheme.h"

@implementation UIImage (GKUtils)

+ (UIImage*)gkImageFromView:(UIView *)view
{
    return [UIImage gkImageFromLayer:view.layer];
}

+ (UIImage*)gkImageFromLayer:(CALayer*) layer
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(floor(layer.bounds.size.width), floor(layer.bounds.size.height)), layer.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [layer renderInContext:context];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (UIImage*)gkImageWithColor:(UIColor*) color size:(CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextDrawPath(context, kCGPathFill);
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

// MARK: - resize

- (CGSize)gkFitWithSize:(CGSize) size type:(GKImageFitType) type
{
    return [UIImage gkFitImageSize:self.size size:size type:type];
}

+ (CGSize)gkFitImageSize:(CGSize) imageSize size:(CGSize) size type:(GKImageFitType) type
{
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    if(width == height){
        width = MIN(width, size.width > size.height ? size.height : size.width);
        height = width;
    }else{
        CGFloat heightScale = height / size.height;
        CGFloat widthScale = width / size.width;
        
        switch (type) {
            case GKImageFitTypeSize : {
                if(height >= size.height && width >= size.width){
                    if(heightScale > widthScale){
                        height = floorf(height / heightScale);
                        width = floorf(width / heightScale);
                    }else{
                        height = floorf(height / widthScale);
                        width = floorf(width / widthScale);
                    }
                } else {
                    if(height >= size.height && width <= size.width) {
                        height = floorf(height / heightScale);
                        width = floorf(width / heightScale);
                    } else if(height <= size.height && width >= size.width){
                        height = floorf(height / widthScale);
                        width = floorf(width / widthScale);
                    }
                }
            }
                break;
            case GKImageFitTypeWidth : {
                if(width > size.width) {
                    height = floorf(height / widthScale);
                    width = floorf(width / widthScale);
                }
            }
                break;
            case GKImageFitTypeHeight : {
                if(height > size.height) {
                    height = floorf(height / heightScale);
                    width = floorf(width / heightScale);
                }
            }
                break;
            default:
                break;
        }
    }
    
    return CGSizeMake(width, height);
}

- (UIImage*)gkAspectFitWithSize:(CGSize)size
{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    size = [UIImage gkFitImageSize:CGSizeMake(width, height) size:size type:GKImageFitTypeSize];
    
    if(size.height >= height || size.width >= width)
        return self;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, UIImage.gkImageScale);
    [self drawInRect:CGRectMake(0.0, 0.0, floorf(size.width), floorf(size.height))];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    thumbnail = [UIImage imageWithCGImage:thumbnail.CGImage scale:thumbnail.scale orientation:thumbnail.imageOrientation];
    
    return thumbnail;
}

- (UIImage*)gkAspectFillWithSize:(CGSize)size
{
    UIImage *ret = nil;
    
    if(self.size.width == self.size.height && size.width == size.height) {
        //正方形图片
        ret = self;
    } else {
        CGFloat multipleWidthNum = self.size.width / size.width;
        CGFloat multipleHeightNum = self.size.height / size.height;
        
        CGFloat scale = MIN(multipleWidthNum, multipleHeightNum);
        int width = size.width * scale;
        int height = size.height * scale;
        ret = [self gkSubImageWithRect:CGRectMake((self.size.width - width) / 2.0, (self.size.height - height) / 2.0, width, height)];
    }
    
    return [ret gkAspectFitWithSize:size];
}

- (UIImage*)gkSubImageWithRect:(CGRect)rect
{
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(floorf(rect.size.width), floorf(rect.size.height)), NO, UIImage.gkImageScale);
    
    [self drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage*)gkFixOrientation:(UIImage *)aImage
{
    if (aImage.imageOrientation == UIImageOrientationUp)
      return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform =CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
      case UIImageOrientationDown:
      case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;
      case UIImageOrientationLeft:
      case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;
      case UIImageOrientationRight:
      case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
      default:
        break;
    }
    switch (aImage.imageOrientation) {
      case UIImageOrientationUpMirrored:
      case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
      case UIImageOrientationLeftMirrored:
      case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.height,0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
      default:
        break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGImageRef cgImage = aImage.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height,
                         CGImageGetBitsPerComponent(cgImage), 0,
                         CGImageGetColorSpace(cgImage),
                         CGImageGetBitmapInfo(cgImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
      case UIImageOrientationLeft:
      case UIImageOrientationLeftMirrored:
      case UIImageOrientationRight:
      case UIImageOrientationRightMirrored:
        // Grr...
        CGContextDrawImage(ctx, CGRectMake(0, 0, height, width), cgImage);
        break;
      default:
        CGContextDrawImage(ctx, CGRectMake(0 ,0, width, height), cgImage);
        break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:aImage.scale orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

// MARK: - 二维码

+ (UIImage*)gkQRCodeImageWithString:(NSString*) string
                  correctionLevel:(GKQRCodeImageCorrectionLevel) correctionLevel
                             size:(CGSize) size
                     contentColor:(UIColor*) contentColor
                  backgroundColor:(UIColor*) backgroundColor
                             logo:(UIImage*) logo
                            logoSize:(CGSize)logoSize
{
    
    if(string == nil)
        return nil;
    
    ///设置默认属性
    if(contentColor == nil)
        contentColor = [UIColor blackColor];
    if(backgroundColor == nil)
        backgroundColor = [UIColor whiteColor];
    
    if(CGSizeEqualToSize(size, CGSizeZero)){
        size = CGSizeMake(240.0, 240.0);
    }
    
    NSString *level = nil;
    switch (correctionLevel){
        case GKQRCodeImageCorrectionLevelPercent7 :
            level = @"L";
            break;
        case GKQRCodeImageCorrectionLevelPercent15 :
            level = @"M";
            break;
        case GKQRCodeImageCorrectionLevelPercent25 :
            level = @"Q";
            break;
        case GKQRCodeImageCorrectionLevelPercent30 :
            level = @"H";
            break;
    }
    
    ///通过coreImage生成默认的二维码图片
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    [filter setValue:level forKey:@"inputCorrectionLevel"];
    
    CIImage *ciImage = filter.outputImage;
    
    ///把它生成给定大小的图片
    CGRect rect = CGRectIntegral(ciImage.extent);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:rect];
    
    if(imageRef == NULL)
        return nil;
    
    ///创建位图
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    ///获取实际生成的图片宽高
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    ///计算需要的二维码图片宽高比例
    CGFloat w_scale = size.width / (CGFloat)width;
    CGFloat h_scale = size.height / (CGFloat)height;
    
    width *= w_scale;
    height *= h_scale;
    
    size_t bytesPerRow = width * 4; ///每行字节数
    uint32_t *data = malloc(bytesPerRow * height); ///创建像素存储空间
    CGContextRef cx = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    
    if(cx == NULL){
        CGImageRelease(imageRef);
        free(data);
        return nil;
    }
    
    CGContextSetInterpolationQuality(cx, kCGInterpolationNone); ///设置二维码质量，否则二维码图片会变模糊，可无损放大
    CGContextScaleCTM(cx, w_scale, h_scale); ///调整坐标系比例
    CGContextDrawImage(cx, rect, imageRef);
    
    CGImageRelease(imageRef);
    
    ///也可以使用 CIFalseColor 类型的滤镜来改变二维码背景颜色和二维码颜色
    
    ///如果二维码颜色不是黑色 并且背景不是白色 ，改变它的颜色
    if(![contentColor isEqualToColor:[UIColor blackColor]]
       || ![backgroundColor isEqualToColor:[UIColor whiteColor]]){
        ///获取颜色的rgba值
        NSDictionary *dic = [contentColor gkColorARGB];
        int c_red = [[dic objectForKey:GKColorRed] floatValue] * 255;
        int c_green = [[dic objectForKey:GKColorGreen] floatValue] * 255;
        int c_blue = [[dic objectForKey:GKColorBlue] floatValue] * 255;
        int c_alpha = [[dic objectForKey:GKColorAlpha] floatValue] * 255;
        
        dic = [backgroundColor gkColorARGB];
        int b_red = [[dic objectForKey:GKColorRed] floatValue] * 255;
        int b_green = [[dic objectForKey:GKColorGreen] floatValue] * 255;
        int b_blue = [[dic objectForKey:GKColorBlue] floatValue] * 255;
        int b_alpha = [[dic objectForKey:GKColorAlpha] floatValue] * 255;
        
        
        ///遍历图片的像素并改变值，像素是一个二维数组， 每个像素由RGBA的数组组成，在数组中的排列顺序是从右到左即 array[0] 是 A阿尔法通道
        uint32_t *tmpData = data; ///创建临时的数组指针，保持data的指针指向为起始位置
        for(size_t i = 0;i < height; i ++){
            for(size_t j = 0;j < width; j ++){
                uint8_t *ptr = (uint8_t*)tmpData;
                if(ptr[3] < 255){ ///判断是否是背景像素，白色是背景
                    ///改变二维码颜色
                    ptr[3] = c_red;
                    ptr[2] = c_green;
                    ptr[1] = c_blue;
                    ptr[0] = c_alpha;
                }else{
                    ///改变背景颜色
                    ptr[3] = b_red;
                    ptr[2] = b_green;
                    ptr[1] = b_blue;
                    ptr[0] = b_alpha;
                }
                
                tmpData ++; ///指针指向下一个像素
            }
        }
    }
    
    ///绘制logo 圆角有锯齿，暂无解决方案
    //    if(logo)
    //    {
    //        ///因为前面 画板已缩放过了，这里的坐标系要调整比例
    //        CGImageRef logoRef = logo.CGImage;
    //        width = logo.size.width / w_scale;
    //        height = logo.size.height / h_scale;
    //        rect = CGRectMake((size.width / w_scale - width) / 2.0, (size.height / h_scale - height) / 2.0, width, height);
    //        CGContextDrawImage(cx, rect, logoRef);
    //    }
    
    ///从画板中获取二维码图片
    CGImageRef qrImageRef = CGBitmapContextCreateImage(cx);
    CGContextRelease(cx);
    free(data);
    
    if(qrImageRef == NULL)
        return nil;
    
    UIImage *image = [UIImage imageWithCGImage:qrImageRef];
    CGImageRelease(qrImageRef);
    
    ///绘制logo 没有锯齿
    if(logo){
        if(logoSize.width == 0 || logoSize.height == 0){
            logoSize = logo.size;
        }
        
        size = CGSizeMake(floorf(image.size.width), floorf(image.size.height));
        
        UIGraphicsBeginImageContextWithOptions(size, NO, UIImage.gkImageScale);
        
        [image drawAtPoint:CGPointZero];
        [logo drawInRect:CGRectMake((size.width - logoSize.width) / 2.0, (size.height - logoSize.height) / 2.0, logoSize.width, logoSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

@end
