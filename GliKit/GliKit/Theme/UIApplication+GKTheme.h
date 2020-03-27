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

///导航栏titleView 和 item的间距
@property (class, nonatomic, assign) CGFloat gkNavigationBarTitleViewItemMargin;

///状态栏样式
@property (class, nonatomic, assign) UIStatusBarStyle gkStatusBarStyle;

///状态栏高度
@property (class, nonatomic, readonly) CGFloat gkStatusBarHeight;

///钥匙串群组
@property(class, nonatomic) NSString *gkKeychainAcessGroup;

@end

