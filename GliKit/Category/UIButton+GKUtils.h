//
//  UIButton+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIButton 图标位置
 */
typedef NS_ENUM(NSInteger, GKButtonImagePosition){
    
    ///左边 系统默认
    GKButtonImagePositionLeft = 0,
    
    ///图标在文字右边
    GKButtonImagePositionRight,
    
    ///图标在文字顶部
    GKButtonImagePositionTop,
    
    ///图标在文字底部
    GKButtonImagePositionBottom,
};

@interface UIButton (GKUtils)

/**
 设置按钮图标位置 将改变 imageEdgeInsets titleEdgeInsets contentEdgeInsets，如果要设置对应的值，需要在调用该方法后设置 如果 title或者image为空 将全部设置0
 
 @param position 图标位置
 @param margin 图标和文字间隔
 @warning UIControlContentHorizontalAlignmentFill 和 UIControlContentVerticalAlignmentFill 将忽略
 */
- (void)gkSetImagePosition:(GKButtonImagePosition) position margin:(CGFloat) margin;

/**
 设置对应状态的背景颜色

 @param backgroundColor 背景颜色，为nil时移除
 @param state 状态，支持  UIControlStateNormal， UIControlStateHighlighted，UIControlStateDisabled，UIControlStateSelected
 */
- (void)gkSetBackgroundColor:(UIColor*) backgroundColor forState:(UIControlState) state;

@end


