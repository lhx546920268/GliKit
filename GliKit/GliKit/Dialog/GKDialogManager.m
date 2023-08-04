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
#import "GKBaseDefines.h"
#import "GKBaseViewController.h"
#import "UIViewController+GKPush.h"

///等于vc自身或者其parent
BOOL GKViewControllerEqualOrParent(UIViewController *vc, UIViewController *comparedVC) {
    if (vc == nil || comparedVC == nil) return NO;
    if (vc == comparedVC) return YES;
    UIViewController *parent = comparedVC.parentViewController;
    while (parent) {
        if (vc == parent) return YES;
        parent = parent.parentViewController;
    }
    return NO;
}

///弹窗信息
@interface GKDialogModel : NSObject

///
@property(nonatomic, strong) UIViewController *viewController;

///当前必须是某个viewController才显示
@property(nonatomic, weak) UIViewController *requiredParentViewController;

///显示完成回调
@property(nonatomic, copy) void(^completion)(void);

///
@property(nonatomic, strong) UIView *view;

///优先级
@property(nonatomic, assign) NSInteger priority;

///是否可以显示
@property(nonatomic, readonly) BOOL displayEnabled;

@end

@implementation GKDialogModel

- (UIView *)view
{
    return _view ?: self.viewController.view;
}

- (BOOL)displayEnabled
{
    return self.requiredParentViewController == nil || GKViewControllerEqualOrParent(self.requiredParentViewController, self.gkCurrentViewController);
}

@end

@interface GKDialogWindow()

///当前显示的
@property(nonatomic, strong) NSMutableArray<GKDialogModel*> *models;

@end

@implementation GKDialogWindow

- (void)loadRootViewControllerIfNeeded
{
    if (!self.rootViewController) {
        UIViewController *root = [UIViewController new];
        root.view.backgroundColor = UIColor.clearColor;
        self.rootViewController = root;
    }
}

