//
//  GKBaseWebViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 基础Web 视图控制器
 */
@interface GKBaseWebViewController : GKBaseViewController<WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>

/**
 网页视图，ios8.0新出的api，更高效地显示网页
 */
@property(nonatomic, readonly) WKWebView *webView;

// MARK: - Web Config

/**
 是否关闭系统的长按手势 default is 'NO'
 */
@property(nonatomic, assign) BOOL shouldCloseSystemLongPressGesture;

/**
 是否使用 web里面的标题，使用会self.title 替换成web的标题，default is 'YES'
 */
@property(nonatomic, assign) BOOL useWebTitle;

/**
 载入htmlString 是否根据屏幕适配 default is 'NO'
 */
@property(nonatomic, assign) BOOL adjustScreenWhenLoadHtmlString;

/**
 是否需要显示进度条 default is 'YES'
 */
@property(nonatomic, assign) BOOL shouldDisplayProgress;

/**
 返回需要注入的js
 */
@property(nonatomic, readonly, nullable) NSString *javascript;

/**
 返回需要设置的自定义 userAgent 会拼在系统的userAgent后面 default is nil
 */
@property(nonatomic, readonly, nullable) NSString *customUserAgent;

// MARK: - 内容

/**
 当前链接
 */
@property(nonatomic, readonly, nullable) NSURL *currentURL;

/**
 第一个链接
 */
@property(nonatomic, readonly, nullable) NSString *originalURL;

/**
 将要打开的链接
 */
@property(nonatomic, copy, nullable) NSURL *URL;

/**
 将要打开的html
 */
@property(nonatomic, copy, nullable) NSString *htmlString;

// MARK: - Init

/**
 构造方法
 *@param URLString 将要打开的链接
 *@return 一个实例
 */
- (instancetype)initWithURLString:(nullable NSString*) URLString;

/**
 构造方法
 *@param URL 将要打开的链接
 *@return 一个实例
 */
- (instancetype)initWithURL:(nullable NSURL*) URL;

/**
 构造方法
 *@param htmlString 将要打开的html
 *@return 一个实例
 */
- (instancetype)initWithHtmlString:(nullable NSString*) htmlString;

/**
 将要创建webView
 */
- (void)willInitWebView;

/**
 初始化
 */
- (void)initViews NS_REQUIRES_SUPER;

// MARK: - Web Control

/**
 是否可以倒退
 */
@property(nonatomic, readonly) BOOL canGoBack;

/**
 是否可以前进
 */
@property(nonatomic, readonly) BOOL canGoForward;

/**
 后退
 */
- (void)goBack;

/**
 前进
 */
- (void)goForward;

/**
 刷新
 */
- (void)reload;

/**
 加载网页
 */
- (void)loadWebContent;

// MARK: - 回调

/**
 是否应该打开某个链接 default is 'YES'
 */
- (BOOL)shouldOpenURL:(NSURL*) URL action:(WKNavigationAction*) action;

/**
 进度条改变
 */
- (void)onProgressChange:(float) progress;



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint*)targetContentOffset NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
