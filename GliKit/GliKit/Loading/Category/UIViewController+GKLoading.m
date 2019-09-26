//
//  UIViewController+GKLoading.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKLoading.h"
#import "UIView+GKLoading.h"
#import "GKBaseDefines.h"
#import "UIViewController+GKDialog.h"

@implementation UIViewController (GKLoading)

///获取当前内容视图
- (UIView*)gkContentView
{
    return self.isShowAsDialog ? self.dialog : self.view;
}

// MARK: - loading

- (void)setGkShowPageLoading:(BOOL)gkShowPageLoading
{
    self.gkContentView.gkShowPageLoading = gkShowPageLoading;
}

- (BOOL)gkShowPageLoading
{
    return [self.gkContentView gkShowPageLoading];
}

- (void)setGkPageLoadingView:(UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    self.gkContentView.gkPageLoadingView = gkPageLoadingView;
}

- (UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    return self.gkContentView.gkPageLoadingView;
}

- (void)setGkShowFailPage:(BOOL)gkShowFailPage
{
    self.gkContentView.gkShowFailPage = gkShowFailPage;
    if(gkShowFailPage){
        WeakObj(self);
        self.gkContentView.gkReloadDataHandler = ^(void){
            [selfWeak gkReloadData];
        };
    }
}

- (BOOL)gkShowFailPage
{
    return [self.gkContentView gkShowFailPage];
}

- (void)gkReloadData
{
    
}

// MARK: - hud

- (void)gkShowProgressWithText:(NSString*) text
{
    [self.gkContentView gkShowProgressWithText:text];
}

- (void)gkDismissProgress
{
    [self.gkContentView gkDismissProgress];
}

- (void)gkDismissText
{
    [self.gkContentView gkDismissText];
}

- (void)gkShowProgressWithText:(NSString*) text delay:(NSTimeInterval) delay
{
    [self.gkContentView gkShowProgressWithText:text delay:delay];
}

- (void)gkShowSuccessWithText:(NSString*) text
{
    [self.gkContentView gkShowSuccessWithText:text];
}

- (void)gkShowErrorWithText:(NSString*) text
{
    [self.gkContentView gkShowErrorWithText:text];
}

- (void)gkShowWarningWithText:(NSString *)text
{
    [self.gkContentView gkShowWarningWithText:text];
}

@end
