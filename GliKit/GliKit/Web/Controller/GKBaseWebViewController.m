//
//  GKBaseWebViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseWebViewController.h"
#import "GKProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+GKWeb.h"
#import "GKPageViewController.h"
#import "UIViewController+GKSafeAreaCompatible.h"
#import "GKNavigationBar.h"
#import "NSString+GKUtils.h"
#import "GKBaseDefines.h"
#import "UIViewController+GKLoading.h"

///当前系统默认的 userAgent
static NSString *GKSystemUserAgent = nil;

///使用单例 防止 存储信息不一致
static WKProcessPool *sharedProcessPool;

@interface GKBaseWebViewController ()

///加载进度条
@property(nonatomic, strong) GKStraightLineProgressView *progressView;

///获取userAgent的 webView，因为 在iOS 12中，在调用 navigatior.userAgent 后，设置customUserAgent会不生效
@property(nonatomic, strong) WKWebView *userAgentWebView;

@end

@implementation GKBaseWebViewController

// MARK: - dealloc

- (void)dealloc
{
    _webView.scrollView.delegate = nil;
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

// MARK: - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        [self initViews];
    }
    
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString
{
    return [self initWithURL:[NSURL URLWithString:URLString]];
}

- (instancetype)initWithURL:(NSURL*) URL
{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
       
        URL = [self fixURLIfNeeded:URL];
        _URL = URL;
        _originalURL = [URL copy];
        [self initViews];
    }
    return self;
}

- (instancetype)initWithHtmlString:(NSString*) htmlString
{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.htmlString = htmlString;
        [self initViews];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self willInitWebView];
    [self initWebView];
    [self loadWebContent];
}

- (void)willInitWebView
{
    
}

//初始化
- (void)initViews
{
    self.useWebTitle = YES;
    _shouldDisplayProgress = YES;
}

///初始化webView
- (void)initWebView
{
    //加载进度条条
    UIView *contentView = [UIView new];
    self.contentView = contentView;
    
    GKStraightLineProgressView *progressView = [GKStraightLineProgressView new];
    progressView.progressColor = [UIColor colorWithRed:0 green:0.4784314 blue:1.0 alpha:1.0];
    progressView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:progressView];
    self.progressView = progressView;
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[self webViewConfiguration]];
    if(@available(iOS 9.0, *)){
        _webView.allowsLinkPreview = NO;
    }
    
    _webView.navigationDelegate = self;
    //_webView.opaque = NO; //背景透明，开了可能会有性能问题
    _webView.UIDelegate = self;
    _webView.scrollView.delegate = self;
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [contentView insertSubview:_webView belowSubview:progressView];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.height.equalTo(2.5);
        make.top.equalTo(self.gkSafeAreaLayoutGuideTop);
    }];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
}

- (void)setURL:(NSURL *)URL
{
    if(_URL != URL){
        _URL = [self fixURLIfNeeded:URL];
    }
}

///如果需要 修正URL
- (NSURL*)fixURLIfNeeded:(NSURL*) URL
{
    if(URL){
        NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:false];
        if([NSString isEmpty:components.scheme]) {
            components.scheme = @"http";
        }
        
        NSString *host = components.host;
        if(![NSString isEmpty:host] && [host componentsSeparatedByString:@"."].count < 3){
            components.host = [NSString stringWithFormat:@"www.%@", host];
        }
        
        URL = components.URL;
    }
    return URL;
}

// MARK: - Web Config

