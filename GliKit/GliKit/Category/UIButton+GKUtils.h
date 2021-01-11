//
//  UIButton+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (GKUtils)

///原始的contentEdgeInsets
@property(nonatomic, assign) UIEdgeInsets gkContentEdgeInsets NS_DEPRECATED_IOS(2_0, 2_0, "Use GKButton instead");

/// 设置按钮图标位置 将改变 imageEdgeInsets titleEdgeInsets contentEdgeInsets，如果要设置对应的值，需要在调用该方法后设置 如果 title或者image为空 将全部设置0
/// @param position 图标位置
/// @param margin 图标和文字间隔
/// @warning UIControlContentHorizontalAlignmentFill 和 UIControlContentVerticalAlignmentFill 将忽略
- (void)gkSetImagePosition:(GKButtonImagePosition) position margin:(CGFloat) margin NS_DEPRECATED_IOS(2_0, 2_0, "Use GKButton instead");

@end

NS_ASSUME_NONNULL_END


