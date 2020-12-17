//
//  UIView+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/25.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///视图扩展
@interface UIView (GKUtils)

// MARK: - 坐标

/**
 get and set frame.origin.y
 */
@property(nonatomic, assign) CGFloat gkTop;

/**
 get and set (frame.origin.y + frame.size.height)
 */
@property(nonatomic, assign) CGFloat gkBottom;

/**
 get and set (frame.origin.x + frame.size.width)
 */
@property(nonatomic, assign) CGFloat gkRight;

/**
 get and set frame.origin.x
 */
@property(nonatomic, assign) CGFloat gkLeft;

/**
 get and set frame.size.width
 */
@property(nonatomic, assign) CGFloat gkWidth;

/**
 get and set frame.size.height
 */
@property(nonatomic, assign) CGFloat gkHeight;

/**
 get and set frame.size
 */
@property(nonatomic, assign) CGSize gkSize;

/**
 get and set center.x
 */
@property(nonatomic, assign) CGFloat gkCenterX;

/**
 get and set center.y
 */
@property(nonatomic, assign) CGFloat gkCenterY;

/**
 通过xib加载 xib的名称必须和类的名称一致
 */
+ (nullable instancetype)loadFromNib;

/**
 删除所有子视图
 */
- (void)gkRemoveAllSubviews;

/**
 安全区域 兼容ios 11
 */
@property(nonatomic, readonly) UIEdgeInsets gkSafeAreaInsets;

/**
 设置部分圆角
 
 @param cornerRadius 圆角
 @param corners 圆角位置
 @param rect 视图大小，如果使用autoLayout
 */
- (void)gkSetCornerRadius:(CGFloat) cornerRadius corners:(UIRectCorner) corners rect:(CGRect) rect;

@end

///视图扩展
@interface UIScrollView (GKUtils)

/**
 get and set contentInset
 */
@property(nonatomic, assign) CGFloat gkInsetTop;
@property(nonatomic, assign) CGFloat gkInsetLeft;
@property(nonatomic, assign) CGFloat gkInsetBottom;
@property(nonatomic, assign) CGFloat gkInsetRight;

@end

NS_ASSUME_NONNULL_END

