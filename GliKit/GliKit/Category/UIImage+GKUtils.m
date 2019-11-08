//
//  UIImage+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIImage+GKUtils.h"

@implementation UIImage (GKUtils)

+ (UIImage*)gkImageFromView:(UIView *)view
{
    return [UIImage gkImageFromLayer:view.layer];
}

+ (UIImage*)gkImageFromLayer:(CALayer*) layer
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(floor(layer.bounds.size.width), floor(layer.bounds.size.height)), layer.opaque, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [layer renderInContext:context];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (UIImage*)gkImageWithColor:(UIColor*) color size:(CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
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
    CGSize retSize = CGSizeZero;
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
    
    retSize = CGSizeMake(width, height);
    return retSize;
}

- (UIImage*)gkAspectFitWithSize:(CGSize)size
{
    CGImageRef cgImage = self.CGImage;
    size_t width = CGImageGetWidth(cgImage) / 2.0;
    size_t height = CGImageGetHeight(cgImage) / 2.0;
    
    size = [UIImage gkFitImageSize:CGSizeMake(width, height) size:size type:GKImageFitTypeSize];
    
    if(size.height >= height || size.width >= width)
        return self;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, floorf(size.width), floorf(size.height));
    [self drawInRect:imageRect];
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
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(floorf(rect.size.width), floorf(rect.size.height)), NO, 2.0);
    
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
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                         CGImageGetBitsPerComponent(aImage.CGImage), 0,
                         CGImageGetColorSpace(aImage.CGImage),
                         CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
      case UIImageOrientationLeft:
      case UIImageOrientationLeftMirrored:
      case UIImageOrientationRight:
      case UIImageOrientationRightMirrored:
        // Grr...
        CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
        break;
      default:
        CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
        break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg =CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}


@end
