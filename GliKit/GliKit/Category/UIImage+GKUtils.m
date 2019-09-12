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

//MARK: resize

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

@end