- (NSMutableArray<GKDialogModel *> *)models
{
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

- (void)addDialogModel:(GKDialogModel*) model
{
    [self loadRootViewControllerIfNeeded];
    if (self.models.count > 0) {
        for (NSInteger i = self.models.count - 1; i >= 0; i --) {
            if (model.priority < self.models[i].priority) {
                [self.models insertObject:model atIndex:i];
                [self.rootViewController.view insertSubview:model.view atIndex:i];
                break;
            }
        }
    }
    
    if (!model.view.superview) {
        [self.models addObject:model];
        [self.rootViewController.view addSubview:model.view];
    }
    
    [model.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void)removeDialogModel:(GKDialogModel*) model
{
    [_models removeObject:model];
    [model.view removeFromSuperview];
}

- (void)removeDialog:(UIView*) dialog
{
    for (NSInteger i = 0; i < self.models.count; i ++) {
        GKDialogModel *model = self.models[i];
        if (model.view == dialog) {
            [self.models removeObjectAtIndex:i];
            [model.view removeFromSuperview];
        }
    }
}

@end

///栈
@interface GKDialogStack : NSObject

///
@property(nonatomic, strong) NSMutableArray<GKDialogModel*> *models;

///是否为空
@property(nonatomic, readonly) BOOL isEmpty;

///
@property(nonatomic, readonly) BOOL isNotEmpty;

@end

@implementation GKDialogStack

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.models = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isEmpty
{
    return self.models.count == 0;
}

- (BOOL)isNotEmpty
{
    return self.models.count > 0;
}

- (void)put:(GKDialogModel*) model
{
    if (self.isEmpty) {
        [self.models addObject:model];
    } else {
        for (NSInteger i = 0; i < self.models.count; i ++) {
            if (self.models[i].priority >= model.priority) {
                [self.models insertObject:model atIndex:i];
                break;
            }
        }
    }
}

- (GKDialogModel*)popForViewController:(UIViewController*) vc
{
    if (self.isNotEmpty) {
        GKDialogModel *model = self.models.lastObject;
        if (model.requiredParentViewController == nil || GKViewControllerEqualOrParent(model.requiredParentViewController, vc)) {
            [self.models removeLastObject];
            return model;
        }
    }
    return nil;
}

@end

@interface GKDialogManager ()

///等待显示的弹窗
@property (nonatomic, strong) GKDialogStack *pendingDialogs;

///共享的弹窗
@property (nonatomic, strong) GKDialogWindow *dialogWindow;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(viewControllerVisibleDidChange:) name:GKBaseViewControllerVisibleDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(viewControllerVisibleWillChange:) name:GKBaseViewControllerVisibleWillChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

// MARK: - 通知

- (void)viewControllerVisibleDidChange:(NSNotification*) notification
{
    if ([notification.userInfo[GKVisibleKey] boolValue]) {
        UIViewController *vc = notification.userInfo[GKVisibleViewControllerKey];
        //显示需要的弹窗
        GKDialogModel *model = [_pendingDialogs popForViewController:vc];
        if (model) {
            [self loadDialogWindowIfNeeded];
            [self.dialogWindow addDialogModel:model];
            !model.completion ?: model.completion();
        }
    }
}

- (void)viewControllerVisibleWillChange:(NSNotification*) notification
{
    if (![notification.userInfo[GKVisibleKey] boolValue]) {
        UIViewController *vc = notification.userInfo[GKVisibleViewControllerKey];
        //移除弹窗，有些弹窗只在部分界面显示
        if (self.dialogWindow.models.count > 0) {
            NSMutableArray *models = [NSMutableArray array];
            for (NSInteger i = 0; i < self.dialogWindow.models.count; i ++) {
                GKDialogModel *model = self.dialogWindow.models[i];
                if (model.requiredParentViewController != nil && GKViewControllerEqualOrParent(model.requiredParentViewController, vc)) {
                    [models addObject:model];
                }
            }
            
            if (models.count > 0) {
                for (GKDialogModel *model in models) {
                    [self.dialogWindow removeDialogModel:model];
                }
                [self removeDialogWindowIfNeeded];
            }
        }
    }
}

// MARK: - Props

- (GKDialogStack *)pendingDialogs
{
    if (!_pendingDialogs) {
        _pendingDialogs = [GKDialogStack new];
    }
    return _pendingDialogs;
}

- (BOOL)hasPendingDialog
{
    return _pendingDialogs.isNotEmpty;
}

- (BOOL)hasMultiDialog
{
    return self.dialogWindow.models.count > 0;
}

// MARK: - Dialog

///创建弹窗 如果为空的时候
- (void)loadDialogWindowIfNeeded
{
    if(!self.dialogWindow){
        self.dialogWindow = [self createWindowWithLevel:UIWindowLevelAlert];
        [self.dialogWindow makeKeyAndVisible];
    }
}

///当没有弹窗的时候 移除窗口
- (void)removeDialogWindowIfNeeded
{
    if(self.dialogWindow && self.dialogWindow.models.count == 0){
        [self.dialogWindow resignKeyWindow];
        self.dialogWindow = nil;
    }
}

- (void)showDialogController:(UIViewController *)dialogController inViewController:(UIViewController *)viewController priority:(NSInteger)priority completion:(void (^)(void))completion
{
    GKDialogModel *model = [GKDialogModel new];
    model.viewController = dialogController;
    model.requiredParentViewController = viewController;
    model.priority = priority;
    if (priority == NSNotFound) {
        [self showTopDialogWithModel:model completion:completion];
    } else {
        [self showDialogWithModel:model completion:completion];
    }
}

- (void)showDialog:(UIView *)dialog inViewController:(UIViewController *)viewController priority:(NSInteger)priority completion:(void (^)(void))completion
{
    GKDialogModel *model = [GKDialogModel new];
    model.view = dialog;
    model.requiredParentViewController = viewController;
    model.priority = priority;
    if (priority == NSNotFound) {
        [self showTopDialogWithModel:model completion:completion];
    } else {
        [self showDialogWithModel:model completion:completion];
    }
}

- (void)showDialogWithModel:(GKDialogModel*) model completion:(void (^)(void))completion
{
    if(self.dialogWindow.models.count > 0 || !model.displayEnabled){
        model.completion = completion;
        [self.pendingDialogs put:model];
    }else{
        [self loadDialogWindowIfNeeded];
        [self.dialogWindow addDialogModel:model];
        !completion ?: completion();
    }
}

- (void)showTopDialogWithModel:(GKDialogModel*) model completion:(void (^)(void))completion
{
    [self loadDialogWindowIfNeeded];
    model.priority = NSNotFound;
    [self.dialogWindow addDialogModel:model];
    !completion ?: completion();
}

- (void)removeDialogController:(UIViewController *)dialogController
{
    [self removeDialog:dialogController.view];
}

- (void)removeDialog:(UIView *)dialog
{
    [self.dialogWindow removeDialog:dialog];
    if (self.dialogWindow.models.count == 0) {
        GKDialogModel *model = [_pendingDialogs popForViewController:self.gkCurrentViewController];
        if(model){
            [self.dialogWindow addDialogModel:model];
            !model.completion ?: model.completion();
        }else{
            [self removeDialogWindowIfNeeded];
        }
    }
}

- (GKDialogWindow*)createWindowWithLevel:(UIWindowLevel)level
{
    GKDialogWindow *window = nil;
    if(@available(iOS 13, *)){
        UIWindowScene *scene = nil;
          for(UIWindowScene *s in UIApplication.sharedApplication.connectedScenes){
              if(s.activationState == UISceneActivationStateForegroundActive && [s isKindOfClass:UIWindowScene.class]){
                  scene = s;
                  break;
              }
          }
        if(scene){
            window = [[GKDialogWindow alloc] initWithWindowScene:scene];
        }
    }
    if(!window){
        window = GKDialogWindow.new;
    }
    window.frame = UIScreen.gkMainScreen.bounds;
    window.windowLevel = level;
    window.backgroundColor = UIColor.clearColor;
    
    return window;
}

@end
