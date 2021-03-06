//
//  UIColor+GKTheme.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/21.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (GKTheme)

///app主色调
@property(class, nonatomic, strong) UIColor *gkThemeColor;

///主色调对应的 tintColor
@property(class, nonatomic, strong) UIColor *gkThemeTintColor;

///主要导航栏背景颜色
@property(class, nonatomic, strong) UIColor *gkNavigationBarBackgroundColor;

///导航栏标题颜色
@property(class, nonatomic, strong) UIColor *gkNavigationBarTitleColor;

///导航栏按钮颜色
@property(class, nonatomic, strong) UIColor *gkNavigationBarTintColor;

///分割线颜色
@property(class, nonatomic, strong) UIColor *gkSeparatorColor;

///app背景颜色 灰色那个
@property(class, nonatomic, strong) UIColor *gkGrayBackgroundColor;

///骨架层背景颜色
@property(class, nonatomic, strong) UIColor *gkSkeletonBackgroundColor;

///高亮灰色背景
@property(class, nonatomic, strong) UIColor *gkHighlightedBackgroundColor;

///输入框placeholder 颜色
@property(class, nonatomic, strong) UIColor *gkPlaceholderColor;

@end

NS_ASSUME_NONNULL_END


