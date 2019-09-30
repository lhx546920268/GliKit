//
//  GKMenuBarProps.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///菜单属性
@interface GKMenuBarProps : NSObject

/**
 内容间距 default is 'UIEdgeInsetZero'
 */
@property(nonatomic, assign) UIEdgeInsets contentInset;

//MARK: - 按钮样式

/**
 菜单按钮字体颜色
 */
@property(nonatomic, strong, null_resettable) UIColor *normalTextColor;

/**
 菜单按钮字体
 */
@property(nonatomic, strong, null_resettable) UIFont *normalFont;

/**
 菜单按钮 选中颜色
 */
@property(nonatomic, strong, null_resettable) UIColor *selectedTextColor;

/**
 菜单按钮 选中字体 nil的时候使用 normalFont default is 'nil'
 */
@property(nonatomic, strong, null_resettable) UIFont *selectedFont;

/**
 按钮间 只有 GKMenuBarStyleFit 生效 default is '5.0'
 */
@property(nonatomic, assign) CGFloat itemInterval;

/**
 按钮宽度延伸 left + right defautl is '10.0'
 */
@property(nonatomic, assign) CGFloat itemPadding;

//MARK: - 分割线

/**
 按钮选中下划线高度 default is '2.0'
 */
@property(nonatomic, assign) CGFloat indicatorHeight;

/**
 按钮选中下划线颜色 nil的使用使用 selectedTextColor default is 'nil'
 */
@property(nonatomic, strong, null_resettable) UIColor *indicatorColor;

/**
 下划线是否填满 default is 'NO' GKMenuBarStyleFill 有效
 */
@property(nonatomic, assign) BOOL indicatorShouldFill;

/**
 是否显示菜单顶部分割线
 */
@property(nonatomic, assign) BOOL displayTopDivider;

/**
 菜单底部分割线
 */
@property(nonatomic, assign) BOOL displayBottomDivider;

/**
 是否显示分隔符 只有 GKMenuBarStyleFit 生效 default is 'YES'
 */
@property(nonatomic, assign) BOOL displayItemDidvider;

@end

NS_ASSUME_NONNULL_END
