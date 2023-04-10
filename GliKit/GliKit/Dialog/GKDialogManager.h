//
//  GKDialogManager.h
//  GliKit
//
//  Created by 罗海雄 on 2023/2/13.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///弹窗管理
@interface GKDialogManager : NSObject

///单例
@property(nonatomic, class, readonly) GKDialogManager *sharedManager;

///共享的弹窗
@property(nonatomic, readonly, nullable) UIWindow *dialogWindow;

///是否有可见的窗口
@property(nonatomic, readonly) BOOL hasVisibleWindow;

///是否有多个弹窗
@property(nonatomic, readonly) BOOL hasMultiDialog;

///是否有等待显示的弹窗
@property(nonatomic, readonly) BOOL hasPendingDialog;

///当前可见的window
@property(nonatomic, readonly, nullable) UIWindow *visibleWindow;

///添加界面 会调用loadDialogWindowIfNeeded，只显示一个，如果已存在有的 要排队
- (void)showViewControllerInDialogWindow:(UIViewController*) vc completion:(void(^ _Nullable)(void)) completion;

///添加一个叠加显示的界面
- (void)showTopViewControllerInDialogWindow:(UIViewController*) vc completion:(void(^ _Nullable)(void)) completion;

///移除界面
- (void)removeViewControllerFromDialogWindow:(UIViewController*) vc completion:(void(^ _Nullable)(void)) completion;

///创建window
- (UIWindow*)createWindowWithLevel:(UIWindowLevel) level;

///让window可见，如果可能的话
- (void)makeWindowKeyAndVisibleIfEnabled:(UIWindow*) window;

///让window消失
- (void)resignKeyWindow:(UIWindow*) window;

///标记不可用
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
