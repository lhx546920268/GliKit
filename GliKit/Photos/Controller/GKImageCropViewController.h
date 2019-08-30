//
//  GKImageCropViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKBaseViewController.h"

@class GKPhotosOptions;

/**
 图片裁剪
 */
@interface GKImageCropViewController : GKBaseViewController

/**
 裁剪框的位置 大小
 */
@property (nonatomic, readonly) CGRect cropFrame;

/**
 构造方法
 *@param settings 裁剪设置
 *@return 一个实例
 */
- (id)initWithOptions:(GKPhotosOptions*) options;

/**
 获取裁剪的图片
 */
- (UIImage*)cropImage;

@end
