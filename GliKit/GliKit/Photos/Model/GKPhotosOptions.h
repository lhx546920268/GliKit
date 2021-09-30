//
//  GKPhotosOptions.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKImageCropSettings.h"

NS_ASSUME_NONNULL_BEGIN

@class GKPhotosOptions;

///打开相册的意图
typedef NS_ENUM(NSInteger, GKPhotosIntention){
    
    ///单选
    GKPhotosIntentionSingleSelection,
    
    ///多选
    GKPhotosIntentionMultiSelection,
    
    ///裁剪 必须设置裁剪选项 cropSettings
    GKPhotosIntentionCrop,
};

///相册选择结果
@interface GKPhotosPickResult : NSObject

///图片缩略图
@property(nonatomic, strong, nullable) UIImage *thumbnail;

///压缩后的图片
@property(nonatomic, strong, nullable) UIImage *compressedImage;

///压缩后的图片路径
@property(nonatomic, copy) NSString *filePath;

///原图
@property(nonatomic, strong, nullable) UIImage *originalImage;

///压缩后的图片大小
@property(nonatomic, assign) CGSize compressedImageSize;

///通过相册选项 图片数据创建 创建失败返回nil
+ (nullable instancetype)resultWithData:(nullable NSData*) data options:(GKPhotosOptions*) options;
+ (nullable instancetype)resultWithImage:(nullable UIImage*) image options:(GKPhotosOptions*) options;

@end


///相册选项
@interface GKPhotosOptions : NSObject

///选择图片完成回调
@property(nonatomic, copy, nullable) void(^completion)(NSArray<GKPhotosPickResult*> *results);

///意图
@property(nonatomic, assign) GKPhotosIntention intention;

///裁剪选项
@property(nonatomic, strong, nullable) GKImageCropSettings *cropSettings;

///缩略图大小 default `zero` 只缩放宽度
@property(nonatomic, assign) CGSize thumbnailSize;

///压缩图片的大小 default `540` 只缩放宽度
@property(nonatomic, assign) CGSize compressedImageSize;

///是否需要原图 default `NO`
@property(nonatomic, assign) BOOL needOriginalImage;

///多选数量 default `1`
@property(nonatomic, assign) NSInteger maxCount;

///网格图片间距 default `3.0`
@property(nonatomic, assign) CGFloat gridInterval;

///每行图片数量 default `4`
@property(nonatomic, assign) NSInteger numberOfItemsPerRow;

///是否显示所有图片 default `YES`
@property(nonatomic, assign) BOOL shouldDisplayAllPhotos;

///是否显示空的相册 default `NO`
@property(nonatomic, assign) BOOL shouldDisplayEmptyCollection;

///是否直接显示第一个相册的内容 default `YES`
@property(nonatomic, assign) BOOL displayFistCollection;

///图片scale default `GKImageScale`
@property(nonatomic, assign) CGFloat scale;

@end

NS_ASSUME_NONNULL_END

