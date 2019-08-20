//
//  UIViewController+GKLoading.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIViewController+GKLoading.h"
#import "UIView+GKLoading.h"

@implementation UIViewController (GKLoading)

//MARK: loading

- (void)setCa_showPageLoading:(BOOL)gk_showPageLoading
{
    [self.view setCa_showPageLoading:gk_showPageLoading];
}

- (BOOL)gk_showPageLoading
{
    return [self.view gkShowPageLoading];
}

- (void)setCa_pageLoadingView:(GKPageLoadingContainer *)gk_pageLoadingView
{
    self.view.gkPageLoadingView = gk_pageLoadingView;
}

- (GKPageLoadingContainer*)gk_pageLoadingView
{
    return self.view.gkPageLoadingView;
}

- (void)setCa_showFailPage:(BOOL)gk_showFailPage
{
    [self.view setCa_showFailPage:gk_showFailPage];
    if(gk_showFailPage){
        WeakObj(self);
        self.view.gkReloadDataHandler = ^(void){
            [selfWeak gk_reloadData];
        };
    }
}

- (BOOL)gk_showFailPage
{
    return [self.view gkShowFailPage];
}

- (void)gk_reloadData
{
    
}

//MARK: hud

- (void)gk_showProgressWithText:(NSString*) text
{
    [self.view gkShowProgressWithText:text];
}

- (void)gk_dismissProgress
{
    [self.view gkDismissProgress];
}

- (void)gk_dismissText
{
    [self.view gkDismissText];
}

- (void)gk_showProgressWithText:(NSString*) text delay:(NSTimeInterval) delay
{
    [self.view gkShowProgressWithText:text delay:delay];
}

- (void)gk_showSuccessWithText:(NSString*) text
{
    [self.view gkShowSuccessWithText:text];
}

- (void)gk_showErrorWithText:(NSString*) text
{
    [self.view gkShowErrorWithText:text];
}

- (void)gk_showWarningWithText:(NSString *)text
{
    [self.view gkShowWarningWithText:text];
}

@end
