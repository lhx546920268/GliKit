//
//  UIView+GKLoading.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKPageLoadingContainer, GKToastProtocol;
@class GKToast;

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

///页面加载偏移量 default `zero`
@property(nonatomic, assign) UIEdgeInsets gkPageLoadingViewInsets;

///当前toast
@property(nonatomic, strong, nullable) UIView<GKToastProtocol> *gkToast;

///点击失败视图
- (void)gkHandlerTapFailPage;

///显示
- (void)gkShowLoadingToastWithText:(nullable NSString*) text;

///隐藏加载中
- (void)gkDismissLoadingToast;

///延迟显示
- (void)gkShowLoadingToastWithText:(nullable NSString*) text delay:(NSTimeInterval) delay;

///显示成功
- (void)gkShowSuccessWithText:(nullable NSString*) text;

///显示失败
- (void)gkShowErrorWithText:(nullable NSString*) text;

///显示警告
- (void)gkShowWarningWithText:(nullable NSString*) text;

///隐藏提示信息
- (void)gkDismissText;

@end

NS_ASSUME_NONNULL_END

