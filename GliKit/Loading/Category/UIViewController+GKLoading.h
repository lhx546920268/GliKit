//
//  UIViewController+GKLoading.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKPageLoadingContainer;

///loading相关类目
@interface UIViewController (GKLoading)

///页面第一次加载显示
@property(nonatomic, assign) BOOL gk_showPageLoading;

///页面第一次加载视图
@property(nonatomic, strong) GKPageLoadingContainer *gk_pageLoadingView;

///显示加载失败页面
@property(nonatomic, assign) BOOL gk_showFailPage;

///显示hud
- (void)gk_showProgressWithText:(NSString*) text;

///隐藏hud
- (void)gk_dismissProgress;

///隐藏提示信息hud
- (void)gk_dismissText;

///延迟显示hud
- (void)gk_showProgressWithText:(NSString*) text delay:(NSTimeInterval) delay;

///显示成功hud
- (void)gk_showSuccessWithText:(NSString*) text;

///显示失败hud
- (void)gk_showErrorWithText:(NSString*) text;

///显示警告的hud
- (void)gk_showWarningWithText:(NSString*) text;

///重新加载数据 默认不做任何事，子类可以重写该方法
- (void)gk_reloadData;

@end

