//
//  UIView+GKNavigationBarUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 该类目主要是适配 ios 11及以上 导航栏左右按钮间距无法设置的问题
 在iOS 13中 修改 _UINavigationBarContentView（系统导航栏的内容视图，导航栏按钮和标题的父视图）的layoutMargins，directionalLayoutMargins会闪退、
 */
@interface UIView (GKNavigationBarUtils)

@end
