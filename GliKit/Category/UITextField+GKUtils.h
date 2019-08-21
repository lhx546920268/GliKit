//
//  UITextField+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///
@interface UITextField (GKUtils)

//MARK: 内嵌视图

/**
 设置输入框左边图标
 *@param imageName 图标名称
 *@param padding 图标与文字的间距
 */
- (void)gk_setLeftViewWithImageName:(NSString*) imageName padding:(CGFloat) padding;

/**
 设置输入框右边图标
 *@param imageName 图标名称
 *@param padding 图标与文字的间距
 */
- (void)gk_setRightViewWithImageName:(NSString*) imageName padding:(CGFloat) padding;

/**
 设置默认分割线
 */
- (UIView*)gk_setDefaultSeparator;

/**
 底部分割线
 *@param color 分割线颜色
 *@param height 分割线高度
 *@return 分割线 使用autoLayout
 */
- (UIView*)gk_setSeparatorWithColor:(UIColor*) color height:(CGFloat) height;


/**
 添加默认的 inputAccessoryView

 @param title 标题
 @param target 点击确定方法回调，nil则使用默认的 关闭键盘
 @param action 点击确定方法回调，nil则使用默认的 关闭键盘
 */
- (void)gk_addDefaultInputAccessoryViewWithTitle:(NSString*) title target:(id) target action:(SEL) action;
- (void)gk_addDefaultInputAccessoryViewWithTarget:(id) target action:(SEL) action;
- (void)gk_addDefaultInputAccessoryViewWithTitle:(NSString *)title;
- (void)gk_addDefaultInputAccessoryView;

//MARK: 文本限制

/** 用于 gk_extraString
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 */
- (BOOL)gk_shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/**
 输入最大长度 default is 'NSUIntegerMax' 没有限制
 */
@property(nonatomic, assign) NSUInteger gk_maxLength;

/**
 输入类型 default is 'GKTextTypeAll'
 */
@property(nonatomic, assign) GKTextType gk_textType;

/**
 使用以上2个属性，不能自己监听文字变化 UIControlEventEditingChanged 否则会导致监听不对的问题，使用该属性来监听
 */
@property(nonatomic, copy) void(^gk_textDidChange)(void);

/**
 额外字符串 放在文字后面 需要配合 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 一起使用
 */
@property(nonatomic, copy) NSString *gk_extraString;

/**
 禁止的方法列表，如复制，粘贴，通过 NSStringFromSelector 把需要禁止的方法传进来，如禁止粘贴，可传 NSStringFromSelector(paste:) default is 'nil'
 */
@property(nonatomic,strong) NSArray<NSString*> *gk_forbiddenActions;

/**
 光标位置
 */
@property(nonatomic,assign) NSRange gk_selectedRange;

@end


