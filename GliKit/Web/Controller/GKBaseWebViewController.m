//
//  GKBaseWebViewController.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKBaseWebViewController.h"
#import "GKProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+GKWeb.h"
#import "GKPageViewController.h"
#import "UIViewController+GKSafeAreaCompatible.h"
#import "GKNavigationBar.h"
#import "GKNavigationItemHelper.h"

///当前系统默认的 userAgent
static NSString *GKSystemUserAgent = nil;

///使用单例 防止 存储信息不一致
static WKProcessPool *sharedProcessPool;

@interface GKBaseWebViewController ()

/**
 加载进度条
 */
@property(nonatomic,strong) GKProgressView *progressView;

@end

@implementation GKBaseWebViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        [self initilization];
    }
    
    return self;
}

- (id)initWithURL:(NSString*) URL
{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        if(![NSString isEmpty:URL]){
            if(![URL hasPrefix:@"http://"] && ![URL hasPrefix:@"https://"]){
                URL = [NSString stringWithFormat:@"http://%@", URL];
            }
            self.URL = [NSURL URLWithString:URL];
        }
        
        _originalURL = [URL copy];
        [self initilization];
    }
    return self;
}

- (id)initWithHtmlString:(NSString*) htmlString
{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.htmlString = htmlString;
        [self initilization];
    }
    
    return self;
}

//初始化
- (void)initilization
{
    self.useWebTitle = YES;
    _shouldDisplayProgress = YES;
}

#pragma mark- property

- (void)setHtmlString:(NSString *)htmlString
{
    if(_htmlString != htmlString && ![_htmlString isEqualToString:htmlString]){
        if(_adjustScreenWhenLoadHtmlString && ![NSString isEmpty:htmlString]){
            _htmlString = [[NSString stringWithFormat:@"%@%@", [NSString adjustScreenHtmlString], htmlString] copy];
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

#pragma mark web control

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
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

#pragma mark dealloc

- (void)dealloc
{
    _webView.scrollView.delegate = nil;
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark 加载视图

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

/**
 初始化webView
 */
- (void)initWebView
{
    //加载进度条条
    UIView *contentView = [UIView new];
    self.contentView = contentView;
    
    GKProgressView *progressView = [[GKProgressView alloc] initWithStyle:GKProgressViewStyleStraightLine];
    progressView.progressColor = [UIColor colorWithRed:0 green:0.4784314 blue:1.0 alpha:1.0];
    progressView.trackColor = [UIColor clearColor];
    [contentView addSubview:progressView];
    self.progressView = progressView;
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[self webViewConfiguration]];
    if(@available(iOS 9.0, *)){
        _webView.allowsLinkPreview = NO;
    }
    
    if(@available(iOS 11.0, *)){
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    _webView.navigationDelegate = self;
    _webView.opaque = NO;
    _webView.UIDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.scrollView.backgroundColor = [UIColor clearColor];
    _webView.backgroundColor = [UIColor clearColor];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [contentView insertSubview:_webView belowSubview:progressView];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.height.equalTo(2.5);
        make.top.equalTo(self.gk_safeAreaLayoutGuideTop);
    }];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
}

- (WKWebViewConfiguration*)webViewConfiguration
{
    WKUserContentController *userContentController = [WKUserContentController new];
    if(self.shouldCloseSystemLongPressGesture){
        //禁止长按弹出 UIMenuController 相关
        //禁止选择 css 配置相关
        NSString *css = @"('body{-webkit-user-select:none;-webkit-user-drag:none;}')";
        //css 选中样式取消
        NSMutableString *javaScript = [NSMutableString new];
        [javaScript appendString:@"var style = document.createElement('style');"];
        [javaScript appendString:@"style.type = 'text/css';"];
        [javaScript appendFormat:@"var cssContent = document.createTextNode%@;", css];
        [javaScript appendString:@"style.appendChild(cssContent);"];
        [javaScript appendString:@"document.body.appendChild(style);"];
        [javaScript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
        [javaScript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        NSString *js = [self javascript];
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

- (void)loadWebContent
{
    BOOL loadEnable = YES;
    
    //判断需不需要设置 自定义ua，没有获取的系统的ua 先获取
    NSString *userAgent = [self customUserAgent];
    if(![NSString isEmpty:userAgent]){
        if(!GKSystemUserAgent){
            if(@available(iOS 12.0, *)){
                NSString *baseAgent = [NSString stringWithFormat:@"Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile 16A366", [UIDevice currentDevice].systemVersion];
                NSString *agent = [NSString stringWithFormat:@"%@ %@", baseAgent, userAgent];
                self.webView.customUserAgent = agent;
            }
            
            loadEnable = NO;
            WeakObj(self)
            [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                
                if([NSString isEmpty:result]){
                    result = @"";
                }
                GKSystemUserAgent = result;
                selfWeak.webView.customUserAgent = [NSString stringWithFormat:@"%@ %@", GKSystemUserAgent, userAgent];
                [selfWeak loadWebContent];
            }];
        }else{
            
            if([NSString isEmpty:self.webView.customUserAgent]){
                if(![NSString isEmpty:userAgent]){
                    self.webView.customUserAgent = [NSString stringWithFormat:@"%@ %@", GKSystemUserAgent, userAgent];
                }
            }
        }
    }
    if(loadEnable){
        if(self.URL){
            [_webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
        }else if(self.htmlString){
            [_webView loadHTMLString:self.htmlString baseURL:nil];
        }
    }
}

#pragma mark kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"]){
        
        if(self.navigatonBar && !self.navigatonBar.hidden){
            [self setProgress:_webView.estimatedProgress];
        }else{
            self.progressView.hidden = YES;
        }
    }else if ([keyPath isEqualToString:@"title"]){
        
        if(self.useWebTitle){
            if(self.navigatonBar.hidden){
                self.navigationItemHelper.title = _webView.title;
            }else{
                self.navigationItem.title = _webView.title;
            }
        }
    }
}

#pragma mark WKNavigation delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if([self shouldOpenURL:navigationAction.request.URL action:navigationAction]){
        
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

#pragma mark WKUIDelegate

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo NS_AVAILABLE_IOS(10.0)
{
    //是否可以打开预览
    return NO;
}

#pragma mark progress handle

//重设进度
- (void)resetProgress
{
    [self setProgress:0.0];
}

//设置加载进度
- (void)setProgress:(float) progress
{
    self.progressView.progress = self.shouldDisplayProgress ? progress : 0;
    [self onProgressChange:progress];
}

- (void)onProgressChange:(float) progress
{
    
}

#pragma mark 页面是否可以打开

- (BOOL)shouldOpenURL:(NSURL*) URL action:(WKNavigationAction *)action
{
    return YES;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    ///防止左右滑动时触发上下滑动
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


@end
