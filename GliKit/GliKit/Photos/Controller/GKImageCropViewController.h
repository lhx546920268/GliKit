//
//  GKImageCropViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class GKPhotosOptions;

/**
 图片裁剪
 */
@interface GKImageCropViewController : GKBaseViewController

/**
 裁剪框的位置 大小
 */
@property (nonatomic, readonly) CGRect cropFrame;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 构造方法
 *@param options 裁剪设置
 *@return 一个实例
 */
- (instancetype)initWithOptions:(GKPhotosOptions*) options NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
