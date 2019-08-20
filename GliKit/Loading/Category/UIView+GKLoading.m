//
//  UIView+GKLoading.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIView+GKLoading.h"
#import <objc/runtime.h>
#import "GKPageLoadingContainer.h"
#import "GKProgressHUD.h"
#import "GKKeyboardHelper.h"
#import "NSString+GKUtils.h"

static char GKPageLoadingViewKey;
static char GKReloadDataHandlerKey;
static char GKProgressHUDKey;

@implementation UIView (CaLoading)

#pragma mark- page loading

- (void)setGkShowPageLoading:(BOOL)gkShowPageLoading
{
    BOOL loading = self.gkShowPageLoading;
    if(gkShowPageLoading != loading){
        
        if(gkShowPageLoading){
            GKPageLoadingContainer *pageLoadingView = self.gkPageLoadingView;
            if(!pageLoadingView){
                pageLoadingView = [self getPageLoadingView];
            }
            
            pageLoadingView.backgroundColor = self.backgroundColor;
            pageLoadingView.status = GKPageLoadingStatusLoading;
            pageLoadingView.hidden = NO;
            [self bringSubviewToFront:pageLoadingView];
        }else{
            self.gkPageLoadingView = nil;
        }
    }else if(loading){
        //如果原来已经显示 可能动画是停止的
        [self.gkPageLoadingView.animatedimageView startAnimating];
    }
}

- (BOOL)gkShowPageLoading
{
    GKPageLoadingContainer *pageLoadingView = self.gkPageLoadingView;
    return pageLoadingView != nil && pageLoadingView.status == GKPageLoadingStatusLoading;
}

- (void)setCa_pageLoadingView:(GKPageLoadingContainer *)gk_pageLoadingView
{
    GKPageLoadingContainer *pageLoadingView = self.gkPageLoadingView;
    if(pageLoadingView == gk_pageLoadingView)
        return;
    if(pageLoadingView){
        [pageLoadingView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &GKPageLoadingViewKey, gk_pageLoadingView, OBJC_ASSOCIATION_RETAIN);
    
    if(gk_pageLoadingView){
        [self addSubview:gk_pageLoadingView];
        [gk_pageLoadingView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            
            //scrollView 需要确定滑动范围
            if([self isKindOfClass:[UIScrollView class]]){
                make.size.equalTo(self);
            }
        }];
    }
}

- (GKPageLoadingContainer*)gkPageLoadingView
{
    return objc_getAssociatedObject(self, &GKPageLoadingViewKey);
}

- (void)setCa_showFailPage:(BOOL)gk_showFailPage
{
    if(gk_showFailPage != self.gkShowFailPage){
        
        if(gk_showFailPage){
            GKPageLoadingContainer *pageLoadingView = self.gkPageLoadingView;
            if(!pageLoadingView){
                pageLoadingView = [self getPageLoadingView];
            }
            
            pageLoadingView.status = GKPageLoadingStatusError;
            pageLoadingView.hidden = NO;
            [self bringSubviewToFront:pageLoadingView];
        }else{
            self.gkPageLoadingView = nil;
        }
    }
}

- (BOOL)gkShowFailPage
{
    GKPageLoadingContainer *pageLoadingView = self.gkPageLoadingView;
    return pageLoadingView != nil && pageLoadingView.status == GKPageLoadingStatusError;
}

///创建pageloading
- (GKPageLoadingContainer*)getPageLoadingView
{
    GKPageLoadingContainer *pageLoadingView = [GKPageLoadingContainer new];
    pageLoadingView.backgroundColor = self.backgroundColor;
    
    WeakObj(self);
    pageLoadingView.refreshHandler = ^{
        [selfWeak handlerTapFailPage:nil];
    };
    self.gkPageLoadingView = pageLoadingView;
    return pageLoadingView;
}

#pragma mark- handler

