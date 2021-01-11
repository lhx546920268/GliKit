//
//  UIView+GKAutoLayout.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///autoLayout 计算大小方式
typedef NS_ENUM(NSInteger, GKAutoLayoutCalcType)
{
    ///计算宽度 需要给定高度
    GKAutoLayoutCalcTypeWidth = 0,
    
    ///计算高度 需要给定宽度
    GKAutoLayoutCalcTypeHeight = 1,
    
    ///计算大小，可给最大宽度和高度
    GKAutoLayoutCalcTypeSize = 2,
};

///自动布局扩展
@interface UIView (GKAutoLayout)

///判断是否存在约束
@property(nonatomic, readonly) BOOL gkExistConstraints;

///清空约束
- (void)gkRemoveAllContraints;

// MARK: - 获取约束 constraint

/**
 @warning 根据 item1.attribute1 = multiplier × item2.attribute2 + constant
 以下约束只根据 item1 和 attribute1 来获取
 */

///获取高度约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkHeightLayoutConstraint;

///获取宽度约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkWidthLayoutConstraint;

///获取左边距约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkLeftLayoutConstraint;

///获取右边距约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkRightLayoutConstraint;

///获取顶部距约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkTopLayoutConstraint;

///获取底部距约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkBottomLayoutConstraint;

///获取水平居中约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkCenterXLayoutConstraint;

///获取垂直居中约束 返回当前优先级最高的
@property (nonatomic, readonly, nullable) NSLayoutConstraint *gkCenterYLayoutConstraint;


///获取对应约束
- (nullable NSLayoutConstraint*)gkLayoutConstraintForAttribute:(NSLayoutAttribute) attribute;
- (nullable NSLayoutConstraint*)gkLayoutConstraintForAttribute:(NSLayoutAttribute) attribute withSecondItem:(nullable id) secondItem;

// MARK: - AutoLayout 计算大小

/// 根据给定的 size 计算当前view的大小，要使用auto layout
/// @param fitsSize 大小范围 0 则不限制范围
/// @param type 计算方式
- (CGSize)gkSizeThatFits:(CGSize) fitsSize type:(GKAutoLayoutCalcType) type;

///设置垂直方向的拥抱和压缩优先级
- (void)gkSetVerticalHugAndCompressionPriority:(UILayoutPriority) priority;

///设置水平方向的拥抱和压缩优先级
- (void)gkSetHorizontalHugAndCompressionPriority:(UILayoutPriority) priority;

@end

NS_ASSUME_NONNULL_END

