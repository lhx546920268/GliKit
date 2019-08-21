//
//  UIViewController+GKLoading.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIViewController+GKLoading.h"
#import "UIView+GKLoading.h"
#import "GKBaseDefines.h"

@implementation UIViewController (GKLoading)

//MARK: loading

- (void)setGkShowPageLoading:(BOOL)gkShowPageLoading
{
    self.view.gkShowPageLoading = gkShowPageLoading;
}

- (BOOL)gkShowPageLoading
{
    return [self.view gkShowPageLoading];
}

- (void)setGkPageLoadingView:(UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    self.view.gkPageLoadingView = gkPageLoadingView;
}

- (UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    return self.view.gkPageLoadingView;
}

- (void)setGkShowFailPage:(BOOL)gkShowFailPage
{
    self.view.gkShowFailPage = gkShowFailPage;
    if(gkShowFailPage){
        WeakObj(self);
        self.view.gkReloadDataHandler = ^(void){
            [selfWeak gkReloadData];
        };
    }
}

- (BOOL)gkShowFailPage
{
    return [self.view gkShowFailPage];
}

- (void)gkReloadData
{
    
}

//MARK: hud

- (void)gkShowProgressWithText:(NSString*) text
{
    [self.view gkShowProgressWithText:text];
}

- (void)gkDismissProgress
{
    [self.view gkDismissProgress];
}

- (void)gkDismissText
{
    [self.view gkDismissText];
}

- (void)gkShowProgressWithText:(NSString*) text delay:(NSTimeInterval) delay
{
    [self.view gkShowProgressWithText:text delay:delay];
}

- (void)gkShowSuccessWithText:(NSString*) text
{
    [self.view gkShowSuccessWithText:text];
}

- (void)gkShowErrorWithText:(NSString*) text
{
    [self.view gkShowErrorWithText:text];
}

- (void)gkShowWarningWithText:(NSString *)text
{
    [self.view gkShowWarningWithText:text];
}

@end
