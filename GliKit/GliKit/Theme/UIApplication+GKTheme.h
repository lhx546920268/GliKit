//
//  UIApplication+GKTheme.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

///主题
@interface UIApplication (GKTheme)

///分割线高度
@property (class, nonatomic, assign) CGFloat gkSeparatorHeight;

///导航栏间距
@property (class, nonatomic, assign) CGFloat gkNavigationBarMargin;

///导航栏中的标题和按钮间距
@property(class, nonatomic, readonly) CGFloat gkNavigationBarMarginForItem;

///导航栏高度
@property(class, nonatomic, assign) CGFloat gkNavigationBarHeight;

///状态栏样式
@property(class, nonatomic, assign) UIStatusBarStyle gkStatusBarStyle;

///兼容的dark 样式
@property(class, nonatomic, readonly) UIStatusBarStyle gkDarkStatusBarStyle;

///状态栏高度
@property(class, nonatomic, readonly) CGFloat gkStatusBarHeight;

///钥匙串群组
@property(class, nonatomic) NSString *gkKeychainAcessGroup;

@end

