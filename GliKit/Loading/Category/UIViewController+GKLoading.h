//
//  UIViewController+GKLoading.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GKPageLoadingContainer;

///loading相关类目
@interface UIViewController (GKLoading)

///页面第一次加载显示
@property(nonatomic, assign) BOOL gkShowPageLoading;

///页面第一次加载视图
@property(nonatomic, strong) UIView<GKPageLoadingContainer> *gkPageLoadingView;

///显示加载失败页面
@property(nonatomic, assign) BOOL gkShowFailPage;

///显示hud
- (void)gkShowProgressWithText:(NSString*) text;

///隐藏hud
- (void)gkDismissProgress;

///隐藏提示信息hud
- (void)gkDismissText;

///延迟显示hud
- (void)gkShowProgressWithText:(NSString*) text delay:(NSTimeInterval) delay;

///显示成功hud
- (void)gkShowSuccessWithText:(NSString*) text;

///显示失败hud
- (void)gkShowErrorWithText:(NSString*) text;

///显示警告的hud
- (void)gkShowWarningWithText:(NSString*) text;

///重新加载数据 默认不做任何事，子类可以重写该方法
- (void)gkReloadData;

@end

