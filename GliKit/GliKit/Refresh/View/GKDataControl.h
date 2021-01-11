//
//  GKDataControl.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///刷新回调
typedef void(^GKDataControlHandler)(void);

///UIScrollView 的滚动位置
static NSString *const GKDataControlOffset = @"contentOffset";

///滑动状态
typedef NS_ENUM(NSInteger, GKDataControlState)
{
    ///正在滑动
    GKDataControlStatePulling = 0,
    
    ///状态正常，用户没有滑动
    GKDataControlStateNormal,
    
    ///正在加载
    GKDataControlStateLoading,
    
    ///到达临界点
    GKDataControlStateReachCirticalPoint,
    
    ///没有数据了
    GKDataControlStateNoData,
    
    ///加载失败
    GKDataControlStateFail,
};

///下拉刷新和上拉加载的基类
@interface GKDataControl : UIView

///关联的 scrollView
@property(nonatomic, readonly, weak, nullable) UIScrollView *scrollView;

///触发的临界点 default `下拉刷新 60，上拉加载 45`
@property(nonatomic, assign) CGFloat criticalPoint;

///原来的内容 缩进
@property(nonatomic, assign) UIEdgeInsets originalContentInset;

///刷新回调 子类不需要调用这个
@property(nonatomic, copy, nullable) GKDataControlHandler handler;

///加载延迟 default `0.25`
@property(nonatomic, assign) NSTimeInterval loadingDelay;

///停止延迟 default `0.25`
@property(nonatomic, assign) NSTimeInterval stopDelay;

///下拉状态，很少需要主动设置该值
@property(nonatomic, assign) GKDataControlState state;

///是否正在动画
@property(nonatomic, assign) BOOL animating;

///是否需要scrollView 停止响应点击事件 当加载中 default `NO`
@property(nonatomic, assign) BOOL shouldDisableScrollViewWhenLoading;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

///初始化
- (instancetype)initWithScrollView:(UIScrollView*) scrollView NS_DESIGNATED_INITIALIZER;

///开始加载
- (void)startLoading NS_REQUIRES_SUPER;

///停止加载 外部调用 默认延迟刷新UI
- (void)stopLoading;

///已经开始加载 默认调用回调
- (void)onStartLoading NS_REQUIRES_SUPER;

///已经停止加载 默认 恢复 insets动画
- (void)onStopLoading NS_REQUIRES_SUPER;

///刷新状态改变 子类可通过这个改变UI
- (void)onStateChange:(GKDataControlState) state NS_REQUIRES_SUPER;

///获取对应状态的标题 没有则返回normal的标题
- (nullable NSString*)titleForState:(GKDataControlState) state;

///设置对应状态的标题
- (void)setTitle:(nullable NSString*) title forState:(GKDataControlState) state;

///UIScrollView 代理，主要用于当刚好到到达临界点时 松开手时获取contentOffset无法满足临界点
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView 
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint*)targetContentOffset;

///初始化
- (void)initViews NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