- (void)setCa_reloadDataHandler:(void (^)(void))gk_reloadDataHandler
{
    objc_setAssociatedObject(self, &GKReloadDataHandlerKey, gk_reloadDataHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))gkReloadDataHandler
{
    return objc_getAssociatedObject(self, &GKReloadDataHandlerKey);
}

//点击失败视图
- (void)handlerTapFailPage:(UITapGestureRecognizer*) tap
{
    void(^handler)(void) = self.gkReloadDataHandler;
    !handler ?: handler();
}

#pragma mark hud

- (GKProgressHUD*)gkProgressHUD
{
    return objc_getAssociatedObject(self, &GKProgressHUDKey);
}

- (void)setCa_progressHUD:(GKProgressHUD *)gk_progressHUD
{
    GKProgressHUD *hud = self.gkProgressHUD;
    if(hud){
        [hud removeFromSuperview];
    }
    
    objc_setAssociatedObject(self, &GKProgressHUDKey, gk_progressHUD, OBJC_ASSOCIATION_RETAIN);
}

- (void)gkShowProgressWithText:(NSString*) text
{
    [self gkShowProgressWithText:text delay:0];
}

- (void)gkShowProgressWithText:(NSString*) text delay:(NSTimeInterval) delay
{
    if([NSString isEmpty:text]){
        text = @"load_data".zegoLocalizedString;
    }
    [self gk_showHudWithStatus:GKProgressHUDStatusLoading text:text delay:delay];
}

- (void)gkShowSuccessWithText:(NSString*) text
{
    [self gk_showHudWithStatus:GKProgressHUDStatusSuccess text:text delay:2];
}

- (void)gkShowErrorWithText:(NSString*) text
{
    [self gk_showHudWithStatus:GKProgressHUDStatusError text:text delay:2];
}

- (void)gkShowWarningWithText:(NSString *)text
{
    [self gk_showHudWithStatus:GKProgressHUDStatusWarning text:text delay:2];
}

- (void)gk_showHudWithStatus:(GKProgressHUDStatus) status text:(NSString*) text delay:(NSTimeInterval) delay
{
    [self gk_showHudInView:self withStatus:status text:text delay:delay];
}

- (void)gkDismissProgress
{
    [self gk_dismissProgressInView:self];
}

- (void)gkDismissText
{
    [self gk_dismissTextInView:self];
}

- (void)gk_showHudInView:(UIView*) view withStatus:(GKProgressHUDStatus) status text:(NSString*) text delay:(NSTimeInterval) delay
{
    UIWindow *keyboardWindow = [UIApplication sharedApplication].windows.lastObject;
    //键盘正在显示，要在键盘所在的window显示，否则可能会被键盘挡住
    if([GKKeyboardHelper sharedInstance].keyboardShowed){
        view = keyboardWindow;
    }
    
    //隐藏window上的弹窗 防止出现2个
    if(![view isEqual:[AppDelegate instance].window]){
        [[AppDelegate instance].window gk_dismissText];
    }else if (![view isEqual:keyboardWindow]){
        [keyboardWindow gkDismissText];
    }
    
    GKProgressHUD *hud = view.gkProgressHUD;
    if(!hud){
        hud = [GKProgressHUD new];
        view.gkProgressHUD = hud;
        
        WeakObj(view);
        hud.dismissHandler = ^{
            viewWeak.gk_progressHUD = nil;
        };
        [view addSubview:hud];
        
        [hud makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
            
            //scrollView 需要确定滑动范围
            if([view isKindOfClass:[UIScrollView class]]){
                make.size.equalTo(view);
            }
        }];
    }
    
    hud.delay = delay;
    hud.msg = text;
    hud.status = status;
    [hud show];
}

- (void)gk_dismissProgressInView:(UIView*) view
{
    [view.gkProgressHUD dismissProgress];
}

- (void)gk_dismissTextInView:(UIView*) view
{
    [view.gkProgressHUD dismiss];
}

@end
