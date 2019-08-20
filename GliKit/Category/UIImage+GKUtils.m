//
//  UIImage+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIImage+GKUtils.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation UIImage (GKUtils)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (UIImage*)gk_imageFromAsset:(ALAsset *)asset
{
    return [UIImage gk_imageFromAsset:asset options:GKAssetImageOptionsResolutionImage];
}

+ (UIImage*)gk_imageFromAsset:(ALAsset*) asset options:(GKAssetImageOptions) options
{
    if(asset == nil)
        return nil;
    
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    
    UIImage *image = nil;
    
    switch (options){
        case GKAssetImageOptionsFullScreenImage : {
            //满屏的图片朝向已调整为 UIImageOrientationUp
            image = [UIImage imageWithCGImage:[representation fullScreenImage]];
        }
            break;
        case GKAssetImageOptionsResolutionImage : {
            //图片朝向可能不正确，需要调整
            //获取正确的图片方向
            UIImageOrientation orientation = UIImageOrientationUp;
            NSNumber *number = [asset valueForProperty:ALAssetPropertyOrientation];
            
            if(number != nil){
                orientation = [number intValue];
            }
            
            image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:representation.scale orientation:orientation];
        }
            break;
    }
    
    return image;
}

#pragma clang diagnostic pop

+ (UIImage*)gk_imageFromView:(UIView *)view
{
    return [UIImage gk_imageFromLayer:view.layer];
}

+ (UIImage*)gk_imageFromLayer:(GKLayer*) layer
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(floor(layer.bounds.size.width), floor(layer.bounds.size.height)), layer.opaque, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [layer renderInContext:context];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (UIImage*)gk_imageWithColor:(UIColor*) color size:(CGSize) size
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

#pragma mark resize

- (CGSize)gk_fitWithSize:(CGSize) size type:(GKImageFitType) type
{
    return [UIImage gk_fitImageSize:self.size size:size type:type];
}

+ (CGSize)gk_fitImageSize:(CGSize) imageSize size:(CGSize) size type:(GKImageFitType) type
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

- (UIImage*)gk_aspectFitWithSize:(CGSize)size
{
    CGImageRef cgImage = self.CGImage;
    size_t width = CGImageGetWidth(cgImage) / 2.0;
    size_t height = CGImageGetHeight(cgImage) / 2.0;
    
    size = [UIImage gk_fitImageSize:CGSizeMake(width, height) size:size type:GKImageFitTypeSize];
    
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

- (UIImage*)gk_aspectFillWithSize:(CGSize)size
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
        ret = [self gk_subImageWithRect:CGRectMake((self.size.width - width) / 2.0, (self.size.height - height) / 2.0, width, height)];
    }
    
    return [ret gk_aspectFitWithSize:size];
}

- (UIImage*)gk_subImageWithRect:(CGRect)rect
{
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(floorf(rect.size.width), floorf(rect.size.height)), NO, 2.0);
    
    [self drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage*)grayscaleImageForImage:(UIImage*)image
{
    // Adapted from this thread: http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
    const int RED =1;
    const int GREEN =2;
    const int BLUE =3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0,0, image.size.width* image.scale, image.size.height* image.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t*) malloc(width * height *sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels,0, width * height *sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,8, width *sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context,CGRectMake(0,0, width, height), [image CGImage]);
    
    for(int  y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t*) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] +0.59 * rgbaPixel[GREEN] +0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(imageRef);
    
    return resultUIImage;
}

@end
