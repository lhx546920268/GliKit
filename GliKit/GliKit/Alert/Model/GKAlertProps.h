//
//  GKAlertProps.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 弹窗属性
 */
@interface GKAlertProps : NSObject<NSCopying>

//MARK: - 通用

/**
 主题颜色
 */
@property(nonatomic, strong) UIColor *mainColor;

/**
 整个内容边距
 */
@property(nonatomic, assign) UIEdgeInsets contentInsets;

/**
 提示框内容（除了按钮）最低高度
 */
@property(nonatomic, assign) CGFloat contentMinHeight;

/**
 圆角
 */
@property(nonatomic, assign) CGFloat cornerRadius;

/**
 文字和图标和父视图的间距
 */
@property(nonatomic, assign) UIEdgeInsets textInsets;

/**
 内容垂直间距
 */
@property(nonatomic, assign) CGFloat verticalSpacing;

/**
 actionSheet 取消按钮和 内容视图的背景颜色
 */
@property(nonatomic, strong) UIColor *spacingBackgroundColor;

//MARK: - 取消按钮

/**
 actionSheet 取消按钮和 内容视图的间距
 */
@property(nonatomic, assign) CGFloat cancelButtonVerticalSpacing;

/**
 取消按钮字体
 */
@property(nonatomic, strong) UIFont *cancelButtonFont;

/**
 取消按钮字体颜色
 */
@property(nonatomic, strong) UIColor *cancelButtonTextColor;

//MARK: - 标题

/**
 标题字体
 */
@property(nonatomic, strong) UIFont *titleFont;

/**
 标题字体颜色
 */
@property(nonatomic, strong) UIColor *titleTextColor;

/**
 标题对其方式
 */
@property(nonatomic, assign) NSTextAlignment titleTextAlignment;

//MARK: - 信息

/**
 信息字体
 */
@property(nonatomic, strong) UIFont *messageFont;

/**
 信息字体颜色
 */
@property(nonatomic, strong) UIColor *messageTextColor;

/**
 信息对其方式
 */
@property(nonatomic, assign) NSTextAlignment messageTextAlignment;

//MARK: - 按钮

/**
 按钮高度 alert 45 actionSheet 50
 */
@property(nonatomic, assign) CGFloat buttonHeight;

/**
 按钮字体
 */
@property(nonatomic, strong) UIFont *butttonFont;

/**
 高亮背景
 */
@property(nonatomic, strong) UIColor *highlightedBackgroundColor;

/**
 按钮无法点击时的字体颜色
 */
@property(nonatomic, strong) UIColor *disableButtonTextColor;

/**
 按钮无法点击时的字体
 */
@property(nonatomic, strong) UIFont *disableButtonFont;

//MARK: - 警示

/**
 按钮字体颜色
 */
@property(nonatomic, strong) UIColor *buttonTextColor;

/**
 警示按钮字体
 */
@property(nonatomic, strong) UIFont *destructiveButtonFont;

/**
 警示按钮字体颜色
 */
@property(nonatomic, strong) UIColor *destructiveButtonTextColor;

/**
 警示按钮背景颜色
 */
@property(nonatomic, strong) UIColor *destructiveButtonBackgroundColor;

//MARK: - Init

/**
 alert 单例
 */
+ (instancetype)alertInstance;

/**
 actionSheet 单例
 */
+ (instancetype)actionSheetInstance;

@end

NS_ASSUME_NONNULL_END
