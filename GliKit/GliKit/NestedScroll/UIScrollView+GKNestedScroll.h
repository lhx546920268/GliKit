//
//  UIScrollView+GKNestedScroll.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKNestedScrollHelper;

///嵌套滚动扩展
@interface UIScrollView (GKNestedScroll)

///是否可以嵌套滑动 需要手动设置 child和parent都要设置这个
@property(nonatomic, assign) BOOL gkNestedScrollEnable;

///是否是嵌套滑动容器 需要手动设置
@property(nonatomic, assign) BOOL gkNestedParent;

///滑动到父容器了 在父容器设置
@property(nonatomic, copy) void(^gkChildDidScrollToParent)(void);

///当前嵌套滑动容器，如果没设置，会自动寻找
@property(nonatomic, weak) UIScrollView *gkNestedParentScrollView;

///当前嵌套滑动的子视图 需要手动设置，有多个时要动态设置 可通过 self.scrollView.gkNestedParentScrollView.gkNestedChildScrollView = self.scrollView 来设置
@property(nonatomic, weak) UIScrollView *gkNestedChildScrollView;

///内部用，嵌套滑动帮助类 只有嵌套滑动容器才有这个
@property(nonatomic, readonly) GKNestedScrollHelper *gkNestedScrollHelper;

@end

