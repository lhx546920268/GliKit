//
//  GKPopover.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///弹出窗口箭头方向
typedef NS_ENUM(NSInteger, GKPopoverArrowDirection){
    
    ///向左
    GKPopoverArrowDirectionLeft = 0,
    
    ///向上
    GKPopoverArrowDirectionTop,
    
    ///向右
    GKPopoverArrowDirectionRight,
    
    ///向下
    GKPopoverArrowDirectionBottom,
};

@class GKPopover;

///弹出窗口代理
@protocol GKPopoverDelegate <NSObject>

@optional

///弹出窗口将要显示
- (void)popoverWillShow:(GKPopover*) popover;

///弹出窗口已经显示
- (void)popoverDidShow:(GKPopover*) popover;

///弹出窗口将要消失
- (void)popoverWillDismiss:(GKPopover*) popover;

///弹出窗口已经消失
- (void)popoverDidDismiss:(GKPopover*) popover;

@end

///无色透明视图 点击时关闭弹窗窗口
@interface GKPopoverOverlay : UIView

@end

///弹出窗口
@interface GKPopover : UIView

///背景颜色，default `whiteColor`
@property(nonatomic, strong) UIColor *fillColor;

///边框颜色，default `clearColor`
@property(nonatomic, strong) UIColor *strokeColor;

///边框线条宽度 default `0`，没有线条
@property(nonatomic, assign) CGFloat strokeWidth;

///圆角
@property(nonatomic, assign) CGFloat cornerRadius;

///顶部偏移量
@property(nonatomic, assign) CGFloat offset;

///箭头和 relatedRect 的间距 default `3`
@property(nonatomic, assign) CGFloat arrowMargin;

///弹窗距离父视图的最小边距 default `10`
@property(nonatomic, assign) CGFloat mininumMargin;

///内容边距 default `(8.0, 8.0, 8.0, 8.0)`
@property(nonatomic, assign) UIEdgeInsets contentInsets;

///箭头尖角坐标
@property(nonatomic, readonly) CGPoint arrowPoint;

///箭头大小 default `{15, 10}`
@property(nonatomic, assign) CGSize arrowSize;

///箭头方向
@property(nonatomic, readonly) GKPopoverArrowDirection arrowDirection;

///是否正在显示
@property(nonatomic, readonly) BOOL isShowing;

///内容视图 设置的内容视图要有确定的大小 设置后会自动 addSubview
@property(nonatomic, strong) UIView *contentView;

///透明视图
@property(nonatomic, readonly) GKPopoverOverlay *overlay;

///代理
@property(nonatomic, weak, nullable) id<GKPopoverDelegate> delegate;

///[self showInView:view relatedRect:rect animated:animated overlay:YES]
- (void)showInView:(UIView*) view relatedRect:(CGRect) rect animated:(BOOL) animated;

/// 显示弹出窗口
/// @param view 父视图
/// @param rect 触发菜单的按钮在 父视图中的位置大小，可用UIView 或 UIWindow 中的converRectTo 来转换
/// @param animated 是否动画
/// @param overlay 是否使用点击空白处关闭菜单
- (void)showInView:(UIView*) view relatedRect:(CGRect) rect animated:(BOOL) animated overlay:(BOOL) overlay;

///关闭弹出窗口
- (void)dismissAnimated:(BOOL) animated;

///初始化内容视图 子类重写
- (void)initContentView;

///重新绘制
- (void)redraw;

@end

NS_ASSUME_NONNULL_END
