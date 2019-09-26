//
//  UIViewController+GKEmptyView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKEmptyView;

///空视图相关扩展
@interface UIViewController (GKEmptyView)

///空视图
@property(nonatomic, readonly, nullable) GKEmptyView *gkEmptyView;

///设置显示空视图
@property(nonatomic, assign) BOOL gkShowEmptyView;

@end

NS_ASSUME_NONNULL_END

