//
//  GKDialogManager.m
//  GliKit
//
//  Created by 罗海雄 on 2023/2/13.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDialogManager.h"
#import "UIViewController+GKUtils.h"
#import "UIScreen+GKUtils.h"

///等待显示的弹窗信息
@interface GKPendingDialogModel : NSObject

///
@property(nonatomic, strong) UIViewController *viewController;

///显示完成回调
@property(nonatomic, copy) void(^completion)(void);

@end

@implementation GKPendingDialogModel

@end

@interface GKDialogManager ()

///等待显示的弹窗
@property (nonatomic, strong) NSMutableArray<GKPendingDialogModel*> *pendingDialogs;

///等待的window
@property (nonatomic, strong) NSMutableArray<UIWindow*> *pendingWindows;

///可见的window
@property (nonatomic, strong) NSMutableArray<UIWindow*> *visibleWindows;

///共享的弹窗
@property(nonatomic, strong) UIWindow *dialogWindow;

@end

@implementation GKDialogManager

+ (GKDialogManager *)sharedManager
{
    static GKDialogManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GKDialogManager new];
    });
    return manager;
}

- (NSMutableArray<GKPendingDialogModel *> *)pendingDialogs
{
    if (!_pendingDialogs) {
        _pendingDialogs = [NSMutableArray array];
    }
    return _pendingDialogs;
}

- (NSMutableArray<UIWindow *> *)pendingWindows
{
    if (!_pendingWindows) {
        _pendingWindows = [NSMutableArray array];
    }
    return _pendingWindows;
}

- (NSMutableArray<UIWindow *> *)visibleWindows
{
    if (!_visibleWindows) {
        _visibleWindows = [NSMutableArray array];
    }
    return _visibleWindows;
}

- (BOOL)hasVisibleWindow
{
    return _visibleWindows.count > 0;
}

- (BOOL)hasPendingDialog
{
    return _pendingDialogs.count > 0;
}

- (BOOL)hasMultiDialog
{
    return self.visibleWindow.rootViewController.presentedViewController != nil;
}

- (UIWindow *)visibleWindow
{
    return _visibleWindows.lastObject;
}

///创建弹窗 如果为空的时候
- (void)loadDialogWindowIfNeeded
{
    if(!self.dialogWindow){
        self.dialogWindow = [self createWindowWithLevel:UIWindowLevelAlert];
        [self makeWindowKeyAndVisibleIfEnabled:self.dialogWindow];
    }
}

///当没有弹窗的时候 移除窗口
- (void)removeDialogWindowIfNeeded
{
    if(self.dialogWindow){
        if(!self.dialogWindow.rootViewController){
            [self resignKeyWindow:self.dialogWindow];
            self.dialogWindow = nil;
        }
    }
}

- (void)showViewControllerInDialogWindow:(UIViewController *)vc completion:(void (^)(void))completion
{
    [self loadDialogWindowIfNeeded];
    if(self.dialogWindow.rootViewController){
        GKPendingDialogModel *model = [GKPendingDialogModel new];
        model.viewController = vc;
        model.completion = completion;
        [self.pendingDialogs addObject:model];
    }else{
        self.dialogWindow.rootViewController = vc;
        !completion ?: completion();
    }
}

- (void)showTopViewControllerInDialogWindow:(UIViewController *)vc completion:(void (^)(void))completion
{
    [self loadDialogWindowIfNeeded];
    if(self.dialogWindow.rootViewController){
        [self.dialogWindow.rootViewController.gkTopestPresentedViewController presentViewController:vc animated:NO completion:completion];
    }else{
        self.dialogWindow.rootViewController = vc;
        !completion ?: completion();
    }
}

- (void)removeViewControllerFromDialogWindow:(UIViewController *)vc completion:(void (^)(void))completion
{
    if (self.dialogWindow.rootViewController == vc) {
        NSMutableArray *dialogs = [self pendingDialogs];
        if(dialogs.count > 0){
            GKPendingDialogModel *model = dialogs.lastObject;
            self.dialogWindow.rootViewController = model.viewController;
            [dialogs removeLastObject];
        }else{
            self.dialogWindow.rootViewController = nil;
            [self removeDialogWindowIfNeeded];
        }
        !completion ?: completion();
    } else {
        [vc dismissViewControllerAnimated:NO completion:completion];
    }
}

- (UIWindow*)createWindowWithLevel:(UIWindowLevel)level
{
    UIWindow *window = nil;
    if(@available(iOS 13, *)){
        UIWindowScene *scene = nil;
          for(UIWindowScene *s in UIApplication.sharedApplication.connectedScenes){
              if(s.activationState == UISceneActivationStateForegroundActive && [s isKindOfClass:UIWindowScene.class]){
                  scene = s;
                  break;
              }
          }
        if(scene){
            window = [[UIWindow alloc] initWithWindowScene:scene];
        }
    }
    if(!window){
        window = UIWindow.new;
    }
    window.frame = UIScreen.gkMainScreen.bounds;
    window.windowLevel = level;
    window.backgroundColor = UIColor.clearColor;
    
    return window;
}

- (void)makeWindowKeyAndVisibleIfEnabled:(UIWindow *)window
{
    if (_visibleWindows.count > 0){
        [self.pendingWindows addObject:window];
    } else {
        [self.visibleWindows addObject:window];
        [window makeKeyAndVisible];
    }
}

- (void)resignKeyWindow:(UIWindow *)window
{
    [_visibleWindows removeObject:window];
    [window resignKeyWindow];
    
    if (_pendingWindows.count > 0) {
        UIWindow *window = _pendingWindows.lastObject;
        [self.visibleWindows addObject:window];
        
        [_pendingWindows removeLastObject];
        [window makeKeyAndVisible];
    }
}

@end
