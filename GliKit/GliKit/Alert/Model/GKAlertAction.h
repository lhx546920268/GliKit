//
//  GKAlertAction.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKButton.h"

NS_ASSUME_NONNULL_BEGIN

///弹窗按钮样式
@interface GKAlertAction : NSObject

///是否可以点击 default `YES`
@property(nonatomic, assign) BOOL enabled;

///字体 如果没有，则使用默认字体 default `nil`
@property(nonatomic, strong, nullable) UIFont *font;

///字体颜色 如果没有，则使用默认字体颜色 default `nil`
@property(nonatomic, strong, nullable) UIColor *textColor;

///按钮标题
@property(nonatomic, copy, nullable) NSString *title;

///图标
@property(nonatomic, strong, nullable) UIImage *icon;

///图片和标题的间隔 default `5.0`
@property(nonatomic, assign) CGFloat spacing;

///图标位置
@property(nonatomic, assign) GKButtonImagePosition imagePosition;


/// 初始化
/// @param title 按钮标题
+ (instancetype)alertActionWithTitle:(NSString*) title;

/// 初始化
/// @param title 按钮标题
/// @param icon 按钮图标
+ (instancetype)alertActionWithTitle:(nullable NSString*) title icon:(nullable UIImage*) icon;

@end

NS_ASSUME_NONNULL_END
