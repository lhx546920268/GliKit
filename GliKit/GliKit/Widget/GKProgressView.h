//
//  GKProgressView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///进度条样式
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

///进度条
@interface GKProgressView : UIView

///进度条layer
@property(nonatomic, readonly) CAShapeLayer *progressLayer;

///是否开启进度条 default `YES` 当设置为`NO`时，将重置 progress
@property(nonatomic, assign) BOOL openProgress;

///当前进度，default `0.0`，范围 0.0 ~ 1.0 当 openProgress = NO 时，忽略所有设置的值
@property(nonatomic, assign) CGFloat progress;

///进度条进度颜色 default `greenColor`
@property(nonatomic, strong, null_resettable) UIColor *progressColor;

///是否隐藏 当进度满的时候 default `YES`
@property(nonatomic, assign) BOOL hideAfterFinish;

///是否动画隐藏，使用渐变 default `YES`
@property(nonatomic, assign) BOOL hideWidthAnimated;

///更新进度条样式
- (void)updateProgressStyle;

///进度条大小变了
- (void)onProgressSizeChange:(CGSize) size;

///更新进度条
- (void)updateProgress:(CGFloat) progress previousProgress:(CGFloat) previousProgress animated:(BOOL) animated;

@end

///直线进度条
@interface GKStraightLineProgressView : GKProgressView

@end

///圆环进度条
@interface GKCircleProgressView : GKProgressView

///进度条轨道颜色 default `[UIColor colorWithWhite:0.9 alpha:1.0]`
@property(nonatomic, strong, null_resettable) UIColor *trackColor;

///是否显示百分比 default `NO`
@property(nonatomic, assign) BOOL showPercent;

///百分比label, 显示在圆环中间
@property(nonatomic, readonly, nullable) UILabel *percentLabel;

///进度条线条大小 default `10.0`
@property(nonatomic, assign) CGFloat progressLineWidth;

@end

///圆饼进度条
@interface GKRoundCakesProgressView : GKProgressView

///是否从0到1, default `YES`
@property(nonatomic, assign) BOOL fromZero;

///边框和圆饼的间距，default `0`
@property(nonatomic, assign) CGFloat innerMargin;

@end

NS_ASSUME_NONNULL_END

