//
//  UIViewController+GKDialog.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKDialog.h"
#import "UIViewController+GKKeyboard.h"
#import "UIView+GKAutoLayout.h"
#import "GKBaseViewController.h"
#import "GKContainer.h"
#import "NSObject+GKUtils.h"
#import "GKBaseDefines.h"
#import <objc/runtime.h>
#import "UIViewController+GKUtils.h"
#import "UIView+GKUtils.h"
#import "GKDialogManager.h"
#import "GKScrollViewController.h"
#import "GKDialogInteractiveDismisHelper.h"

static char GKIsShowAsDialogKey;
static char GKDialogKey;
static char GKDialogShouldUseNewWindowKey;
static char GKDialogPriorityKey;
static char GKShouldDismissDialogOnTapTranslucentKey;
static char GKDialogBackgroundViewKey;
static char GKDialogShowAnimateKey;
static char GKDialogDismissAnimateKey;
static char GKisDialogShowingKey;
static char GKDialogShowCompletionHandlerKey;
static char GKDialogWillDismissnHandlerKey;
static char GKDialogDismissCompletionHandlerKey;
static char GKDialogShouldAnimateKey;
static char GKTapDialogBackgroundGestureRecognizerKey;
static char GKIsDialogViewDidLayoutSubviewsKey;
static char GKDialogInteractiveDismissibleKey;
static char GKDialogInteractiveDismisHelperKey;

@implementation UIViewController (GKDialog)

+ (void)load
{
    SEL selectors[] = {
        @selector(viewWillAppear:),
        @selector(viewWillDisappear:),
        @selector(viewDidAppear:),
        @selector(viewDidLoad),
        @selector(viewDidLayoutSubviews)
    };
    
    int count = sizeof(selectors) / sizeof(SEL);
    for(int i = 0;i < count;i ++){
        [self gkExchangeImplementations:selectors[i] prefix:@"gkDialog_"];
    }
}

// MARK: - 视图消失出现

- (void)gkDialog_viewWillAppear:(BOOL)animated
{
    [self gkDialog_viewWillAppear:animated];
    if(self.isShowAsDialog){
        [self setIsDialogShowing:YES];
    }
}

- (void)gkDialog_viewWillDisappear:(BOOL)animated
{
    [self gkDialog_viewWillDisappear:animated];
    if(self.isShowAsDialog){
        [self setIsDialogShowing:NO];
    }
}

- (void)gkDialog_viewDidAppear:(BOOL)animated
{
    [self gkDialog_viewDidAppear:animated];
    if(self.isShowAsDialog){
        [self executeShowAnimate];
    }
}

// MARK: - View init

- (void)gkDialog_viewDidLoad {
 
      [self gkDialog_viewDidLoad];
      
      if(self.isShowAsDialog){
          UIView *backgroundView = [UIView new];
          backgroundView.alpha = 0;
          backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
          [self.view insertSubview:backgroundView atIndex:0];
          
          [backgroundView addGestureRecognizer:self.tapDialogBackgroundGestureRecognizer];
          self.tapDialogBackgroundGestureRecognizer.enabled = self.shouldDismissDialogOnTapTranslucent;
          
          [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.edges.equalTo(self.view);
          }];
          [self setDialogBackgroundView:backgroundView];
          
          self.view.backgroundColor = [UIColor clearColor];
      }
}

- (void)gkDialog_viewDidLayoutSubviews
{
    [self gkDialog_viewDidLayoutSubviews];
    [self setIsDialogViewDidLayoutSubviews:YES];
    
    if(self.isShowAsDialog){
        [self executeShowAnimate];
    }
}

