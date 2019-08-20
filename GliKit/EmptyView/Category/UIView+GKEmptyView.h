//
//  UIView+CAEmptyView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKEmptyView.h"

///空视图扩展
@interface UIView (CAEmptyView)

///空视图 不要直接设置这个 使用 cashowEmptyView
@property(nonatomic, strong) GKEmptyView *ca_emptyView;

///设置显示空视图
@property(nonatomic, assign) BOOL ca_showEmptyView;

///空视图代理
@property(nonatomic, weak) id<GKEmptyViewDelegate> ca_emptyViewDelegate;

///旧的视图大小，防止 layoutSubviews 时重复计算
@property(nonatomic, assign) CGSize ca_oldSize;

///调整emptyView
- (void)layoutEmtpyView;

@end


