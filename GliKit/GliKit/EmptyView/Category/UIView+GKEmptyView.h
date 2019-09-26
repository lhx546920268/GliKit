//
//  UIView+GKEmptyView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKEmptyView.h"

NS_ASSUME_NONNULL_BEGIN

///空视图扩展
@interface UIView (GKEmptyView)

///空视图 不要直接设置这个 使用 gkShowEmptyView
@property(nonatomic, strong, nullable) GKEmptyView *gkEmptyView;

///设置显示空视图
@property(nonatomic, assign) BOOL gkShowEmptyView;

///空视图代理
@property(nonatomic, weak, nullable) id<GKEmptyViewDelegate> gkEmptyViewDelegate;

///旧的视图大小，防止 layoutSubviews 时重复计算
@property(nonatomic, assign) CGSize gkOldSize;

///调整emptyView
- (void)layoutEmtpyView;

@end

NS_ASSUME_NONNULL_END

