//
//  GKPhotosOptions.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosOptions.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+GKUtils.h"
#import "UIImage+GKTheme.h"
#import "GKFileManager.h"

@implementation GKPhotosPickResult

+ (instancetype)resultWithImage:(UIImage*) image options:(GKPhotosOptions*) options
{
    if(!image)
        return nil;
    
    GKPhotosPickResult *result = [GKPhotosPickResult new];
    if(options.needOriginalImage){
        result.originalImage = image;
    }
    
    if(!CGSizeEqualToSize(CGSizeZero, options.compressedImageSize)){
        
        UIImage *compressedImage = [image gkAspectFitWithSize:options.compressedImageSize];
        result.compressedImage = compressedImage;
        result.filePath = [GKFileManager writeImage:compressedImage scale:0.9];
        result.compressedImageSize = CGSizeMake(compressedImage.size.width * compressedImage.scale, compressedImage.size.height * compressedImage.scale);
        image = compressedImage;
    } else {
        result.filePath = [GKFileManager writeImage:image scale:1.0];
    }
    
    if(!CGSizeEqualToSize(CGSizeZero, options.thumbnailSize)){
        CGSize size = options.thumbnailSize;
        CGFloat scale = options.scale;
        size.width *= scale;
        size.height *= scale;
        result.thumbnail = [image gkAspectFitWithSize:size];
    }
    
    return result;
}

+ (instancetype)resultWithData:(NSData*) data options:(GKPhotosOptions*) options
{
    CGImageSourceRef source = CGImageSourceCreateWithData(CFBridgingRetain(data), CFBridgingRetain(@{(NSString*) kCGImageSourceShouldAllowFloat : @YES}));
    if(!source)
        return nil;
    
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    if(!properties){
        CFRelease(source);
        return nil;
    }
    
    UIImage *image = nil;
    NSNumber *width = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
    NSNumber *height = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
    CGSize imageSize = CGSizeMake(width.doubleValue, height.doubleValue);
    
    CGFloat scale = options.scale;
    
    GKPhotosPickResult *result = [GKPhotosPickResult new];
    if(options.needOriginalImage){
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        if(imageRef != NULL){
            result.originalImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
            image = result.originalImage;
            CGImageRelease(imageRef);
        }
    }
    
    if(!CGSizeEqualToSize(CGSizeZero, options.compressedImageSize)){
        
        CGSize size = options.compressedImageSize;
        size.width *= scale;
        size.height *= scale;
        
        size = [UIImage gkFitImageSize:imageSize size:size];
        
        CGImageRef imageRef;
        if (size.width < imageSize.width || size.height < imageSize.height) {
            NSDictionary *compressedImageOptions = @{(id)kCGImageSourceThumbnailMaxPixelSize : @(MAX(size.width, size.height)),
                                        (id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                        (id)kCGImageSourceCreateThumbnailWithTransform : @YES};
            
            imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)compressedImageOptions);
        } else {
            imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        }

        if(imageRef != NULL){
            UIImage *compressedImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
            image = compressedImage;
            result.compressedImage = compressedImage;
            result.filePath = [GKFileManager writeImage:compressedImage originalData:data scale:0.9];
            result.compressedImageSize = CGSizeMake(compressedImage.size.width * compressedImage.scale, compressedImage.size.height * compressedImage.scale);
            CGImageRelease(imageRef);
        }
    } else {
        if (!image) {
            image = [UIImage imageWithData:data];
        }
        result.filePath = [GKFileManager writeImage:image  scale:1.0];
    }
    
    if(!CGSizeEqualToSize(CGSizeZero, options.thumbnailSize)){
        CGSize size = options.thumbnailSize;
        size.width *= scale;
        size.height *= scale;
        
        if (!image) {
            image = [UIImage imageWithData:data];
        }
    }
    
    CFRelease(source);
    CFRelease(properties);
    
    return result;
}

@end

@implementation GKPhotosOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxCount = 1;
        self.gridInterval = 3;
        self.numberOfItemsPerRow = 4;
        self.shouldDisplayAllPhotos = YES;
        self.displayFistCollection = YES;
        self.compressedImageSize = CGSizeMake(540, 0);
        self.scale = UIImage.gkImageScale;
    }
    return self;
}

- (void)setScale:(CGFloat)scale
{
    if(_scale != scale){
        if(scale < 1.0){
            scale = 1.0;
        }
        _scale = scale;
    }
}

@end
