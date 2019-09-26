//
//  GKDefaultLoadMoreControl.h
//  GliKit
//
//  Created by luohaixiong on 2018/7/20.
//  Copyright © 2018年 罗海雄. All rights reserved.
//

#import "GKLoadMoreControl.h"

NS_ASSUME_NONNULL_BEGIN

/**
 默认的加载更多控件
 */
@interface GKDefaultLoadMoreControl : GKLoadMoreControl

/**
 是否要显示菊花 默认显示
 */
@property(nonatomic, assign) BOOL showIndicatorView;

/**
 加载菊花
 */
@property(nonatomic, readonly) UIActivityIndicatorView *indicatorView;

/**
 加载显示的提示信息
 */
@property(nonatomic, readonly) UILabel *textLabel;

@end

NS_ASSUME_NONNULL_END
