//
//  GKContainer.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///大小自适应
static const CGFloat GKWrapContent = -1;

///自动布局 安全区域
typedef NS_OPTIONS(NSUInteger, GKSafeLayoutGuide){
    
    ///没有
    GKSafeLayoutGuideNone = 0,
    
    ///上
    GKSafeLayoutGuideTop = 1 << 0,
    
    ///左
    GKSafeLayoutGuideLeft = 1 << 1,
    
    ///下
    GKSafeLayoutGuideBottom = 1 << 2,
    
    ///右
    GKSafeLayoutGuideRight = 1 << 3,
    
    ///全部
    GKSafeLayoutGuideAll = GKSafeLayoutGuideTop | GKSafeLayoutGuideLeft | GKSafeLayoutGuideBottom | GKSafeLayoutGuideRight,
};

///自动布局 loading 范围
typedef NS_OPTIONS(NSUInteger, GKOverlayArea){
    
    ///都不遮住 header 和 footer会看到得到
    GKOverlayAreaNone = 0,
    
    ///pageloading视图将遮住header
    GKOverlayAreaPageLoadingTop = 1 << 1,
    
    ///pageloading视图将遮住footer
    GKOverlayAreaPageLoadingBottom = 1 << 2,
    
    ///空视图将遮住header
    GKOverlayAreaEmptyViewTop = 1 << 3,
    
    ///空视图将遮住footer
    GKOverlayAreaEmptyViewBottom = 1 << 4,
    
    ///遮住顶部
    GKOverlayAreaTop = GKOverlayAreaPageLoadingTop | GKOverlayAreaEmptyViewTop,
    
    ///遮住底部
    GKOverlayAreaBottom = GKOverlayAreaPageLoadingBottom | GKOverlayAreaEmptyViewBottom,
    
    ///遮住所有
    GKOverlayAreaAll = GKOverlayAreaTop | GKOverlayAreaBottom,
};

@class GKBaseViewController, MASViewAttribute;

/**
 基础容器视图
 */
@interface GKContainer : UIView

///固定在顶部的视图
@property(nonatomic, strong, nullable) UIView *topView;

///顶部视图原始高度
@property(nonatomic, readonly) CGFloat topViewOriginalHeight;

///固定在底部的视图
@property(nonatomic, strong, nullable) UIView *bottomView;

///底部视图原始高度
@property(nonatomic, readonly) CGFloat bottomViewOriginalHeight;

///内容视图
@property(nonatomic, strong, nullable) UIView *contentView;

///内容视图间距 default is `zero`
@property(nonatomic, assign) UIEdgeInsets contentInsets;

///关联的viewController
@property(nonatomic, weak, readonly, nullable) GKBaseViewController *viewController;

///自动布局 安全区域 default is 'GKSafeLayoutGuideTop' 如果是以弹窗的形式显示 必须设为none
@property(nonatomic, assign) GKSafeLayoutGuide safeLayoutGuide;

///自动布局 loading 范围
@property(nonatomic, assign) GKOverlayArea overlayArea;

///布局完成回调
@property(nullable, nonatomic, copy) void(^layoutSubviewsHandler)(void);

///顶部约束 如果有topView，就是 topView.mas_bottom，否则如果包含safeLayoutGuide.top，就是 safeAreaTop，否则就是self.mas_top
@property(nonatomic, readonly) MASViewAttribute *topLayoutAttribute;

///底部约束 如果有bottomView，就是 bottomView.mas_top
///如果包含safeLayoutGuide.bottom，就是 safeAreaBottom
///否则就是self.mas_bottom，如果有tabBar 还会减去 tabBar.height
@property(nonatomic, readonly) MASViewAttribute *bottomLayoutAttribute;

///底部约束偏移量
@property(nonatomic, readonly) CGFloat bottomLayoutConstraintOffset;

///左边约束 如果包含safeLayoutGuide.left，就是 safeAreaLeft，否则就是self.mas_leading
@property(nonatomic, readonly) MASViewAttribute *leftLayoutAttribute;

///右边约束 如果包含safeLayoutGuide.right，就是 safeAreaRight，否则就是self.mas_trail
@property(nonatomic, readonly) MASViewAttribute *rightLayoutAttribute;

///初始化
- (void)initParams;

/**
 通过 UIViewController初始化
 */
- (instancetype)initWithViewController:(nullable GKBaseViewController*) viewController;

/**
 设置顶部视图
 @param topView 顶部视图
 @param height 视图高度，GKWrapContent 为自适应
 */
- (void)setTopView:(nullable UIView *)topView height:(CGFloat) height;

/**
 设置底部视图
 
 @param bottomView 底部视图
 @param height 视图高度，GKWrapContent 为自适应
 */
- (void)setBottomView:(nullable UIView *)bottomView height:(CGFloat) height;

/**
 设置顶部视图隐藏 视图必须有高度约束
 @param hidden 是否隐藏
 @param animate 是否动画
 */
- (void)setTopViewHidden:(BOOL) hidden animate:(BOOL) animate;

/**
 设置底部视图隐藏 视图必须有高度约束
 @param hidden 是否隐藏
 @param animate 是否动画
 */
- (void)setBottomViewHidden:(BOOL) hidden animate:(BOOL) animate;

@end

NS_ASSUME_NONNULL_END