- (void)setIsDialogViewDidLayoutSubviews:(BOOL) flag
{
    objc_setAssociatedObject(self, &GKIsDialogViewDidLayoutSubviewsKey, @(flag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDialogViewDidLayoutSubviews
{
    return [objc_getAssociatedObject(self, &GKIsDialogViewDidLayoutSubviewsKey) boolValue];
}

- (void)onDialogInitialize{}

// MARK: - 状态

- (void)setIsShowAsDialog:(BOOL)isShowAsDialog
{
    objc_setAssociatedObject(self, &GKIsShowAsDialogKey, @(isShowAsDialog), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isShowAsDialog
{
    return [objc_getAssociatedObject(self, &GKIsShowAsDialogKey) boolValue];
}

- (void)setIsDialogShowing:(BOOL)isDialogShowing
{
    objc_setAssociatedObject(self, &GKisDialogShowingKey, @(isDialogShowing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDialogShowing
{
    return [objc_getAssociatedObject(self, &GKisDialogShowingKey) boolValue];
}

// MARK: - View

- (void)setDialog:(UIView *)dialog
{
#ifdef DEBUG
    if([self isKindOfClass:[GKBaseViewController class]]){
        GKBaseViewController *vc = (GKBaseViewController*)self;
        NSAssert(vc.container == nil, @"如果 UIViewController 是 GKBaseViewController 或者其子类，并且没有使用xib，dialog属性将自动设置为 GKContainer");
    }
#endif
    objc_setAssociatedObject(self, &GKDialogKey, dialog, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)dialog
{
    if([self isKindOfClass:[GKBaseViewController class]]){
        GKBaseViewController *vc = (GKBaseViewController*)self;
        if(vc.container != nil){
            return vc.container;
        }
    }
    
    return objc_getAssociatedObject(self, &GKDialogKey);
}

- (void)setDialogShouldUseNewWindow:(BOOL)dialogShouldUseNewWindow
{
    objc_setAssociatedObject(self, &GKDialogShouldUseNewWindowKey, @(dialogShouldUseNewWindow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dialogShouldUseNewWindow
{
    return [objc_getAssociatedObject(self, &GKDialogShouldUseNewWindowKey) boolValue];
}

- (void)setDialogPriority:(NSInteger)dialogPriority
{
    objc_setAssociatedObject(self, &GKDialogPriorityKey, @(dialogPriority), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)dialogPriority
{
    return [objc_getAssociatedObject(self, &GKDialogPriorityKey) integerValue];
}

- (UIWindow *)dialogWindow
{
    if(self.dialogShouldUseNewWindow){
        return GKDialogManager.sharedManager.dialogWindow;
    }else{
        return UIApplication.sharedApplication.delegate.window;
    }
}

// MARK: - 背景

- (void)setShouldDismissDialogOnTapTranslucent:(BOOL) flag
{
    if(self.shouldDismissDialogOnTapTranslucent != flag){
        
        objc_setAssociatedObject(self, &GKShouldDismissDialogOnTapTranslucentKey, @(flag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.tapDialogBackgroundGestureRecognizer.enabled = flag;
    }
}

- (BOOL)shouldDismissDialogOnTapTranslucent
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldDismissDialogOnTapTranslucentKey);
    return number != nil ? number.boolValue : YES;
}

- (UIGestureRecognizer*)tapDialogBackgroundGestureRecognizer
{
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &GKTapDialogBackgroundGestureRecognizerKey);
    if(!tap){
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapDialogBackground)];
        objc_setAssociatedObject(self, &GKTapDialogBackgroundGestureRecognizerKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tap;
}

- (void)handleTapDialogBackground
{
    [self dismissDialog];
}

- (void)setDialogBackgroundView:(UIView *)dialogBackgroundView
{
    objc_setAssociatedObject(self, &GKDialogBackgroundViewKey, dialogBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)dialogBackgroundView
{
    return objc_getAssociatedObject(self, &GKDialogBackgroundViewKey);
}

// MARK: - 下拉关闭弹窗交互

- (void)setDialogInteractiveDismissible:(BOOL)dialogInteractiveDismissible
{
    objc_setAssociatedObject(self, &GKDialogDismissAnimateKey, @(dialogInteractiveDismissible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dialogInteractiveDismissible
{
    NSNumber *number = objc_getAssociatedObject(self, &GKDialogInteractiveDismissibleKey);
    return number != nil ? number.boolValue : YES;
}

- (void)setDialogInteractiveDismisHelper:(GKDialogInteractiveDismisHelper*) helper
{
    objc_setAssociatedObject(self, &GKDialogInteractiveDismisHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GKDialogInteractiveDismisHelper*)dialogInteractiveDismisHelper
{
    return objc_getAssociatedObject(self, &GKDialogInteractiveDismisHelperKey);
}

// MARK: - 回调 Block

- (void)setDialogShowCompletionHandler:(void (^)(void)) handler
{
    objc_setAssociatedObject(self, &GKDialogShowCompletionHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(void))dialogShowCompletionHandler
{
    return objc_getAssociatedObject(self, &GKDialogShowCompletionHandlerKey);
}

- (void)setDialogWillDismissHandler:(void (^)(BOOL)) handler
{
    objc_setAssociatedObject(self, &GKDialogWillDismissnHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(BOOL))dialogWillDismissHandler
{
    return objc_getAssociatedObject(self, &GKDialogWillDismissnHandlerKey);
}

- (void)setDialogDismissCompletionHandler:(void (^)(void)) handler
{
    objc_setAssociatedObject(self, &GKDialogDismissCompletionHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(void))dialogDismissCompletionHandler
{
    return objc_getAssociatedObject(self, &GKDialogDismissCompletionHandlerKey);
}

// MARK: - 动画属性

- (void)setDialogShowAnimate:(GKDialogAnimate)dialogShowAnimate
{
    objc_setAssociatedObject(self, &GKDialogShowAnimateKey, @(dialogShowAnimate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GKDialogAnimate)dialogShowAnimate
{
    return [objc_getAssociatedObject(self, &GKDialogShowAnimateKey) integerValue];
}

- (void)setDialogDismissAnimate:(GKDialogAnimate)dialogDismissAnimate
{
    objc_setAssociatedObject(self, &GKDialogDismissAnimateKey, @(dialogDismissAnimate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GKDialogAnimate)dialogDismissAnimate
{
    return [objc_getAssociatedObject(self, &GKDialogDismissAnimateKey) integerValue];
}

- (void)setDialogShouldAnimate:(BOOL) dialogShouldAnimate
{
    objc_setAssociatedObject(self, &GKDialogShouldAnimateKey, @(dialogShouldAnimate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dialogShouldAnimate
{
    return [objc_getAssociatedObject(self, &GKDialogShouldAnimateKey) boolValue];
}

// MARK: - 显示

- (void)showAsDialog
{
    [self showAsDialogAnimated:YES];
}

- (void)showAsDialogAnimated:(BOOL)animated
{
    [self showAsDialogInViewController:nil animated:animated];
}

- (void)showAsDialogInViewController:(UIViewController *)viewController
{
    [self showAsDialogInViewController:viewController inPresentWay:YES layoutHandler:nil animated:YES];
}

- (void)showAsDialogInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self showAsDialogInViewController:viewController inPresentWay:YES layoutHandler:nil animated:animated];
}

- (void)showAsDialogInViewController:(UIViewController *)viewController layoutHandler:(void (NS_NOESCAPE ^)(UIView *, UIView *))layoutHandler
{
    [self showAsDialogInViewController:viewController inPresentWay:NO layoutHandler:layoutHandler animated:YES];
}

- (void)showAsDialogInViewController:(UIViewController *)viewController layoutHandler:(void (NS_NOESCAPE^)(UIView *, UIView *))layoutHandler animated:(BOOL)animated
{
    [self showAsDialogInViewController:viewController inPresentWay:NO layoutHandler:layoutHandler animated:animated];
}

- (void)showAsDialogInViewController:(UIViewController *)viewController inPresentWay:(BOOL) inPresentWay layoutHandler:(void (NS_NOESCAPE ^)(UIView *, UIView *))layoutHandler animated:(BOOL)animated
{
    if(self.isDialogShowing){
        return;
    }
    
    self.dialogShouldAnimate = animated;
    [self setIsShowAsDialog:YES];
    [self onDialogInitialize];
    
    if(self.dialogShouldUseNewWindow){
        [GKDialogManager.sharedManager showDialogController:self inViewController:viewController priority:self.dialogPriority completion:self.dialogShowCompletionHandler];
    } else {
        if (!viewController) {
            viewController = UIApplication.sharedApplication.delegate.window.rootViewController.gkTopestPresentedViewController;
        }
        if(inPresentWay){
            //设置使背景透明
            self.modalPresentationStyle = UIModalPresentationCustom;
            [viewController presentViewController:self animated:NO completion:nil];
        }else{
            [viewController.view addSubview:self.view];
            [viewController addChildViewController:self];
            if(layoutHandler){
                layoutHandler(self.view, viewController.view);
            }else{
                [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(viewController.view);
                }];
            }
        }
    }
    
    if (self.dialogInteractiveDismissible
        && self.dialogShowAnimate == GKDialogAnimateFromBottom
        && self.dialogDismissAnimate == GKDialogAnimateFromBottom) {
        [self setDialogInteractiveDismisHelper:[[GKDialogInteractiveDismisHelper alloc] initWithViewController:self]];
    }
    
    if (!animated) {
        [self onDialogShowInternal];
    }
}

- (void)onDialogShowInternal
{
    !self.dialogShowCompletionHandler ?: self.dialogShowCompletionHandler();
    [self onDialogShow];
}

- (void)onDialogShow{}

// MARK: - 动画

///执行出场动画
- (void)executeShowAnimate
{
    //出场动画
    if(self.dialog && self.isDialogViewDidLayoutSubviews){
        if(self.dialogShouldAnimate){
            [self setDialogShouldAnimate:NO];
            
            NSTimeInterval duration = [self showDurationForDialogAnimate:self.dialogShowAnimate];
            switch (self.dialogShowAnimate) {
                case GKDialogAnimateNone : {
                    self.dialogBackgroundView.alpha = 1.0;
                    [self onDialogShowInternal];
                }
                    break;
                case GKDialogAnimateScale : {
                    
                    self.dialog.alpha = 0;
                    [UIView animateWithDuration:duration animations:^(void){
                        
                        self.dialogBackgroundView.alpha = 1.0;
                        self.dialog.alpha = 1.0;
                        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                        animation.fromValue = @(1.3);
                        animation.toValue = @(1.0);
                        animation.duration = duration;
                        [self.dialog.layer addAnimation:animation forKey:@"scale"];
                        [self showAnimateAlongsideWithDialog];
                    } completion:^(BOOL finished) {
                        [self onDialogShowInternal];
                    }];
                }
                    break;
                case GKDialogAnimateFromTop : {
                    [UIView animateWithDuration:duration animations:^(void){
                        
                        self.dialogBackgroundView.alpha = 1.0;
                        
                        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
                        animation.fromValue = @(-self.dialog.gkHeight / 2.0);
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                        animation.toValue = @(self.dialog.layer.position.y);
                        animation.duration = duration;
                        [self.dialog.layer addAnimation:animation forKey:@"position"];
                        [self showAnimateAlongsideWithDialog];
                    } completion:^(BOOL finished) {
                        [self onDialogShowInternal];
                    }];
                }
                    break;
                case GKDialogAnimateFromBottom : {
                    
                    [UIView animateWithDuration:duration animations:^(void){
                        
                        self.dialogBackgroundView.alpha = 1.0;
                        
                        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
                        animation.fromValue = @(self.view.gkHeight + self.dialog.gkHeight / 2);
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        animation.toValue = @(self.dialog.layer.position.y);
                        animation.duration = duration;
                        [self.dialog.layer addAnimation:animation forKey:@"position"];
                        [self showAnimateAlongsideWithDialog];
                    } completion:^(BOOL finished) {
                        [self onDialogShowInternal];
                    }];
                }
                    break;
                case GKDialogAnimateCustom : {
                    
                    [self didExecuteDialogShowCustomAnimate:^(BOOL finish){
                        [self onDialogShowInternal];
                    }];
                }
                    break;
            }
        }else{
            self.dialogBackgroundView.alpha = 1.0;
        }
    }
    
}

- (void)dismissDialogAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    !self.dialogWillDismissHandler ?: self.dialogWillDismissHandler(animated);
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    if(animated){
        NSTimeInterval duration = [self dismissDurationForDialogAnimate:self.dialogDismissAnimate];
        switch (self.dialogDismissAnimate) {
            case GKDialogAnimateNone : {
                [self onDialogDismissWithCompletion:completion];
            }
                break;
            case GKDialogAnimateScale : {
                
                [UIView animateWithDuration:duration animations:^(void){
                    
                    [self setNeedsStatusBarAppearanceUpdate];
                    self.dialogBackgroundView.alpha = 0;
                    self.dialog.alpha = 0;
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                    animation.fromValue = @(1.0);
                    animation.toValue = @(1.3);
                    animation.duration = duration;
                    animation.fillMode = kCAFillModeForwards;
                    animation.removedOnCompletion = NO;
                    [self.dialog.layer addAnimation:animation forKey:@"scale"];
                    [self dismissAnimateAlongsideWithDialog];
                }completion:^(BOOL finish){
                    [self onDialogDismissWithCompletion:completion];
                }];
            }
                break;
            case GKDialogAnimateFromTop : {
                
                [UIView animateWithDuration:duration animations:^(void){
                    
                    [self setNeedsStatusBarAppearanceUpdate];
                    self.dialogBackgroundView.alpha = 0;
                    
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
                    animation.fromValue = @(self.dialog.layer.position.y);
                    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                    animation.toValue = @(- self.dialog.gkHeight / 2.0);
                    animation.duration = duration;
                    animation.fillMode = kCAFillModeForwards;
                    animation.removedOnCompletion = NO;
                    [self.dialog.layer addAnimation:animation forKey:@"position"];
                    [self dismissAnimateAlongsideWithDialog];
                }completion:^(BOOL finish){
                    [self onDialogDismissWithCompletion:completion];
                }];
            }
                break;
            case GKDialogAnimateFromBottom : {
                
                [UIView animateWithDuration:duration animations:^(void){
                    
                    [self setNeedsStatusBarAppearanceUpdate];
                    self.dialogBackgroundView.alpha = 0;
                    
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
                    animation.fromValue = @(self.dialog.layer.position.y);
                    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    animation.toValue = @(self.view.gkHeight + self.dialog.gkHeight / 2);
                    animation.duration = duration;
                    animation.fillMode = kCAFillModeForwards;
                    animation.removedOnCompletion = NO;
                    [self.dialog.layer addAnimation:animation forKey:@"position"];
                    [self dismissAnimateAlongsideWithDialog];
                }completion:^(BOOL finish){
                    
                    [self onDialogDismissWithCompletion:completion];
                }];
            }
                break;
            case GKDialogAnimateCustom : {
                
                WeakObj(self);
                [self didExecuteDialogDismissCustomAnimate:^(BOOL finish){
                    
                    [selfWeak onDialogDismissWithCompletion:completion];
                }];
            }
                break;
        }
    }else{
        [self onDialogDismissWithCompletion:completion];
    }
}

- (void)didExecuteDialogShowCustomAnimate:(void(^)(BOOL finish)) completion
{
    !completion ?: completion(YES);
}

- (void)didExecuteDialogDismissCustomAnimate:(void(^)(BOOL finish)) completion
{
    !completion ?: completion(YES);
}

- (void)showAnimateAlongsideWithDialog{}
- (void)dismissAnimateAlongsideWithDialog{}

- (NSTimeInterval)showDurationForDialogAnimate:(GKDialogAnimate)animate
{
    return 0.25;
}

- (NSTimeInterval)dismissDurationForDialogAnimate:(GKDialogAnimate)animate
{
    return 0.25;
}

// MARK: - 关闭

- (void)dismissDialog
{
    [self dismissDialogAnimated:YES];
}

- (void)dismissDialogAnimated:(BOOL)animated
{
    [self dismissDialogAnimated:animated completion:nil];
}

///消失动画完成
- (void)onDialogDismissWithCompletion:(void(^)(void)) completion
{
    if(self.dialogShouldUseNewWindow){
        [GKDialogManager.sharedManager removeDialogController:self];
        [self afterDialogDismissWithCompletion:completion];
    }else{
        if(self.presentingViewController){
            [self dismissViewControllerAnimated:NO completion:^{
                [self afterDialogDismissWithCompletion:completion];
            }];
        }else{
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [self afterDialogDismissWithCompletion:completion];
        }
    }
}

///弹窗消失
- (void)afterDialogDismissWithCompletion:(void(^)(void)) completion
{
    !completion ?: completion();
    !self.dialogDismissCompletionHandler ?: self.dialogDismissCompletionHandler();
    [self onDialogDismiss];
}

- (void)onDialogDismiss{}

// MARK: - 键盘

- (void)adjustDialogPosition
{
    CGFloat y = 0;
    if(self.keyboardHidden){
        y = self.view.gkHeight / 2.0;
    }else{
        y = MIN(self.view.gkHeight / 2.0, self.view.gkHeight - self.keyboardFrame.size.height - self.dialog.gkHeight / 2.0 - 10.0);
    }
    
    NSLayoutConstraint *constraint = self.dialog.gkCenterYLayoutConstraint;
    [UIView animateWithDuration:0.25 animations:^(void){
        
        if(constraint){
            constraint.constant = y - self.view.gkHeight / 2.0;
            [self.view layoutIfNeeded];
        }else{
            self.dialog.center = CGPointMake(self.dialog.center.x, y - self.view.gkHeight / 2.0);
        }
    }];
}

@end
