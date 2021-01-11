//
//  GKLabel.h
//  GliKit
//
//  Created by 罗海雄 on 2020/1/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///自定义label
@interface GKLabel : UILabel

///文本边距 default `zero`
@property(nonatomic, assign) IBInspectable UIEdgeInsets contentInsets;

///是否可以长按选中
@property(nonatomic, assign) BOOL selectable;

///选中时背景颜色 默认主题颜色 0.5透明度
@property(nonatomic, strong, null_resettable) UIColor *selectedBackgroundColor;

///显示的菜单按钮，默认是复制
@property(nonatomic, strong, null_resettable) NSArray<UIMenuItem*> *menuItems;

///要显示的按钮，默认只显示复制
@property(nonatomic, copy, nullable) BOOL(^canPerformActionHandler)(SEL action, id sender);

///是否识别链接，default `NO`
@property(nonatomic, assign) BOOL shouldDetectURL;

///URL和其他设置可点击的 样式 默认蓝色字体加下划线
@property(nonatomic, strong, null_resettable) NSDictionary *clickableAttributes;

///点击识别的字符串回调
@property(nonatomic, copy, nullable) void(^clickStringHandler)(NSString *string);

/// 添加可点击的位置，重新设置text会忽略以前添加的
/// @param range 可点击的位置，如果该范围不在text中，则忽略
- (void)addClickableRange:(NSRange) range;

@end

NS_ASSUME_NONNULL_END
