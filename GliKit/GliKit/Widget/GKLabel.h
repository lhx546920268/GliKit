//
//  GKLabel.h
//  GliKit
//
//  Created by 罗海雄 on 2020/1/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 自定义label
 */
@interface GKLabel : UILabel

/**
 文本边距 default is 'UIEdgeInsetsZero'
 */
@property(nonatomic, assign) UIEdgeInsets contentInsets;

/**
 是否可以长按选中 必须手动开启 userInteractionEnabled
 */
@property(nonatomic, assign) BOOL selectable;

/**
 选中时背景颜色 默认主题颜色
 */
@property(nonatomic, strong, null_resettable) UIColor *selectedBackgroundColor;

/**
 选中时文字颜色 默认主题颜色对应的 tintColor
 */
@property(nonatomic, strong, null_resettable) UIColor *selectedTextColor;

/**
 显示的菜单按钮，默认是复制
 */
@property(nonatomic, strong, null_resettable) NSArray<UIMenuItem*> *menuItems;

/**
 要显示的按钮，默认只显示复制
 */
@property(nonatomic, copy) BOOL(^canPerformActionHandler)(SEL action, id sender);

@end

NS_ASSUME_NONNULL_END
