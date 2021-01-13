//
//  UIView+GKLoading.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKLoading.h"
#import <objc/runtime.h>
#import "GKToast.h"
#import "GKKeyboardHelper.h"
#import "NSString+GKUtils.h"
#import "GKPageLoadingContainer.h"
#import "GKBaseDefines.h"

static char GKPageLoadingViewKey;
static char GKReloadDataHandlerKey;
static char GKToastKey;
static char GKPageLoadingViewInsetsKey;

@implementation UIView (CaLoading)

// MARK: - page loading

- (void)setGkShowPageLoading:(BOOL)gkShowPageLoading
{
    BOOL loading = self.gkShowPageLoading;
    if(gkShowPageLoading != loading){
        
        if(gkShowPageLoading){
            UIView<GKPageLoadingContainer> *pageLoadingView = self.gkPageLoadingView;
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
        self.gkPageLoadingView.status = GKPageLoadingStatusLoading;
    }
}

- (BOOL)gkShowPageLoading
{
    UIView<GKPageLoadingContainer> *pageLoadingView = self.gkPageLoadingView;
    return pageLoadingView != nil && pageLoadingView.status == GKPageLoadingStatusLoading;
}

- (void)setGkPageLoadingView:(UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    UIView<GKPageLoadingContainer> *pageLoadingView = self.gkPageLoadingView;
    if(pageLoadingView == gkPageLoadingView)
        return;
    if(pageLoadingView){
        [pageLoadingView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &GKPageLoadingViewKey, gkPageLoadingView, OBJC_ASSOCIATION_RETAIN);
    
    if(gkPageLoadingView){
        [self addSubview:gkPageLoadingView];
        [gkPageLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(self.gkPageLoadingViewInsets);
            
            //scrollView 需要确定滑动范围
            if([self isKindOfClass:[UIScrollView class]]){
                make.size.equalTo(self);
            }
        }];
    }
}

- (UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    return objc_getAssociatedObject(self, &GKPageLoadingViewKey);
}

- (void)setGkShowFailPage:(BOOL)gkShowFailPage
{
    if(gkShowFailPage != self.gkShowFailPage){
        
        if(gkShowFailPage){
            UIView<GKPageLoadingContainer> *pageLoadingView = self.gkPageLoadingView;
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
    UIView<GKPageLoadingContainer> *pageLoadingView = self.gkPageLoadingView;
    return pageLoadingView != nil && pageLoadingView.status == GKPageLoadingStatusError;
}

///创建pageloading
- (GKPageLoadingContainer*)getPageLoadingView
{
    GKPageLoadingContainer *pageLoadingView = [GKPageLoadingContainer new];
    pageLoadingView.backgroundColor = self.backgroundColor;
    
    WeakObj(self);
    pageLoadingView.refreshHandler = ^{
        [selfWeak gkHandlerTapFailPage];
    };
    self.gkPageLoadingView = pageLoadingView;
    return pageLoadingView;
}

- (void)setGkPageLoadingViewInsets:(UIEdgeInsets)gkPageLoadingViewInsets
{
    UIEdgeInsets insets = self.gkPageLoadingViewInsets;
    if(!UIEdgeInsetsEqualToEdgeInsets(insets, gkPageLoadingViewInsets)){
        objc_setAssociatedObject(self, &GKPageLoadingViewInsetsKey, @(gkPageLoadingViewInsets), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UIEdgeInsets)gkPageLoadingViewInsets
{
    return [objc_getAssociatedObject(self, &GKPageLoadingViewInsetsKey) UIEdgeInsetsValue];
}

// MARK: - handler

- (void)setGkReloadDataHandler:(void (^)(void))gkReloadDataHandler
{
    objc_setAssociatedObject(self, &GKReloadDataHandlerKey, gkReloadDataHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))gkReloadDataHandler
{
    return objc_getAssociatedObject(self, &GKReloadDataHandlerKey);
}

//点击失败视图
- (void)gkHandlerTapFailPage
{
    void(^handler)(void) = self.gkReloadDataHandler;
    !handler ?: handler();
}

// MARK: - Toast

- (UIView<GKToastProtocol> *)gkToast
{
    return objc_getAssociatedObject(self, &GKToastKey);
}

- (void)setGkToast:(UIView<GKToastProtocol> *) gkToast
{
    UIView<GKToastProtocol> *toast = self.gkToast;
    if(toast){
        [toast removeFromSuperview];
    }
    
    objc_setAssociatedObject(self, &GKToastKey, gkToast, OBJC_ASSOCIATION_RETAIN);
}

- (void)gkShowLoadingToastWithText:(NSString*) text
{
    [self gkShowLoadingToastWithText:text delay:0];
}

- (void)gkShowLoadingToastWithText:(NSString*) text delay:(NSTimeInterval) delay
{
    if([NSString isEmpty:text]){
        text = @"加载中...";
    }
    [self gkShowToastWithStatus:GKToastStatusLoading text:text delay:delay];
}

- (void)gkShowSuccessWithText:(NSString*) text
{
    [self gkShowToastWithStatus:GKToastStatusSuccess text:text delay:2];
}

- (void)gkShowErrorWithText:(NSString*) text
{
    [self gkShowToastWithStatus:GKToastStatusError text:text delay:2];
}

- (void)gkShowWarningWithText:(NSString *)text
{
    [self gkShowToastWithStatus:GKToastStatusWarning text:text delay:2];
}

- (void)gkShowToastWithStatus:(GKToastStatus) status text:(NSString*) text delay:(NSTimeInterval) delay
{
    [self gkShowToastInView:self withStatus:status text:text delay:delay];
}

- (void)gkDismissLoadingToast
{
    [self gkDismissLoadingToastInView:self];
}

- (void)gkDismissText
{
    [self gkDismissTextInView:self];
}

- (void)gkShowToastInView:(UIView*) view withStatus:(GKToastStatus) status text:(NSString*) text delay:(NSTimeInterval) delay
{
    UIWindow *keyboardWindow = [UIApplication sharedApplication].windows.lastObject;
    //键盘正在显示，要在键盘所在的window显示，否则可能会被键盘挡住
    if([GKKeyboardHelper sharedInstance].keyboardShowed){
        view = keyboardWindow;
    }
    
    //隐藏window上的弹窗 防止出现2个
    if(![view isEqual:UIApplication.sharedApplication.delegate.window]){
        [UIApplication.sharedApplication.delegate.window gkDismissText];
    }else if (![view isEqual:keyboardWindow]){
        [keyboardWindow gkDismissText];
    }
    
    UIView<GKToastProtocol> *toast = view.gkToast;
    if(!toast){
        toast = [GKToast new];
        view.gkToast = toast;
        
        WeakObj(view);
        toast.dismissCompletion = ^{
            viewWeak.gkToast = nil;
        };
        [view addSubview:toast];
        
        [toast mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
            
            //scrollView 需要确定滑动范围
            if([view isKindOfClass:[UIScrollView class]]){
                make.size.equalTo(view);
            }
        }];
    }
    
    toast.delay = delay;
    toast.text = text;
    toast.status = status;
    [toast show];
}

- (void)gkDismissLoadingToastInView:(UIView*) view
{
    [view.gkToast dismissLoading];
}

- (void)gkDismissTextInView:(UIView*) view
{
    [view.gkToast dismiss];
}

@end
