//
//  CAImagePicker.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhotosOptions.h"

///选择图片完成回调
typedef void(^GKImagePickerCompletionHandler)(NSArray<GKPhotosPickResult*> *results);;

///图片选择
@interface GKImagePicker : NSObject

///相机是否可以使用 不能使用时会弹出对应错误
+ (BOOL)canUseCamera;

///图片选项
@property(nonatomic, readonly) GKPhotosOptions *options;

///关联的controller
- (instancetype)initWithController:(UIViewController*) viewController;

///选择图片
- (void)pickImageWithCompletionHanler:(GKImagePickerCompletionHandler) handler;

@end

