//
//  UIViewController+GKDialog.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///弹窗动画类型
typedef NS_ENUM(NSInteger, GKDialogAnimate)
{
    ///无动画
    GKDialogAnimateNone = 0,
    
    ///缩放
    GKDialogAnimateScale,
    
    ///从上进入
    GKDialogAnimateFromTop,
    
    ///从下进入
    GKDialogAnimateFromBottom,
    
    ///自定义 要重写 didExecuteDialogShowCustomAnimate 和 didExecuteDialogDismissCustomAnimate
    GKDialogAnimateCustom,
};

/**
 弹窗类目
 如果 UIViewController 是 GKBaseViewController 或者其子类，并且没有使用xib，dialog属性将自动设置为 GKContainer
 此时 self.view 将不再是 GKContainer，要设置 container的大小和位置
 */
@interface UIViewController (GKDialog)

///是否以弹窗的样式显示 default `NO`
@property(nonatomic, readonly) BOOL isShowAsDialog;

/**
 弹窗 子类可在 viewDidLoad中设置，设置后会不会自动添加到view中，要自己设置对应的约束
 如果 UIViewController 是 GKBaseViewController 或者其子类，并且没有使用xib，dialog属性将自动设置为 GKContainer
 */
@property(nonatomic, strong, nullable) UIView *dialog;

///是否使用新窗口显示 使用新窗口显示可以保证 弹窗始终显示在最前面 必须在 showAsDialog 前设置
@property(nonatomic, assign) BOOL dialogShouldUseNewWindow;

///优先级 dialogShouldUseNewWindow = YES时生效 default `0`
@property(nonatomic, assign) NSInteger dialogPriority;

///关联的窗口
@property(nonatomic, readonly, nullable) UIWindow *dialogWindow;

///是否要点击透明背景dismiss default `YES`
@property(nonatomic, assign) BOOL shouldDismissDialogOnTapTranslucent;

///背景视图
@property(nonatomic, readonly, nullable) UIView *dialogBackgroundView;

///点击背景手势
@property(nonatomic, readonly) UITapGestureRecognizer *tapDialogBackgroundGestureRecognizer;

///出现动画 default `GKDialogAnimateNone`
@property(nonatomic, assign) GKDialogAnimate dialogShowAnimate;
 
///消失动画 default `GKDialogAnimateNone`
@property(nonatomic, assign) GKDialogAnimate dialogDismissAnimate;

///是否可以滑动关闭 default `YES`, only support `GKDialogAnimateFromBottom`
@property(nonatomic, assign) BOOL dialogInteractiveDismissible;

///弹窗是否已显示
@property(nonatomic, readonly) BOOL isDialogShowing;

///显示动画完成回调
@property(nonatomic, copy, nullable) void(^dialogShowCompletionHandler)(void);

///弹窗将要消失回调
@property(nonatomic,copy) void(^dialogWillDismissHandler)(BOOL animate);

///消失动画完成回调
@property(nonatomic, copy, nullable) void(^dialogDismissCompletionHandler)(void);

///显示 如果 dialogShouldUseNewWindow，则在新的窗口上显示，否则在 window.rootViewController.topest 通过present方式显示
- (void)showAsDialog;
- (void)showAsDialogAnimated:(BOOL) animated;

///在指定viewController 上显示，当使用dialogShouldUseNewWindow时，可设置只在某个viewController上显示
- (void)showAsDialogInViewController:(nullable UIViewController *)viewController;
- (void)showAsDialogInViewController:(nullable UIViewController *)viewController animated:(BOOL) animated;


/// 显示在指定viewControlelr
/// @param viewController parent
/// @param layoutHandler 布局回调 如果为空，则在viewController 上铺满
- (void)showAsDialogInViewController:(nullable UIViewController *)viewController layoutHandler:(void(NS_NOESCAPE ^ __nullable)(UIView *view, UIView *superview)) layoutHandler;
- (void)showAsDialogInViewController:(nullable UIViewController *)viewController layoutHandler:(void(NS_NOESCAPE ^ __nullable)(UIView *view, UIView *superview)) layoutHandler animated:(BOOL) animated;

///隐藏
- (void)dismissDialog;
- (void)dismissDialogAnimated:(BOOL) animated;
- (void)dismissDialogAnimated:(BOOL) animated completion:(void(^ _Nullable)(void)) completion;

///执行自定义显示动画 子类重写
- (void)didExecuteDialogShowCustomAnimate:(void(^ _Nullable)(BOOL finish)) completion;

///执行自定义消失动画 子类重写
- (void)didExecuteDialogDismissCustomAnimate:(void(^ _Nullable)(BOOL finish)) completion;

///一起执行的动画 子类可重写
- (void)showAnimateAlongsideWithDialog;
- (void)dismissAnimateAlongsideWithDialog;

///弹窗动画时长 default `0.25`
- (NSTimeInterval)showDurationForDialogAnimate:(GKDialogAnimate) animate;
- (NSTimeInterval)dismissDurationForDialogAnimate:(GKDialogAnimate) animate;

///键盘弹出来，调整弹窗位置，子类可重写
- (void)adjustDialogPosition;

///弹窗显示 消失回调，子类可重写
- (void)onDialogShow;
- (void)onDialogDismiss;

///点击弹窗背景
- (void)handleTapDialogBackground;

///弹窗初始化，在这里配置参数
- (void)onDialogInitialize;

@end

NS_ASSUME_NONNULL_END