///网页配置
- (WKWebViewConfiguration*)webViewConfiguration
{
    WKUserContentController *userContentController = [WKUserContentController new];
    
    NSString *js = [self javascript];
    if(self.shouldCloseSystemLongPressGesture || ![NSString isEmpty:js]){
        
        NSMutableString *javaScript = [NSMutableString new];
        if(self.shouldCloseSystemLongPressGesture){
            //禁止长按弹出 UIMenuController 相关
            //禁止选择 css 配置相关
            NSString *css = @"('body{-webkit-user-select:none;-webkit-user-drag:none;}')";
            //css 选中样式取消
            
            [javaScript appendString:@"var style = document.createElement('style');"];
            [javaScript appendString:@"style.type = 'text/css';"];
            [javaScript appendFormat:@"var cssContent = document.createTextNode%@;", css];
            [javaScript appendString:@"style.appendChild(cssContent);"];
            [javaScript appendString:@"document.body.appendChild(style);"];
            [javaScript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
            [javaScript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        }
        
        if(![NSString isEmpty:js]){
            [javaScript appendString:js];
        }
        
        WKUserScript *script = [[WKUserScript alloc] initWithSource:javaScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [userContentController addUserScript:script];
    }
    
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContentController;
    if(!sharedProcessPool){
        sharedProcessPool = [WKProcessPool new];
    }
    configuration.processPool = sharedProcessPool;
    
    return configuration;
}

- (NSString*)javascript
{
    return nil;
}

- (NSString*)customUserAgent
{
    return nil;
}

///获取userAgent
- (void)loadUserAgentWithCompletion:(void(^)(void)) completion
{
    if(!self.userAgentWebView){
        self.userAgentWebView = [WKWebView new];
        WeakObj(self)
        [self.userAgentWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if([NSString isEmpty:result]){
                result = @"";
            }
            GKSystemUserAgent = result;
            selfWeak.userAgentWebView = nil;
            !completion ?: completion();
        }];
    }
}

// MARK: - 内容

- (void)setHtmlString:(NSString *)htmlString
{
    if(![_htmlString isEqualToString:htmlString]){
        if(_adjustScreenWhenLoadHtmlString && ![NSString isEmpty:htmlString]){
            _htmlString = [[NSString stringWithFormat:@"%@%@", [NSString gkAdjustScreenHtmlString], htmlString] copy];
        }else{
            _htmlString = [htmlString copy];
        }
    }
}

- (void)setShouldDisplayProgress:(BOOL)shouldDisplayProgress
{
    if(_shouldDisplayProgress != shouldDisplayProgress){
        _shouldDisplayProgress = shouldDisplayProgress;
        self.progressView.hidden = !_shouldDisplayProgress || self.progressView.progress == 0;
    }
}

// MARK: - Web Control

- (BOOL)canGoBack
{
    return [_webView canGoBack];;
}

- (BOOL)canGoForward
{
    return [_webView canGoForward];
}

- (NSURL*)currentURL
{
    return _webView.URL;
}

- (void)goBack
{
    [_webView goBack];
}

- (void)goForward
{
    [_webView goForward];
}

- (void)reload
{
    NSURL *URL = self.currentURL;
    if(!URL){
        URL = self.URL;
        if(URL){
            [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
        }else if(self.htmlString){
            [self.webView loadHTMLString:self.htmlString baseURL:nil];
        }
    }else{
        [self.webView reload];
    }
}

- (void)loadWebContent
{
    BOOL loadEnabled = YES;
    //判断需不需要设置 自定义ua，没有获取的系统的ua 先获取
    if(!GKSystemUserAgent){
        NSString *userAgent = [self customUserAgent];
        if(![NSString isEmpty:userAgent]){
            
            if(self.URL || self.htmlString){
                [self setProgress:0.1];
            }
            loadEnabled = NO;
            WeakObj(self)
            [self loadUserAgentWithCompletion:^{
                [selfWeak loadWebContent];
            }];
        }
    }else{
        
        if([NSString isEmpty:self.webView.customUserAgent]){
            NSString *userAgent = [self customUserAgent];
            if(![NSString isEmpty:userAgent]){
                NSString *agent = [NSString stringWithFormat:@"%@ %@", GKSystemUserAgent, userAgent];
                self.webView.customUserAgent = agent;
            }
        }
    }
 
    if(loadEnabled){
        if(self.URL){
            
            [_webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
        }else if(self.htmlString){
            
            [_webView loadHTMLString:self.htmlString baseURL:nil];
        }
    }
}

// MARK: - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"]){
        
        [self setProgress:_webView.estimatedProgress];
    }else if ([keyPath isEqualToString:@"title"]){
        
        if(self.useWebTitle){
            self.navigatonBar.title = _webView.title;
        }
    }
}

// MARK: - WKNavigation delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if([self shouldOpenURL:navigationAction.request.URL action:navigationAction]){
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    //WkWebView的进程不知啥原因 停止了，刷新当前页面，防止白屏
    [webView reload];
}

// MARK: - WKUIDelegate

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo NS_AVAILABLE_IOS(10.0)
{
    //是否可以打开预览
    return NO;
}

// MARK: - Progress Handle

//设置加载进度
- (void)setProgress:(float) progress
{
    self.progressView.progress = self.shouldDisplayProgress ? progress : 0;
    [self onProgressChange:progress];
}

- (void)onProgressChange:(float) progress
{
    
}

- (BOOL)shouldOpenURL:(NSURL*) URL action:(WKNavigationAction *)action
{
    return YES;
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //防止左右滑动时触发上下滑动
    if([self.parentViewController isKindOfClass:[GKPageViewController class]]){
        GKPageViewController *page = (GKPageViewController*)self.parentViewController;
        page.scrollView.scrollEnabled = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if([self.parentViewController isKindOfClass:[GKPageViewController class]]){
        GKPageViewController *page = (GKPageViewController*)self.parentViewController;
        page.scrollView.scrollEnabled = YES;
    }
}

// MARK: - Navigation

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if(error.code != NSURLErrorCancelled){
        self.gkShowFailPage = YES;
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if(error.code != NSURLErrorCancelled){
        self.gkShowFailPage = YES;
    }
}

- (void)gkReloadData
{
    [super gkReloadData];
    if(self.URL){
        self.gkShowFailPage = NO;
        [self reload];
    }
}

@end
