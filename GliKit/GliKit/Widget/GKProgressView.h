//
//  GKProgressView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 进度条样式
 */
typedef NS_ENUM(NSInteger, GKProgressViewStyle){
    ///直线
    GKProgressViewStyleStraightLine = 0,
    
    ///圆环
    GKProgressViewStyleCircle = 1,
    
    ///圆饼 从空到满
    GKProgressViewStyleRoundCakesFromEmpty = 2,
    
    ///圆饼 从满到空
    GKProgressViewStyleRoundCakesFromFull = 3,
};

/**
 进度条
 */
@interface GKProgressView : UIView

/**
 是否开启进度条 default is 'YES' 当设置为NO时，将重置 progress
 */
@property(nonatomic, assign) BOOL openProgress;

/**
 当前进度，default is '0.0'，范围 0.0 ~ 1.0 当 openProgress = NO 时，忽略所有设置的值
 */
@property(nonatomic, assign) float progress;

/**
 进度条进度颜色 default is 'greenColor'
 */
@property(nonatomic, strong) UIColor *progressColor;

/**
 进度条轨道颜色 default is '[UIColor colorWithWhite:0.9 alpha:1.0]'
 */
@property(nonatomic, strong) UIColor *trackColor;

/**
 进度条样式
 */
@property(nonatomic, readonly) GKProgressViewStyle style;

/**
 进度条线条大小，当style = GKProgressViewStyleCircle，default is '10.0'，当 style = GKProgressViewStyleRoundCakes，default is '3.0'
 */
@property(nonatomic, assign) CGFloat progressLineWidth;

/**
 是否隐藏 当进度满的时候 default is 'YES'
 */
@property(nonatomic, assign) BOOL hideAfterFinish;

/**
 是否动画隐藏，使用渐变 default is 'YES'
 */
@property(nonatomic, assign) BOOL hideWidthAnimated;

/**
 是否显示百分比 default is 'NO'，只有当style = GKProgressViewStyleCircle 时 有效
 */
@property(nonatomic, assign) BOOL showPercent;

/**
 百分比label, 显示在圆环中间，只有当style = GKProgressViewStyleCircle && showPercent = YES 时 有效
 */
@property(nonatomic, readonly, nullable) UILabel *percentLabel;


/**
 [self initWithFrame:CGRectZero style:style]
 */
- (instancetype)initWithStyle:(GKProgressViewStyle) style;

/**
 构造方法
 *@param frame 位置大小
 *@param style 进度条样式
 *@return 一个实例
 */
- (instancetype)initWithFrame:(CGRect)frame style:(GKProgressViewStyle) style;

@end

NS_ASSUME_NONNULL_END

