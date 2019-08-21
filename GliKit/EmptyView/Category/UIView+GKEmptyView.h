//
//  UIView+GKEmptyView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKEmptyView.h"

///空视图扩展
@interface UIView (GKEmptyView)

///空视图 不要直接设置这个 使用 cashowEmptyView
@property(nonatomic, strong) GKEmptyView *gkEmptyView;

///设置显示空视图
@property(nonatomic, assign) BOOL gkShowEmptyView;

///空视图代理
@property(nonatomic, weak) id<GKEmptyViewDelegate> gkEmptyViewDelegate;

///旧的视图大小，防止 layoutSubviews 时重复计算
@property(nonatomic, assign) CGSize gkOldSize;

///调整emptyView
- (void)layoutEmtpyView;

@end


