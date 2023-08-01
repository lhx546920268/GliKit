//
//  GKDialogManager.h
//  GliKit
//
//  Created by 罗海雄 on 2023/2/13.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///弹窗window
@interface GKDialogWindow : UIWindow

@end

///弹窗管理，使用新的UIWindow来显示
///不负责动画，只有添加和移除dialog
@interface GKDialogManager : NSObject

///单例
@property(nonatomic, class, readonly) GKDialogManager *sharedManager;

///共享的弹窗
@property(nonatomic, readonly, nullable) GKDialogWindow *dialogWindow;

///是否有多个弹窗
@property(nonatomic, readonly) BOOL hasMultiDialog;

///是否有等待显示的弹窗
@property(nonatomic, readonly) BOOL hasPendingDialog;

///添加界面 会调用loadDialogWindowIfNeeded，只显示一个，如果已存在有的 要排队，如果优先级是NSNotFound，则会叠加在已有的弹窗上面
- (void)showDialogController:(UIViewController*) dialogController inViewController:(nullable UIViewController*) viewController priority:(NSInteger) priority completion:(void(^ _Nullable)(void)) completion;

- (void)showDialog:(UIView*) dialog inViewController:(nullable UIViewController*) viewController priority:(NSInteger) priority completion:(void(^ _Nullable)(void)) completion;

///移除界面
- (void)removeDialogController:(UIViewController*) dialogController;
- (void)removeDialog:(UIView*) dialog;

///标记不可用
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
