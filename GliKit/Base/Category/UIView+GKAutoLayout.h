//
//  UIView+GKAutoLayout.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///autoLayout 计算大小方式
typedef NS_ENUM(NSInteger, GKAutoLayoutCalculateType)
{
    ///计算宽度 需要给定高度
    GKAutoLayoutCalculateTypeWidth = 0,
    
    ///计算高度 需要给定宽度
    GKAutoLayoutCalculateTypeHeight = 1,
    
    ///计算大小，可给最大宽度和高度
    GKAutoLayoutCalculateTypeSize = 2,
};

///自动布局扩展
@interface UIView (GKAutoLayout)

/**
 判断是否存在约束
 */
@property(nonatomic, readonly) BOOL gk_existConstraints;

//MARK:- 获取约束 constraint

/**
 清空约束
 */
- (void)gk_removeAllContraints;

/**
 @warning 根据 item1.attribute1 = multiplier × item2.attribute2 + constant
 以下约束只根据 item1 和 attribute1 来获取
 */

/**
 获取高度约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_heightLayoutConstraint;

/**
 获取宽度约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_widthLayoutConstraint;

/**
 获取左边距约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_leftLayoutConstraint;

/**
 获取右边距约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_rightLayoutConstraint;

/**
 获取顶部距约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_topLayoutConstraint;

/**
 获取底部距约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_bottomLayoutConstraint;

/**
 获取水平居中约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_centerXLayoutConstraint;

/**
 获取垂直居中约束 返回当前优先级最高的
 */
@property (nonatomic,readonly) NSLayoutConstraint *gk_centerYLayoutConstraint;


///获取对应约束
- (NSLayoutConstraint*)gk_layoutConstraintForAttribute:(NSLayoutAttribute) attribute;
- (NSLayoutConstraint*)gk_layoutConstraintForAttribute:(NSLayoutAttribute) attribute withSecondItem:(id) secondItem;

//MARK:- AutoLayout 计算大小

/**根据给定的 size 计算当前view的大小，要使用auto layout
 *@param fitsSize 大小范围 0 则不限制范围
 *@param type 计算方式
 *@return view 大小
 */
- (CGSize)gk_sizeThatFits:(CGSize) fitsSize type:(GKAutoLayoutCalculateType) type;

///设置垂直方向的拥抱和压缩优先级
- (void)gk_setVerticalHugAndCompressionPriority:(UILayoutPriority) priority;

///设置水平方向的拥抱和压缩优先级
- (void)gk_setHorizontalHugAndCompressionPriority:(UILayoutPriority) priority;

@end

