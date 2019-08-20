//
//  UIView+GKLoading.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKPageLoadingContainer, GKProgressHUD;

///loading相关扩展
@interface UIView (GKLoading)

///页面第一次加载显示
@property(nonatomic, assign) BOOL gkShowPageLoading;

///页面第一次加载视图
@property(nonatomic, strong) GKPageLoadingContainer *gkPageLoadingView;

///显示加载失败页面
@property(nonatomic, assign) BOOL gkShowFailPage;

///点击失败页面回调
@property(nonatomic, copy) void(^gkReloadDataHandler)(void);

///当前hud
@property(nonatomic, strong) GKProgressHUD *gkProgressHUD;

///点击失败视图
- (void)handlerTapFailPage:(UITapGestureRecognizer*) tap;

///显示hud
- (void)gkShowProgressWithText:(NSString*) text;

///隐藏加载中hud
- (void)gkDismissProgress;

///延迟显示hud
- (void)gkShowProgressWithText:(NSString*) text delay:(NSTimeInterval) delay;

///显示成功hud
- (void)gkShowSuccessWithText:(NSString*) text;

///显示失败hud
- (void)gkShowErrorWithText:(NSString*) text;

///显示警告hud
- (void)gkShowWarningWithText:(NSString*) text;

///隐藏提示信息hud
- (void)gkDismissText;

@end

