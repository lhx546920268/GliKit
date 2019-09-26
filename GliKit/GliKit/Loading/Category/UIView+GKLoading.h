//
//  UIView+GKLoading.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKPageLoadingContainer, GKProgressHUD;
@class GKProgressHUD;

///loading相关扩展
@interface UIView (GKLoading)

///页面第一次加载显示
@property(nonatomic, assign) BOOL gkShowPageLoading;

///页面第一次加载视图
@property(nonatomic, strong, nullable) UIView<GKPageLoadingContainer> *gkPageLoadingView;

///显示加载失败页面
@property(nonatomic, assign) BOOL gkShowFailPage;

///点击失败页面回调
@property(nonatomic, copy, nullable) void(^gkReloadDataHandler)(void);

///页面加载偏移量 default is UIEdgeInsetZero
@property(nonatomic, assign) UIEdgeInsets gkPageLoadingViewInsets;

///当前hud
@property(nonatomic, strong, nullable) UIView<GKProgressHUD> *gkProgressHUD;

///点击失败视图
- (void)gkHandlerTapFailPage;

///显示hud
- (void)gkShowProgressWithText:(nullable NSString*) text;

///隐藏加载中hud
- (void)gkDismissProgress;

///延迟显示hud
- (void)gkShowProgressWithText:(nullable NSString*) text delay:(NSTimeInterval) delay;

///显示成功hud
- (void)gkShowSuccessWithText:(nullable NSString*) text;

///显示失败hud
- (void)gkShowErrorWithText:(nullable NSString*) text;

///显示警告hud
- (void)gkShowWarningWithText:(nullable NSString*) text;

///隐藏提示信息hud
- (void)gkDismissText;

@end

NS_ASSUME_NONNULL_END

