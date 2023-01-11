//
//  GKPhotosBrowseViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2020/5/14.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKCollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

///图片浏览信息
@interface GKPhotosBrowseModel : NSObject

///图片
@property(nonatomic, strong, nullable) UIImage *image;

///图片路径
@property(nonatomic, copy, nullable) NSURL *URL;

///缩略图链接
@property(nonatomic, copy, nullable) NSURL *thumbnailURL;

///通过图片初始化
+ (instancetype)modelWithImage:(nullable UIImage*) image;

///通过图片路径初始化
+ (instancetype)modelWithURL:(nullable NSString*) URL;

///通过图片路径初始化
+ (instancetype)modelWithURL:(nullable NSString*) URL thumnbailURL:(nullable NSString*) thumbnailURL;

@end

@class GKPhotosBrowseViewController;

///图片浏览代理
@protocol GKPhotosBrowseViewControllerDelegate <NSObject>

@optional

///将进入全屏
- (void)photosBrowseViewControllerWillEnterFullScreen:(GKPhotosBrowseViewController*) viewController;

///已经进入全屏
- (void)photosBrowseViewControllerDidEnterFullScreen:(GKPhotosBrowseViewController*) viewController;

///将退出全屏
- (void)photosBrowseViewControllerWillExitFullScreen:(GKPhotosBrowseViewController*) viewController;

///已经退出全屏
- (void)photosBrowseViewControllerDidExitFullScreen:(GKPhotosBrowseViewController*) viewController;

@end

///图片放大浏览
@interface GKPhotosBrowseViewController : GKCollectionViewController

///动画时间长度 default is '0.25'
@property(nonatomic, assign) CGFloat animateDuration;

///图片间隔 default 15
@property(nonatomic, assign) CGFloat imageSpacing;

///是否满屏显示 default YES
@property(nonatomic, assign) BOOL displayInFullScreen;

///图片信息
@property(nonatomic, readonly) NSArray<GKPhotosBrowseModel*> *models;

///当前显示的图片下标
@property(nonatomic, readonly) NSUInteger visibleIndex;

///获取动画的视图，如果需要显示和隐藏动画， index 图片下标，将使用到view.frame 和 view.contentMode
@property(nonatomic, copy, nullable) UIView *(^animatedViewHandler)(NSUInteger index);

///代理
@property(nonatomic, weak, nullable) id<GKPhotosBrowseViewControllerDelegate> delegate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 通过图片初始化

 @param images 图片数组
 @param visibleIndex 当前可见位置
 @return 一个实例
 */
- (instancetype)initWithImages:(NSArray<UIImage*>*) images visibleIndex:(NSInteger) visibleIndex NS_DESIGNATED_INITIALIZER;

/**
 通过图片路径初始化
 
 @param URLs 图片路径数组
 @param visibleIndex 当前可见位置
 @return 一个实例
 */
- (instancetype)initWithURLs:(NSArray<NSString*>*) URLs visibleIndex:(NSInteger) visibleIndex NS_DESIGNATED_INITIALIZER;

/**
 通过图片数据初始化
 
 @param models 图片数据
 @param visibleIndex 当前可见位置
 @return 一个实例
 */
- (instancetype)initWithModels:(NSArray<GKPhotosBrowseModel*>*) models visibleIndex:(NSInteger) visibleIndex NS_DESIGNATED_INITIALIZER;

///显示
- (void)showAnimated:(BOOL) animated;

///消失
- (void)dismissAimated:(BOOL) animated;

///重新加载数据
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
